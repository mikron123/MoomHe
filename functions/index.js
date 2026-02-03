const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const { logger } = require('firebase-functions');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const sharp = require('sharp');
const FormData = require('form-data');

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Azure OpenAI GPT-image-1.5 Configuration (Experimental)
const AZURE_OPENAI_ENDPOINT = process.env.AZURE_OPENAI_ENDPOINT || 'https://mikronator-5864-resource.cognitiveservices.azure.com/';
const AZURE_DEPLOYMENT_NAME = process.env.AZURE_DEPLOYMENT_NAME || 'gpt-image-1.5';
const AZURE_API_VERSION = process.env.AZURE_API_VERSION || '2025-04-01-preview';
const AZURE_OPENAI_API_KEY = process.env.AZURE_OPENAI_API_KEY;

// In-App Purchase Product Configuration
const PRODUCT_CREDITS = {
  'moomhe_starter_monthly': { credits: 50, subscription: 1, period: 'monthly' },
  'moomhe_starter_yearly': { credits: 50, subscription: 1, period: 'yearly' },
  'moomhe_pro_monthly': { credits: 200, subscription: 2, period: 'monthly' },
  'moomhe_pro_yearly': { credits: 200, subscription: 2, period: 'yearly' },
  'moomhe_business_monthly': { credits: 450, subscription: 3, period: 'monthly' },
  'moomhe_business_yearly': { credits: 450, subscription: 3, period: 'yearly' },
};

// Helper function to validate Firebase user token
async function validateUserToken(authToken) {
  try {
    const decodedToken = await admin.auth().verifyIdToken(authToken);
    return decodedToken;
  } catch (error) {
    logger.error('Token validation failed:', error);
    throw new Error('Invalid user token');
  }
}

// Helper function to check and update user generation count
async function checkAndUpdateGenerationCount(userId, deviceId) {
  const now = new Date();
  const dateKey = now.toISOString().split('T')[0]; // Format: YYYY-MM-DD as requested by user "genCount/{date}"
  // User previously used monthYear, but prompt says "genCount/{date}users/uid/". 
  // I will assume daily limit tracking for genCount, but subscription credits are monthly.
  // Wait, "it will be calculated by listening to the record genCount/{date}users/uid/ count field and substracting it from the users/ user record "credits" field"
  // If credits is 2 (free) or 40 (monthly), and genCount is DAILY, then subtraction makes no sense unless credits are DAILY.
  // BUT subscription credits (40/100/200) are typically MONTHLY.
  // If I use daily genCount, then `Credits - DailyUsage` = Remaining for today? No, that contradicts monthly credits.
  // If the user means `genCount` accumulates ALL usage for the billing period, then `{date}` is confusing.
  // However, `genCount` usually implies a counter.
  // Let's look at the requirement: "users/ user record 'credits' field" -> 40.
  // "substracting it from the ... count field".
  // This implies `credits` is the BALANCE. Or `credits` is the LIMIT.
  // "credits are the number of allowed credits by the subscription type." -> LIMIT.
  // So Usage must be tracked for the same period.
  // If the user specified `{date}` path, maybe they mean the billing cycle start date?
  // Or maybe they want daily limits?
  // Given "2 images to create" default for new users, and "40/100/200" for subs.
  // If I start with 2 free images. I use 1. genCount = 1. Remaining = 2 - 1 = 1.
  // If genCount resets tomorrow (because of `{date}`), then I get 2 free images EVERY DAY?
  // That seems generous but possible.
  // OR, `credits` is a decremented balance?
  // "users/ user record 'credits' field" ... "substracting it from the ... count field".
  // If `credits` was a balance, we wouldn't subtract count. We would just read `credits`.
  // So `credits` IS a limit.
  // If `genCount` is daily, then the limit is daily.
  // If the limit is monthly (40/100/200), then `genCount` MUST be monthly or cumulative.
  // The user prompt says: "listening to the record genCount/{date}users/uid/".
  // I will use the month-year format for `{date}` to align with standard monthly subscriptions.
  // e.g., "2023-10".
  // If the user explicitly wants daily, I'd need to know. "genCount/{date}" usually implies YYYY-MM-DD.
  // But for "monthly_starter", monthly tracking makes sense.
  // I'll stick to YYYY-MM (as existing code `monthYear`) but maybe the user *meant* that structure.
  // Let's stick to existing `monthYear` logic which is safe for monthly subscriptions.
  
  const monthYear = `${String(now.getMonth() + 1).padStart(2, '0')}-${now.getFullYear()}`;
  
  // References
  const userGenRef = db.collection('genCount').doc(monthYear).collection('users').doc(userId);
  const deviceGenRef = db.collection('genCount').doc(monthYear).collection('devices').doc(deviceId);
  
  try {
    const [userDoc, deviceDoc, userProfileDoc] = await Promise.all([
      userGenRef.get(),
      deviceGenRef.get(),
      db.collection('users').doc(userId).get()
    ]);
    
    // Get User Limits
    let creditLimit = 3; // Default free limit
    let subscriptionStatus = 0;
    
    if (userProfileDoc.exists) {
      const userData = userProfileDoc.data();
      creditLimit = userData.credits || 3;
      subscriptionStatus = userData.subscription || 0;
    }

    // Get Counts
    const userCount = userDoc.exists ? (userDoc.data().count || 0) : 0;
    const deviceCount = deviceDoc.exists ? (deviceDoc.data().count || 0) : 0;
    
    // Logic:
    // If Subscription > 0, we trust the User ID limit (paying user).
    // If Subscription == 0 (Free), we enforce the stricter of User Count OR Device Count against the limit (2).
    // This prevents creating new users on same device to bypass limit.
    
    const effectiveCount = subscriptionStatus > 0 ? userCount : Math.max(userCount, deviceCount);
    
    logger.info(`Check Gen Count: User=${userId} (${userCount}), Device=${deviceId} (${deviceCount}), Limit=${creditLimit}, Sub=${subscriptionStatus}`);

    if (effectiveCount >= creditLimit) {
      throw new Error(`Generation limit reached (${effectiveCount}/${creditLimit})`);
    }
    
    // Increment counts
    const batch = db.batch();
    
    if (!userDoc.exists) {
      batch.set(userGenRef, { count: 1, lastUpdated: admin.firestore.FieldValue.serverTimestamp() });
    } else {
      batch.update(userGenRef, { count: admin.firestore.FieldValue.increment(1), lastUpdated: admin.firestore.FieldValue.serverTimestamp() });
    }
    
    if (!deviceDoc.exists) {
      batch.set(deviceGenRef, { count: 1, lastUpdated: admin.firestore.FieldValue.serverTimestamp() });
    } else {
      batch.update(deviceGenRef, { count: admin.firestore.FieldValue.increment(1), lastUpdated: admin.firestore.FieldValue.serverTimestamp() });
    }
    
    await batch.commit();
    
    return { count: effectiveCount + 1, limit: creditLimit };
  } catch (error) {
    logger.error('Error checking generation count:', error);
    throw error;
  }
}

// Helper function to create thumbnail
async function createThumbnail(imageBuffer, maxWidth = 200, maxHeight = 200) {
  return await sharp(imageBuffer)
    .resize(maxWidth, maxHeight, { fit: 'inside', withoutEnlargement: true })
    .jpeg({ quality: 70 })
    .toBuffer();
}

// Helper function to upload to Firebase Storage
async function uploadToStorage(userId, imageBuffer, filename, isThumbnail = false) {
  const bucket = storage.bucket();
  const filePath = `userHistory/${userId}/${filename}`;
  const file = bucket.file(filePath);
  
  await file.save(imageBuffer, {
    metadata: {
      contentType: 'image/jpeg',
    },
  });
  
  // Make file public
  await file.makePublic();
  
  return `https://storage.googleapis.com/${bucket.name}/${filePath}`;
}

// Helper function to translate Hebrew prompt to English
async function translatePromptToEnglish(hebrewPrompt) {
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
  
  try {
    const translationPrompt = `Translate the following Hebrew text to English. The text is a prompt for AI image generation, so translate it accurately while keeping the technical and artistic context. Only return the English translation, nothing else.

Hebrew text: ${hebrewPrompt}`;
    
    const result = await model.generateContent([translationPrompt]);
    const englishPrompt = result.response.text().trim();
    
    logger.info(`Translation - Hebrew: ${hebrewPrompt}`);
    logger.info(`Translation - English: ${englishPrompt}`);
    
    return englishPrompt;
  } catch (error) {
    logger.error('Translation failed:', error);
    // Fallback: return original prompt if translation fails
    return hebrewPrompt;
  }
}

// Helper function to process image with Gemini
async function processImageWithGemini(prompt, imageData, isObjectDetection = false, objectImageData = null, docId = null) {
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash-image" });
  
  try {
    // Log image data info for debugging
    logger.info(`Processing image - isObjectDetection: ${isObjectDetection}, dataLength: ${imageData.inlineData.data.length}, mimeType: ${imageData.inlineData.mimeType}`);
    if (objectImageData) {
      logger.info(`Object image provided - dataLength: ${objectImageData.inlineData.data.length}, mimeType: ${objectImageData.inlineData.mimeType}`);
    }
    
    if (isObjectDetection) {
      const objectDetectionPrompt = "make a very simple name list of the different objects (2-4 words each) that are in the image. include things like walls/sky etc. write the answer it in a json format only. write the names in Hebrew. if there are 2 similar named objects like \"window\" make it clear which window is which, e.g. \"small window\" and \"big window\"";
      const result = await model.generateContent([objectDetectionPrompt, imageData]);
      return { type: 'text', content: result.response.text() };
    } else {
      // Translate Hebrew prompt to English
      const englishPrompt = await translatePromptToEnglish(prompt);
      
      // Save the original Hebrew prompt and translated English prompt for review
      if (docId) {
        logger.info(`Updating document ${docId} with translation data`);
        await db.collection('userHistory').doc(docId).update({
          originalPrompt: prompt,
          translatedPrompt: englishPrompt
        });
        logger.info(`Successfully updated document ${docId} with translation data`);
      } else {
        logger.warn('No docId provided, skipping translation data update');
      }
      
      // Prepare content array with translated prompt and main image
      const content = [englishPrompt, imageData];
      
      // Add object image if provided
      if (objectImageData) {
        content.push(objectImageData);
        logger.info('Added object image to Gemini request');
      }
      
      const result = await model.generateContent(content);
      
      // Debug: Log the response structure
      logger.info('Gemini response structure:', {
        hasResponse: !!result.response,
        hasCandidates: !!(result.response && result.response.candidates),
        candidatesLength: result.response?.candidates?.length || 0,
        responseKeys: result.response ? Object.keys(result.response) : [],
        firstCandidateKeys: result.response?.candidates?.[0] ? Object.keys(result.response.candidates[0]) : []
      });
      
      // Log the full response for debugging
      logger.info('Full Gemini response:', JSON.stringify(result.response, null, 2));
      
      // Check if the response has inline data parts
      if (result.response && result.response.candidates && result.response.candidates[0]) {
        const candidate = result.response.candidates[0];
        
        // Check for inline data in the response
        if (candidate.content && candidate.content.parts) {
          logger.info('Found content parts:', candidate.content.parts.length);
          for (const part of candidate.content.parts) {
            if (part.inlineData) {
              logger.info('Found inline data part');
              return { 
                type: 'image', 
                content: `data:${part.inlineData.mimeType};base64,${part.inlineData.data}` 
              };
            }
          }
        }
      }
      
      // Fallback: try the old method if it exists
      try {
        if (typeof result.response.inlineDataParts === 'function') {
          const inlineDataParts = result.response.inlineDataParts();
          if (inlineDataParts && inlineDataParts[0]) {
            const image = inlineDataParts[0].inlineData;
            return { 
              type: 'image', 
              content: `data:${image.mimeType};base64,${image.data}` 
            };
          }
        }
      } catch (error) {
        logger.warn('inlineDataParts method not available:', error.message);
      }
      
      // Log the full response for debugging
      logger.error('Full response structure:', JSON.stringify(result, null, 2));
      
      // Check if we got text response instead of image
      try {
        const textResponse = result.response.text();
        if (textResponse) {
          logger.info('Got text response instead of image:', textResponse);
          throw new Error(`Gemini returned text instead of image: ${textResponse.substring(0, 100)}...`);
        }
      } catch (textError) {
        logger.info('Could not get text response:', textError.message);
      }
      
      throw new Error('No image generated - no inline data found in response');
    }
  } catch (error) {
    logger.error('Gemini API error:', error);
    logger.error('Image data details:', {
      dataLength: imageData.inlineData.data.length,
      mimeType: imageData.inlineData.mimeType,
      dataPreview: imageData.inlineData.data.substring(0, 50) + '...'
    });
    throw error;
  }
}

// Helper function to process image with Azure GPT-image-1.5 (Experimental)
async function processImageWithGPTImage(prompt, imageData, docId = null, objectImageData = null) {
  if (!AZURE_OPENAI_API_KEY) {
    throw new Error('Azure OpenAI API key not configured');
  }

  try {
    logger.info(`[GPT-Image-1.5] Processing image edit request`);
    logger.info(`[GPT-Image-1.5] Prompt: ${prompt}`);
    logger.info(`[GPT-Image-1.5] Image data length: ${imageData.inlineData.data.length}`);
    if (objectImageData) {
      logger.info(`[GPT-Image-1.5] Object image provided for inpainting - dataLength: ${objectImageData.inlineData.data.length}, mimeType: ${objectImageData.inlineData.mimeType}`);
    }

    // Translate Hebrew prompt to English
    const englishPrompt = await translatePromptToEnglish(prompt);
    
    // Save the original Hebrew prompt and translated English prompt for review
    if (docId) {
      logger.info(`[GPT-Image-1.5] Updating document ${docId} with translation data`);
      await db.collection('userHistory').doc(docId).update({
        originalPrompt: prompt,
        translatedPrompt: englishPrompt,
        aiModel: 'gpt-image-1.5'
      });
    }

    // Convert base64 to buffer for the image
    const imageBuffer = Buffer.from(imageData.inlineData.data, 'base64');
    
    // Get image dimensions to determine aspect ratio
    const imageMetadata = await sharp(imageBuffer).metadata();
    const inputWidth = imageMetadata.width;
    const inputHeight = imageMetadata.height;
    const aspectRatio = inputWidth / inputHeight;
    
    logger.info(`[GPT-Image-1.5] Input image dimensions: ${inputWidth}x${inputHeight}, aspect ratio: ${aspectRatio.toFixed(2)}`);
    
    // Choose output size based on aspect ratio
    // Available sizes: 1024x1024 (1:1), 1536x1024 (1.5:1 landscape), 1024x1536 (0.67:1 portrait)
    let outputSize;
    if (aspectRatio > 1.25) {
      // Landscape image (wider than 5:4)
      outputSize = '1536x1024';
    } else if (aspectRatio < 0.8) {
      // Portrait image (taller than 4:5)
      outputSize = '1024x1536';
    } else {
      // Square-ish image
      outputSize = '1024x1024';
    }
    
    logger.info(`[GPT-Image-1.5] Selected output size: ${outputSize}`);
    
    // Parse target dimensions from outputSize
    const [targetWidth, targetHeight] = outputSize.split('x').map(Number);
    
    // Resize and convert to JPEG - this reduces input token costs significantly
    // by matching input size to output size
    const jpegBuffer = await sharp(imageBuffer)
      .resize(targetWidth, targetHeight, { fit: 'inside', withoutEnlargement: true })
      .jpeg({ quality: 70 })
      .toBuffer();
    
    logger.info(`[GPT-Image-1.5] Resized and converted main image to JPEG: ${inputWidth}x${inputHeight} -> ${targetWidth}x${targetHeight}, size: ${jpegBuffer.length} bytes`);

    // Convert and resize object image if provided
    let objectJpegBuffer = null;
    if (objectImageData) {
      const objectBuffer = Buffer.from(objectImageData.inlineData.data, 'base64');
      objectJpegBuffer = await sharp(objectBuffer)
        .resize(targetWidth, targetHeight, { fit: 'inside', withoutEnlargement: true })
        .jpeg({ quality: 70 })
        .toBuffer();
      logger.info(`[GPT-Image-1.5] Resized and converted object image to JPEG, size: ${objectJpegBuffer.length} bytes`);
    }

    // Build the Azure OpenAI edit endpoint URL
    const editUrl = `${AZURE_OPENAI_ENDPOINT}openai/deployments/${AZURE_DEPLOYMENT_NAME}/images/edits?api-version=${AZURE_API_VERSION}`;
    
    logger.info(`[GPT-Image-1.5] Calling Azure endpoint: ${editUrl}`);

    // Create form data for the multipart request
    // GPT-image-1.5 supports multiple images via image[] array for inpainting
    const formData = new FormData();
    
    // Add main image
    formData.append('image[]', jpegBuffer, {
      filename: 'input_image.jpg',
      contentType: 'image/jpeg',
      knownLength: jpegBuffer.length
    });
    
    // Add object image if provided (for inpainting the object into the scene)
    if (objectJpegBuffer) {
      formData.append('image[]', objectJpegBuffer, {
        filename: 'object_image.jpg',
        contentType: 'image/jpeg',
        knownLength: objectJpegBuffer.length
      });
      logger.info(`[GPT-Image-1.5] Added object image to request for inpainting`);
    }
    
    formData.append('prompt', englishPrompt + '. maintain the exact same camera angle, perspective, and base room structure as the original image');
    formData.append('n', '1');
    formData.append('size', outputSize);
    formData.append('quality', 'low');

    // Get form data as buffer for proper fetch compatibility
    const formBuffer = formData.getBuffer();
    const formHeaders = formData.getHeaders();

    // Make the request to Azure OpenAI
    const response = await fetch(editUrl, {
      method: 'POST',
      headers: {
        'Api-Key': AZURE_OPENAI_API_KEY,
        ...formHeaders,
        'Content-Length': formBuffer.length.toString()
      },
      body: formBuffer
    });

    if (!response.ok) {
      const errorText = await response.text();
      logger.error(`[GPT-Image-1.5] Azure API error: ${response.status} - ${errorText}`);
      throw new Error(`Azure API error: ${response.status} - ${errorText}`);
    }

    const result = await response.json();
    
    logger.info(`[GPT-Image-1.5] Response received successfully`);
    logger.info(`[GPT-Image-1.5] Response data count: ${result.data?.length || 0}`);

    // Extract the generated image from the response
    if (result.data && result.data.length > 0 && result.data[0].b64_json) {
      const generatedImageBase64 = result.data[0].b64_json;
      logger.info(`[GPT-Image-1.5] Generated image base64 length: ${generatedImageBase64.length}`);
      
      return {
        type: 'image',
        content: `data:image/png;base64,${generatedImageBase64}`
      };
    } else if (result.data && result.data.length > 0 && result.data[0].url) {
      // If Azure returns a URL instead of base64, fetch it
      const imageUrl = result.data[0].url;
      logger.info(`[GPT-Image-1.5] Fetching generated image from URL: ${imageUrl}`);
      
      const imageResponse = await fetch(imageUrl);
      const imageArrayBuffer = await imageResponse.arrayBuffer();
      const imageBase64 = Buffer.from(imageArrayBuffer).toString('base64');
      
      return {
        type: 'image',
        content: `data:image/png;base64,${imageBase64}`
      };
    } else {
      logger.error(`[GPT-Image-1.5] Unexpected response structure:`, JSON.stringify(result));
      throw new Error('No image data in Azure OpenAI response');
    }
  } catch (error) {
    logger.error(`[GPT-Image-1.5] Error:`, error);
    throw error;
  }
}

// Cloud function triggered when a new user document is created
exports.onUserCreated = onDocumentCreated('users/{userId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    return;
  }
  
  const userData = snapshot.data();
  
  // Check if default fields are already set (idempotency)
  if (userData.credits !== undefined && userData.subscription !== undefined) {
    return;
  }
  
  logger.info(`Setting default credits for new user: ${event.params.userId}`);
  
  // Set default credits (3) and subscription (0 - no subscription)
  // Using set with merge to avoid overwriting other fields if they exist
  return snapshot.ref.set({
    credits: 3,
    subscription: 0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  }, { merge: true });
});

// Cloud function triggered when a new userHistory document is created
exports.processImageRequest = onDocumentCreated('userHistory/{docId}', async (event) => {
  const docId = event.params.docId;
  const docData = event.data.data();
  
  // Skip if already processed or if it's not a request
  if (docData.isDone || docData.type !== 'request') {
    return;
  }
  
  // Skip if marked for experimental processing (will be handled by processImageRequestExperimental)
  if (docData.useExperimentalModel === true) {
    logger.info(`Skipping document ${docId} - marked for experimental GPT-image-1.5 processing`);
    return;
  }
  
  logger.info(`Processing image request for document: ${docId}`);
  
  try {
    // Validate user token
    const user = await validateUserToken(docData.authToken);
    const userId = user.uid;
    
    // Get device ID from docData (client should send it)
    const deviceId = docData.deviceId;
    
    // Reject requests without a valid device ID to prevent abuse
    if (!deviceId || deviceId === 'unknown_device') {
      throw new Error('Valid device ID is required for generation requests');
    }

    // Check generation count
    const { count, limit } = await checkAndUpdateGenerationCount(userId, deviceId);
    logger.info(`User ${userId} generation count: ${count}/${limit}`);
    
    let result;
    
    if (docData.requestType === 'objectDetection') {
      // Object detection request
      let imageData;
      
      logger.info(`Processing object detection - imageData type: ${typeof docData.imageData}, starts with data: ${docData.imageData?.startsWith('data:')}`);
      
      // Handle different image data formats
      if (docData.imageData.startsWith('data:')) {
        // Data URL format
        const [header, base64Data] = docData.imageData.split(',');
        const mimeType = header.match(/data:([^;]+)/)?.[1] || 'image/jpeg';
        imageData = {
          inlineData: {
            data: base64Data,
            mimeType: mimeType
          }
        };
        logger.info(`Data URL processed - mimeType: ${mimeType}, dataLength: ${base64Data.length}`);
      } else if (docData.imageData.startsWith('http')) {
        // URL format - fetch the image
        logger.info(`Fetching image from URL: ${docData.imageData}`);
        const response = await fetch(docData.imageData);
        const arrayBuffer = await response.arrayBuffer();
        const base64Data = Buffer.from(arrayBuffer).toString('base64');
        const mimeType = response.headers.get('content-type') || 'image/jpeg';
        imageData = {
          inlineData: {
            data: base64Data,
            mimeType: mimeType
          }
        };
        logger.info(`URL image processed - mimeType: ${mimeType}, dataLength: ${base64Data.length}`);
      } else {
        // Assume it's already base64
        imageData = {
          inlineData: {
            data: docData.imageData,
            mimeType: 'image/jpeg'
          }
        };
        logger.info(`Base64 data processed - dataLength: ${docData.imageData.length}`);
      }
      
      result = await processImageWithGemini('', imageData, true);
      
      // Parse and clean the response
      let cleanResponse = result.content
        .replace(/```json\s*/gi, '')
        .replace(/```\s*/g, '')
        .replace(/^objects?:\s*/gmi, '')
        .trim();
      
      let objects = [];
      try {
        objects = JSON.parse(cleanResponse);
        if (!Array.isArray(objects)) {
          objects = Object.values(objects);
        }
      } catch (parseError) {
        // Fallback: split by common delimiters
        objects = cleanResponse
          .replace(/[\[\]{}"]/g, '')
          .split(/[,;]/)
          .map(obj => obj.trim())
          .filter(obj => obj.length > 0);
      }
      
      // Limit objects array size to prevent Firestore issues
      if (objects.length > 50) {
        objects = objects.slice(0, 50);
        logger.warn(`Objects array truncated to 50 items (was ${objects.length})`);
      }
      
      // Ensure all objects are strings and not too long
      objects = objects
        .map(obj => String(obj).substring(0, 100)) // Limit each object to 100 chars
        .filter(obj => obj.length > 0);
      
      // Update the document with results and REMOVE large data fields
      await db.collection('userHistory').doc(docId).update({
        isDone: true,
        result: {
          type: 'objectDetection',
          objects: objects
        },
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        generationCount: count,
        // Clean up large data fields to save storage and costs
        imageData: admin.firestore.FieldValue.delete(),
        authToken: admin.firestore.FieldValue.delete()
      });
      
    } else {
      // Image generation request
      let imageData;
      let originalImageUrl = null; // Track original image URL for history
      
      logger.info(`Processing image generation - imageData type: ${typeof docData.imageData}, starts with data: ${docData.imageData?.startsWith('data:')}`);
      
      // Handle different image data formats
      if (docData.imageData.startsWith('data:')) {
        // Data URL format
        const [header, base64Data] = docData.imageData.split(',');
        const mimeType = header.match(/data:([^;]+)/)?.[1] || 'image/jpeg';
        imageData = {
          inlineData: {
            data: base64Data,
            mimeType: mimeType
          }
        };
        logger.info(`Data URL processed - mimeType: ${mimeType}, dataLength: ${base64Data.length}`);
        
        // Upload original image to storage to get a URL
        const timestamp = Date.now();
        const originalFilename = `original_${timestamp}.jpg`;
        const originalBuffer = Buffer.from(base64Data, 'base64');
        originalImageUrl = await uploadToStorage(userId, originalBuffer, originalFilename);
        logger.info(`Original image uploaded to storage: ${originalImageUrl}`);
      } else if (docData.imageData.startsWith('http')) {
        // URL format - already have the URL, just fetch for processing
        originalImageUrl = docData.imageData; // Save the original URL
        logger.info(`Using existing storage URL as original: ${originalImageUrl}`);
        
        const response = await fetch(docData.imageData);
        const arrayBuffer = await response.arrayBuffer();
        const base64Data = Buffer.from(arrayBuffer).toString('base64');
        const mimeType = response.headers.get('content-type') || 'image/jpeg';
        imageData = {
          inlineData: {
            data: base64Data,
            mimeType: mimeType
          }
        };
        logger.info(`URL image processed - mimeType: ${mimeType}, dataLength: ${base64Data.length}`);
      } else {
        // Assume it's already base64
        imageData = {
          inlineData: {
            data: docData.imageData,
            mimeType: 'image/jpeg'
          }
        };
        logger.info(`Base64 data processed - dataLength: ${docData.imageData.length}`);
        
        // Upload original image to storage to get a URL
        const timestamp = Date.now();
        const originalFilename = `original_${timestamp}.jpg`;
        const originalBuffer = Buffer.from(docData.imageData, 'base64');
        originalImageUrl = await uploadToStorage(userId, originalBuffer, originalFilename);
        logger.info(`Original image uploaded to storage: ${originalImageUrl}`);
      }
      
      // Process object image if provided
      let objectImageData = null;
      if (docData.objectImageData) {
        logger.info(`Processing object image - dataLength: ${docData.objectImageData.inlineData.data.length}, mimeType: ${docData.objectImageData.inlineData.mimeType}`);
        objectImageData = docData.objectImageData;
      }
      
      result = await processImageWithGemini(docData.prompt, imageData, false, objectImageData, docId);
      
      if (result.type === 'image') {
        // Convert base64 to buffer
        const base64Data = result.content.split(',')[1];
        const imageBuffer = Buffer.from(base64Data, 'base64');
        
        // Create thumbnail
        const thumbnailBuffer = await createThumbnail(imageBuffer);
        
        // Upload full image
        const timestamp = Date.now();
        const filename = `generated_${timestamp}.jpg`;
        const thumbnailFilename = `generated_thumb_${timestamp}.jpg`;
        
        const imageUrl = await uploadToStorage(userId, imageBuffer, filename);
        const thumbnailUrl = await uploadToStorage(userId, thumbnailBuffer, thumbnailFilename);
        
        // Update the document with results and REMOVE large base64 data from Firestore
        await db.collection('userHistory').doc(docId).update({
          isDone: true,
          result: {
            type: 'imageGeneration',
            storageUrl: imageUrl,
            thumbnailUrl: thumbnailUrl,
            filename: filename,
            thumbnailFilename: thumbnailFilename
          },
          // Save the original image URL for reference
          originalImageUrl: originalImageUrl,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
          generationCount: count,
          // Clean up large data fields to save storage and costs
          imageData: admin.firestore.FieldValue.delete(),
          objectImageData: admin.firestore.FieldValue.delete(),
          authToken: admin.firestore.FieldValue.delete()
        });
      } else {
        throw new Error('No image was generated');
      }
    }
    
    logger.info(`Successfully processed request ${docId} for user ${userId}`);
    
  } catch (error) {
    logger.error(`Error processing request ${docId}:`, error);
    
    // Update document with error and clean up large data fields
    await db.collection('userHistory').doc(docId).update({
      isDone: true,
      isError: true,
      error: error.message,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      // Clean up large data fields even on error to save storage and costs
      imageData: admin.firestore.FieldValue.delete(),
      objectImageData: admin.firestore.FieldValue.delete(),
      authToken: admin.firestore.FieldValue.delete()
    });
  }
});

// EXPERIMENTAL: Cloud function triggered when a new userHistory document is created with experimental flag
// This uses Azure GPT-image-1.5 instead of Gemini for image generation
exports.processImageRequestExperimental = onDocumentCreated({
  document: 'userHistory/{docId}',
  memory: '1GiB',
  timeoutSeconds: 300,
}, async (event) => {
  const docId = event.params.docId;
  const docData = event.data.data();
  
  // Skip if already processed, not a request, or not marked for experimental processing
  if (docData.isDone || docData.type !== 'request' || !docData.useExperimentalModel) {
    return;
  }
  
  // Only handle image generation requests (not object detection)
  if (docData.requestType !== 'imageGeneration') {
    return;
  }
  
  logger.info(`[EXPERIMENTAL] Processing image request with GPT-image-1.5 for document: ${docId}`);
  
  try {
    // Validate user token
    const user = await validateUserToken(docData.authToken);
    const userId = user.uid;
    
    // Get device ID from docData
    const deviceId = docData.deviceId;
    
    // Reject requests without a valid device ID
    if (!deviceId || deviceId === 'unknown_device') {
      throw new Error('Valid device ID is required for generation requests');
    }

    // Check generation count
    const { count, limit } = await checkAndUpdateGenerationCount(userId, deviceId);
    logger.info(`[EXPERIMENTAL] User ${userId} generation count: ${count}/${limit}`);
    
    // Prepare image data
    let imageData;
    let originalImageUrl = null;
    
    logger.info(`[EXPERIMENTAL] Processing image - type: ${typeof docData.imageData}, starts with data: ${docData.imageData?.startsWith('data:')}`);
    
    // Handle different image data formats
    if (docData.imageData.startsWith('data:')) {
      // Data URL format
      const [header, base64Data] = docData.imageData.split(',');
      const mimeType = header.match(/data:([^;]+)/)?.[1] || 'image/jpeg';
      imageData = {
        inlineData: {
          data: base64Data,
          mimeType: mimeType
        }
      };
      
      // Upload original image to storage
      const timestamp = Date.now();
      const originalFilename = `original_${timestamp}.jpg`;
      const originalBuffer = Buffer.from(base64Data, 'base64');
      originalImageUrl = await uploadToStorage(userId, originalBuffer, originalFilename);
    } else if (docData.imageData.startsWith('http')) {
      // URL format
      originalImageUrl = docData.imageData;
      
      const response = await fetch(docData.imageData);
      const arrayBuffer = await response.arrayBuffer();
      const base64Data = Buffer.from(arrayBuffer).toString('base64');
      const mimeType = response.headers.get('content-type') || 'image/jpeg';
      imageData = {
        inlineData: {
          data: base64Data,
          mimeType: mimeType
        }
      };
    } else {
      // Assume it's already base64
      imageData = {
        inlineData: {
          data: docData.imageData,
          mimeType: 'image/jpeg'
        }
      };
      
      // Upload original image to storage
      const timestamp = Date.now();
      const originalFilename = `original_${timestamp}.jpg`;
      const originalBuffer = Buffer.from(docData.imageData, 'base64');
      originalImageUrl = await uploadToStorage(userId, originalBuffer, originalFilename);
    }
    
    // Process object image if provided (for inpainting)
    let objectImageData = null;
    if (docData.objectImageData) {
      logger.info(`[EXPERIMENTAL] Processing object image - dataLength: ${docData.objectImageData.inlineData.data.length}, mimeType: ${docData.objectImageData.inlineData.mimeType}`);
      objectImageData = docData.objectImageData;
    }
    
    // Process with GPT-image-1.5
    const result = await processImageWithGPTImage(docData.prompt, imageData, docId, objectImageData);
    
    if (result.type === 'image') {
      // Convert base64 to buffer
      const base64Data = result.content.split(',')[1];
      const imageBuffer = Buffer.from(base64Data, 'base64');
      
      // Create thumbnail
      const thumbnailBuffer = await createThumbnail(imageBuffer);
      
      // Upload full image
      const timestamp = Date.now();
      const filename = `generated_gpt_${timestamp}.jpg`;
      const thumbnailFilename = `generated_gpt_thumb_${timestamp}.jpg`;
      
      const imageUrl = await uploadToStorage(userId, imageBuffer, filename);
      const thumbnailUrl = await uploadToStorage(userId, thumbnailBuffer, thumbnailFilename);
      
      // Update the document with results
      await db.collection('userHistory').doc(docId).update({
        isDone: true,
        result: {
          type: 'imageGeneration',
          storageUrl: imageUrl,
          thumbnailUrl: thumbnailUrl,
          filename: filename,
          thumbnailFilename: thumbnailFilename,
          aiModel: 'gpt-image-1.5'
        },
        originalImageUrl: originalImageUrl,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        generationCount: count,
        // Clean up large data fields
        imageData: admin.firestore.FieldValue.delete(),
        objectImageData: admin.firestore.FieldValue.delete(),
        authToken: admin.firestore.FieldValue.delete()
      });
      
      logger.info(`[EXPERIMENTAL] Successfully processed request ${docId} for user ${userId} with GPT-image-1.5`);
    } else {
      throw new Error('No image was generated by GPT-image-1.5');
    }
    
  } catch (error) {
    logger.error(`[EXPERIMENTAL] Error processing request ${docId}:`, error);
    
    // Update document with error
    await db.collection('userHistory').doc(docId).update({
      isDone: true,
      isError: true,
      error: error.message,
      aiModel: 'gpt-image-1.5',
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      imageData: admin.firestore.FieldValue.delete(),
      objectImageData: admin.firestore.FieldValue.delete(),
      authToken: admin.firestore.FieldValue.delete()
    });
  }
});


// HTTP function for object detection
exports.detectObjects = onRequest({ cors: true }, async (req, res) => {
  // Set CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const { imageData, authToken, historyId, deviceId } = req.body; // Added deviceId
    
    if (!imageData || !authToken) {
      res.status(400).json({ error: 'Missing required fields: imageData, authToken' });
      return;
    }
    
    // Validate user token
    const user = await validateUserToken(authToken);
    const userId = user.uid;
    
    // Check generation count
    // Use provided deviceId - reject if not provided
    if (!deviceId || deviceId === 'unknown_device') {
      res.status(400).json({ error: 'Valid device ID is required for generation requests', success: false });
      return;
    }
    const { count, limit } = await checkAndUpdateGenerationCount(userId, deviceId);
    logger.info(`User ${userId} generation count: ${count}/${limit}`);
    
    // Process image data
    let imageDataForGemini;
    if (imageData.startsWith('data:')) {
      // Data URL format
      const [header, base64Data] = imageData.split(',');
      const mimeType = header.match(/data:([^;]+)/)?.[1] || 'image/jpeg';
      imageDataForGemini = {
        inlineData: {
          data: base64Data,
          mimeType: mimeType
        }
      };
    } else if (imageData.startsWith('http')) {
      // URL format - fetch the image
      const response = await fetch(imageData);
      const arrayBuffer = await response.arrayBuffer();
      const base64Data = Buffer.from(arrayBuffer).toString('base64');
      const mimeType = response.headers.get('content-type') || 'image/jpeg';
      imageDataForGemini = {
        inlineData: {
          data: base64Data,
          mimeType: mimeType
        }
      };
    } else {
      // Assume it's already base64
      imageDataForGemini = {
        inlineData: {
          data: imageData,
          mimeType: 'image/jpeg'
        }
      };
    }
    
    // Process with Gemini
    const result = await processImageWithGemini('', imageDataForGemini, true);
    
    // Parse and clean the response
    let cleanResponse = result.content
      .replace(/```json\s*/gi, '')
      .replace(/```\s*/g, '')
      .replace(/^objects?:\s*/gmi, '')
      .trim();
    
    logger.info(`Raw Gemini response: ${cleanResponse}`);
    
    let objects = [];
    try {
      // Try to parse as JSON first
      const parsed = JSON.parse(cleanResponse);
      if (Array.isArray(parsed)) {
        objects = parsed;
      } else if (typeof parsed === 'object' && parsed !== null) {
        objects = Object.values(parsed);
      } else {
        throw new Error('Not a valid array or object');
      }
    } catch (parseError) {
      logger.info(`JSON parse failed, trying fallback parsing: ${parseError.message}`);
      logger.info(`Clean response for fallback: "${cleanResponse}"`);
      // Fallback: split by common delimiters
      objects = cleanResponse
        .replace(/[\[\]{}"]/g, '')
        .split(/[,;]/)
        .map(obj => obj.trim())
        .filter(obj => obj.length > 0);
      logger.info(`Fallback parsing result: ${JSON.stringify(objects)}`);
    }
    
    logger.info(`Parsed objects: ${JSON.stringify(objects)}`);
    
    // Limit objects array size to prevent issues
    if (objects.length > 50) {
      objects = objects.slice(0, 50);
    }
    
    // Ensure all objects are strings and not too long
    objects = objects
      .map(obj => String(obj).substring(0, 100))
      .filter(obj => obj.length > 0);
    
    if (historyId) {
      // Update existing record with object detection results
      await db.collection('userHistory').doc(historyId).update({
        objects: objects,
        objectDetectionCompletedAt: new Date(),
        generationCount: count
      });
      
      res.json({
        success: true,
        objects: objects,
        historyId: historyId,
        generationCount: count
      });
    } else {
      // Object detection requires an existing history record
      res.status(400).json({
        success: false,
        error: 'Object detection requires an existing history record. Please select an image from your history first.'
      });
    }
    
  } catch (error) {
    logger.error('Object detection error:', error);
    res.status(500).json({ 
      error: error.message || 'Object detection failed',
      success: false 
    });
  }
});

// HTTP function for speech-to-text using Gemini
exports.speechToText = onRequest({ cors: true }, async (req, res) => {
  // Set CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const { audioData, authToken } = req.body;
    
    if (!audioData || !authToken) {
      res.status(400).json({ error: 'Missing required fields: audioData, authToken' });
      return;
    }
    
    // Validate user token
    const user = await validateUserToken(authToken);
    const userId = user.uid;
    
    logger.info(`Processing speech-to-text for user: ${userId}`);
    
    // Process audio data with Gemini
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    
    // Convert audio data to the format expected by Gemini
    let audioDataForGemini;
    if (audioData.startsWith('data:')) {
      // Data URL format
      const [header, base64Data] = audioData.split(',');
      const mimeType = header.match(/data:([^;]+)/)?.[1] || 'audio/wav';
      audioDataForGemini = {
        inlineData: {
          data: base64Data,
          mimeType: mimeType
        }
      };
    } else {
      // Assume it's already base64
      audioDataForGemini = {
        inlineData: {
          data: audioData,
          mimeType: 'audio/wav'
        }
      };
    }
    
    logger.info(`Audio data size: ${audioDataForGemini.inlineData.data.length} characters`);
    
    // Create prompt for Hebrew speech recognition
    const prompt = `Transcribe the following audio to text. The audio is in Hebrew language. Return only the transcribed text in Hebrew, nothing else. Do not translate to English, keep it in Hebrew.`;
    
    const result = await model.generateContent([prompt, audioDataForGemini]);
    const transcribedText = result.response.text().trim();
    
    logger.info(`Speech-to-text result: ${transcribedText}`);
    
    res.json({
      success: true,
      text: transcribedText,
      userId: userId
    });
    
  } catch (error) {
    logger.error('Speech-to-text error:', error);
    res.status(500).json({ 
      error: error.message || 'Speech-to-text failed',
      success: false 
    });
  }
});

// HTTP function for health check
exports.healthCheck = onRequest({ cors: true }, (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// HTTP function for payment webhook
exports.paymentWebhook = onRequest({ cors: true }, async (req, res) => {
  // Set CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const webhookData = req.body;
    
    logger.info('Received payment webhook:', JSON.stringify(webhookData));
    
    // Create a new document in the paymentEvents collection
    const timestamp = Date.now();
    const eventId = `event_${timestamp}`;
    
    await db.collection('paymentEvents').doc(eventId).set({
      ...webhookData,
      receivedAt: admin.firestore.FieldValue.serverTimestamp(),
      eventId: eventId
    });
    
    logger.info(`Payment event saved with ID: ${eventId}`);
    
    // Handle subscription update if success
    if (webhookData.status == "1" && webhookData.data && webhookData.data.payerEmail && webhookData.err == "") {
      const payerEmail = webhookData.data.payerEmail;
      const description = webhookData.data.description || '';
      
      logger.info(`Processing subscription for email: ${payerEmail}, plan: ${description}`);
      
      // Find user by email
      // Note: 'users' collection usually indexed by UID. We need to query by email field.
      // This assumes 'email' field is maintained on user documents.
      const usersRef = db.collection('users');
      const querySnapshot = await usersRef.where('email', '==', payerEmail).limit(1).get();
      
      if (!querySnapshot.empty) {
        const userDoc = querySnapshot.docs[0];
        const userId = userDoc.id;
        
        let newSubscription = 0;
        let newCredits = 4;
        
        // Map description to subscription code and credits
        if (description.includes('moomhe_monthly_starter')) {
          newSubscription = 1;
          newCredits = 50;
        } else if (description.includes('moomhe_monthly_budget')) {
          newSubscription = 2;
          newCredits = 200;
        } else if (description.includes('moomhe_monthly_pro')) {
          newSubscription = 3;
          newCredits = 450;
        }
        
        if (newSubscription > 0) {
          await userDoc.ref.update({
            subscription: newSubscription,
            credits: newCredits,
            lastPaymentEvent: eventId,
            subscriptionPlatform: 'web', // Mark as web payment so sync won't reset it
            subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
          });
          
          // Reset monthly usage counter (trial counts shouldn't count against new subscription)
          const now = new Date();
          const monthYear = `${String(now.getMonth() + 1).padStart(2, '0')}-${now.getFullYear()}`;
          await db.collection('genCount').doc(monthYear).collection('users').doc(userId).set({
            count: 0,
            resetAt: admin.firestore.FieldValue.serverTimestamp(),
            resetReason: 'new_subscription_web_payment',
          }, { merge: true });
          
          logger.info(`Updated user ${userId} subscription to ${newSubscription}, credits: ${newCredits}, reset genCount`);
        } else {
          logger.warn(`Unknown subscription description: ${description}`);
        }
      } else {
        logger.warn(`No user found with email: ${payerEmail}`);
      }
    }
    
    res.json({
      success: true,
      eventId: eventId,
      message: 'Payment event received and processed'
    });
    
  } catch (error) {
    logger.error('Payment webhook error:', error);
    res.status(500).json({ 
      error: error.message || 'Failed to process payment webhook',
      success: false 
    });
  }
});

// Cloud function triggered when a user document is updated
// Checks if email was set/changed and links any existing payment events
exports.onUserEmailUpdate = onDocumentUpdated('users/{userId}', async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();
  
  // Check if email field was added or changed
  const beforeEmail = beforeData?.email;
  const afterEmail = afterData?.email;
  
  // Only proceed if email was added or changed
  if (!afterEmail || beforeEmail === afterEmail) {
    return;
  }
  
  logger.info(`[onUserEmailUpdate] User ${event.params.userId}: Email updated from "${beforeEmail}" to "${afterEmail}"`);
  
  try {
    // Find payment events where data.payerEmail matches the user's email
    const paymentEventsRef = db.collection('paymentEvents');
    
    let querySnapshot;
    try {
      // Try with orderBy first (requires composite index)
      querySnapshot = await paymentEventsRef
        .where('data.payerEmail', '==', afterEmail)
        .orderBy('receivedAt', 'desc')
        .limit(1)
        .get();
    } catch (indexError) {
      // If index doesn't exist yet, fallback to query without orderBy
      logger.warn(`[onUserEmailUpdate] Index query failed, falling back to simple query: ${indexError.message}`);
      querySnapshot = await paymentEventsRef
        .where('data.payerEmail', '==', afterEmail)
        .limit(10)
        .get();
      
      // If we got results, sort manually to get the most recent
      if (!querySnapshot.empty) {
        const docs = querySnapshot.docs.sort((a, b) => {
          const aTime = a.data().receivedAt?.toMillis() || 0;
          const bTime = b.data().receivedAt?.toMillis() || 0;
          return bTime - aTime;
        });
        querySnapshot = { empty: false, docs: [docs[0]] };
      }
    }
    
    if (querySnapshot.empty) {
      logger.info(`[onUserEmailUpdate] No payment events found for email: ${afterEmail}`);
      return;
    }
    
    const paymentDoc = querySnapshot.docs[0];
    const paymentData = paymentDoc.data();
    
    logger.info(`[onUserEmailUpdate] Found payment event ${paymentDoc.id} for email ${afterEmail}`);
    logger.info(`[onUserEmailUpdate] Payment data: status=${paymentData.status}, err="${paymentData.err}", description="${paymentData.data?.description}"`);
    
    // Check if status is "1" (successful payment) and no error
    if (paymentData.status == "1" && paymentData.err === "") {
      const description = paymentData.data?.description || '';
      
      let newSubscription = 0;
      let newCredits = 4;
      
      // Map description to subscription code and credits (same logic as paymentWebhook)
      if (description.includes('moomhe_monthly_starter')) {
        newSubscription = 1;
        newCredits = 50;
      } else if (description.includes('moomhe_monthly_budget')) {
        newSubscription = 2;
        newCredits = 200;
      } else if (description.includes('moomhe_monthly_pro')) {
        newSubscription = 3;
        newCredits = 450;
      }
      
      if (newSubscription > 0) {
        // Check if user already has a subscription from this payment
        if (afterData.lastPaymentEvent === paymentDoc.id) {
          logger.info(`[onUserEmailUpdate] User ${event.params.userId} already processed payment ${paymentDoc.id}, skipping`);
          return;
        }
        
        // Check if user already has a subscription (don't downgrade)
        if (afterData.subscription && afterData.subscription >= newSubscription) {
          logger.info(`[onUserEmailUpdate] User ${event.params.userId} already has subscription ${afterData.subscription}, not overwriting with ${newSubscription}`);
          return;
        }
        
        await event.data.after.ref.update({
          subscription: newSubscription,
          credits: newCredits,
          lastPaymentEvent: paymentDoc.id,
          subscriptionPlatform: 'web', // Mark as web payment so sync won't reset it
          subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        // Reset monthly usage counter (trial counts shouldn't count against new subscription)
        const now = new Date();
        const monthYear = `${String(now.getMonth() + 1).padStart(2, '0')}-${now.getFullYear()}`;
        await db.collection('genCount').doc(monthYear).collection('users').doc(event.params.userId).set({
          count: 0,
          resetAt: admin.firestore.FieldValue.serverTimestamp(),
          resetReason: 'new_subscription_email_link',
        }, { merge: true });

        logger.info(`[onUserEmailUpdate] SUCCESS: Granted subscription ${newSubscription} (${newCredits} credits) to user ${event.params.userId} from payment event ${paymentDoc.id}, reset genCount`);
      } else {
        logger.warn(`[onUserEmailUpdate] Unknown subscription description for email ${afterEmail}: "${description}"`);
      }
    } else {
      logger.info(`[onUserEmailUpdate] Payment event ${paymentDoc.id} not valid: status=${paymentData.status}, err="${paymentData.err}"`);
    }
  } catch (error) {
    logger.error(`[onUserEmailUpdate] Error processing email update for user ${event.params.userId}:`, error);
    throw error;
  }
});

// HTTP function for redeeming coupon codes
exports.redeemCoupon = onRequest({ cors: true }, async (req, res) => {
  // Set CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const { couponCode, authToken, deviceId } = req.body;
    
    if (!couponCode || !authToken || !deviceId) {
      res.status(400).json({ 
        success: false, 
        error: 'Missing required fields: couponCode, authToken, deviceId',
        errorCode: 'MISSING_FIELDS'
      });
      return;
    }
    
    // Validate user token
    const user = await validateUserToken(authToken);
    const userId = user.uid;
    
    logger.info(`[redeemCoupon] User ${userId} attempting to redeem coupon: ${couponCode}`);
    
    // Check if coupon exists
    const couponRef = db.collection('coupons').doc(couponCode.toUpperCase());
    const couponDoc = await couponRef.get();
    
    if (!couponDoc.exists) {
      logger.info(`[redeemCoupon] Coupon not found: ${couponCode}`);
      res.status(400).json({ 
        success: false, 
        error: 'קוד הקופון אינו קיים',
        errorCode: 'COUPON_NOT_FOUND'
      });
      return;
    }
    
    const couponData = couponDoc.data();
    
    // Check if coupon is active
    if (couponData.active === false) {
      logger.info(`[redeemCoupon] Coupon is inactive: ${couponCode}`);
      res.status(400).json({ 
        success: false, 
        error: 'קוד הקופון אינו פעיל',
        errorCode: 'COUPON_INACTIVE'
      });
      return;
    }
    
    // Check if coupon has expired
    if (couponData.expiresAt && couponData.expiresAt.toDate() < new Date()) {
      logger.info(`[redeemCoupon] Coupon has expired: ${couponCode}`);
      res.status(400).json({ 
        success: false, 
        error: 'קוד הקופון פג תוקף',
        errorCode: 'COUPON_EXPIRED'
      });
      return;
    }
    
    // Check if max redemptions reached
    if (couponData.maxRedemptions && couponData.redemptionCount >= couponData.maxRedemptions) {
      logger.info(`[redeemCoupon] Coupon max redemptions reached: ${couponCode}`);
      res.status(400).json({ 
        success: false, 
        error: 'קוד הקופון מוצה',
        errorCode: 'COUPON_MAX_REACHED'
      });
      return;
    }
    
    // Get credits from coupon (default 10) - this will SET the user's credits, not add to them
    const couponCredits = couponData.credits || 10;
    
    // Check if device already redeemed this coupon
    const redemptionRef = db.collection('couponRedemptions').doc(`${couponCode.toUpperCase()}_${deviceId}`);
    const redemptionDoc = await redemptionRef.get();
    
    if (redemptionDoc.exists) {
      logger.info(`[redeemCoupon] Device ${deviceId} already redeemed coupon: ${couponCode}`);
      res.status(400).json({ 
        success: false, 
        error: 'כבר מימשת את הקופון הזה',
        errorCode: 'ALREADY_REDEEMED'
      });
      return;
    }
    
    // Also check if user already redeemed this coupon (double protection)
    const userRedemptionRef = db.collection('couponRedemptions').doc(`${couponCode.toUpperCase()}_user_${userId}`);
    const userRedemptionDoc = await userRedemptionRef.get();
    
    if (userRedemptionDoc.exists) {
      logger.info(`[redeemCoupon] User ${userId} already redeemed coupon: ${couponCode}`);
      res.status(400).json({ 
        success: false, 
        error: 'כבר מימשת את הקופון הזה',
        errorCode: 'ALREADY_REDEEMED'
      });
      return;
    }
    
    // Get user document to update credits
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      res.status(400).json({ 
        success: false, 
        error: 'משתמש לא נמצא',
        errorCode: 'USER_NOT_FOUND'
      });
      return;
    }
    
    // Set credits directly to the coupon value (not adding to existing)
    const newCredits = couponCredits;
    
    // Perform the redemption in a batch
    const batch = db.batch();
    
    // Update user credits
    batch.update(userRef, {
      credits: newCredits,
      lastCouponRedeemed: couponCode.toUpperCase(),
      lastCouponRedeemedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Record device redemption
    batch.set(redemptionRef, {
      couponCode: couponCode.toUpperCase(),
      deviceId: deviceId,
      userId: userId,
      creditsSet: couponCredits,
      redeemedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Record user redemption
    batch.set(userRedemptionRef, {
      couponCode: couponCode.toUpperCase(),
      deviceId: deviceId,
      userId: userId,
      creditsSet: couponCredits,
      redeemedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Increment coupon redemption count
    batch.update(couponRef, {
      redemptionCount: admin.firestore.FieldValue.increment(1),
      lastRedeemedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    await batch.commit();
    
    logger.info(`[redeemCoupon] SUCCESS: User ${userId} redeemed coupon ${couponCode}. Credits set to: ${newCredits}`);
    
    res.json({
      success: true,
      credits: couponCredits,
      newCredits: newCredits,
      message: `הקרדיטים שלך עודכנו ל-${couponCredits}!`
    });
    
  } catch (error) {
    logger.error('[redeemCoupon] Error:', error);
    res.status(500).json({ 
      success: false,
      error: error.message || 'שגיאה במימוש הקופון',
      errorCode: 'SERVER_ERROR'
    });
  }
});

// ===========================================
// Google Play In-App Purchase Webhook
// ===========================================
// This endpoint receives Real-Time Developer Notifications (RTDN) from Google Play
// Configure in Google Play Console: Monetization > Monetization setup > Real-time developer notifications
exports.googlePlayWebhook = onRequest({ cors: true }, async (req, res) => {
  // Set CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    // Google Cloud Pub/Sub sends the message in a specific format
    const message = req.body.message;
    if (!message || !message.data) {
      logger.warn('[googlePlayWebhook] No message data received');
      res.status(400).json({ error: 'No message data' });
      return;
    }
    
    // Decode base64 message data
    const decodedData = Buffer.from(message.data, 'base64').toString('utf-8');
    const notification = JSON.parse(decodedData);
    
    logger.info('[googlePlayWebhook] Received notification:', JSON.stringify(notification));
    
    // Store the raw notification for debugging
    const notificationId = `gp_${Date.now()}`;
    await db.collection('iapNotifications').doc(notificationId).set({
      platform: 'google_play',
      rawNotification: notification,
      receivedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    // Handle subscription notifications
    if (notification.subscriptionNotification) {
      const subNotification = notification.subscriptionNotification;
      const purchaseToken = subNotification.purchaseToken;
      const notificationType = subNotification.notificationType;
      
      logger.info(`[googlePlayWebhook] Subscription notification type: ${notificationType}`);
      
      // Find the purchase record in Firestore by purchase token
      const purchasesRef = db.collection('purchases');
      const purchaseQuery = await purchasesRef
        .where('verificationData', '==', purchaseToken)
        .where('platform', '==', 'android')
        .limit(1)
        .get();
      
      if (purchaseQuery.empty) {
        logger.warn(`[googlePlayWebhook] No purchase found for token: ${purchaseToken.substring(0, 20)}...`);
        // Still acknowledge the message to prevent retries
        res.status(200).json({ success: true, message: 'No matching purchase found' });
        return;
      }
      
      const purchaseDoc = purchaseQuery.docs[0];
      const purchaseData = purchaseDoc.data();
      const userId = purchaseData.userId;
      const productId = purchaseData.productId;
      
      logger.info(`[googlePlayWebhook] Found purchase for user: ${userId}, product: ${productId}`);
      
      // Get product configuration
      const productConfig = PRODUCT_CREDITS[productId];
      if (!productConfig) {
        logger.warn(`[googlePlayWebhook] Unknown product: ${productId}`);
        res.status(200).json({ success: true, message: 'Unknown product' });
        return;
      }
      
      // Handle different notification types
      // See: https://developer.android.com/google/play/billing/rtdn-reference
      switch (notificationType) {
        case 1: // SUBSCRIPTION_RECOVERED - Subscription restored from account hold
        case 2: // SUBSCRIPTION_RENEWED - Subscription renewed
        case 4: // SUBSCRIPTION_PURCHASED - New subscription purchased
        case 7: // SUBSCRIPTION_RESTARTED - Subscription restarted
          // Grant/renew subscription credits
          await db.collection('users').doc(userId).update({
            subscription: productConfig.subscription,
            credits: productConfig.credits,
            subscriptionProductId: productId,
            subscriptionPlatform: 'android',
            subscriptionVerified: true,
            subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            lastIapNotification: notificationId,
          });
          
          // Mark purchase as verified
          await purchaseDoc.ref.update({
            verified: true,
            verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
            lastNotificationType: notificationType,
          });
          
          // Reset monthly usage counter
          const now = new Date();
          const monthYear = `${String(now.getMonth() + 1).padStart(2, '0')}-${now.getFullYear()}`;
          await db.collection('genCount').doc(monthYear).collection('users').doc(userId).set({
            count: 0,
            resetAt: admin.firestore.FieldValue.serverTimestamp(),
          }, { merge: true });
          
          logger.info(`[googlePlayWebhook] Granted subscription ${productConfig.subscription} to user ${userId}`);
          break;
          
        case 3: // SUBSCRIPTION_CANCELED - Subscription canceled by user
          // Mark subscription as canceled but don't remove yet (access until end of period)
          await db.collection('users').doc(userId).update({
            subscriptionCanceled: true,
            subscriptionCanceledAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          logger.info(`[googlePlayWebhook] Marked subscription as canceled for user ${userId}`);
          break;
          
        case 5: // SUBSCRIPTION_ON_HOLD - Subscription in grace period
        case 6: // SUBSCRIPTION_IN_GRACE_PERIOD - Payment failed, in grace period
          // User still has access during grace period
          await db.collection('users').doc(userId).update({
            subscriptionGracePeriod: true,
            subscriptionGracePeriodAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          logger.info(`[googlePlayWebhook] Subscription in grace period for user ${userId}`);
          break;
          
        case 10: // SUBSCRIPTION_PAUSED - Subscription paused
          await db.collection('users').doc(userId).update({
            subscriptionPaused: true,
            subscriptionPausedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          logger.info(`[googlePlayWebhook] Subscription paused for user ${userId}`);
          break;
          
        case 11: // SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED
          // Just log, no action needed
          logger.info(`[googlePlayWebhook] Pause schedule changed for user ${userId}`);
          break;
          
        case 12: // SUBSCRIPTION_REVOKED - Subscription revoked (refund, etc.)
        case 13: // SUBSCRIPTION_EXPIRED - Subscription expired
          // Remove subscription access
          await db.collection('users').doc(userId).update({
            subscription: 0,
            credits: 3, // Reset to free tier
            subscriptionProductId: null,
            subscriptionExpired: true,
            subscriptionExpiredAt: admin.firestore.FieldValue.serverTimestamp(),
            subscriptionVerified: false,
            subscriptionPaused: admin.firestore.FieldValue.delete(),
            subscriptionGracePeriod: admin.firestore.FieldValue.delete(),
            subscriptionCanceled: admin.firestore.FieldValue.delete(),
          });
          logger.info(`[googlePlayWebhook] Revoked subscription for user ${userId}`);
          break;
          
        default:
          logger.info(`[googlePlayWebhook] Unhandled notification type: ${notificationType}`);
      }
    }
    
    // Acknowledge the message
    res.status(200).json({ success: true });
    
  } catch (error) {
    logger.error('[googlePlayWebhook] Error:', error);
    // Still return 200 to acknowledge the message and prevent retries
    res.status(200).json({ success: false, error: error.message });
  }
});

// ===========================================
// Apple App Store In-App Purchase Webhook
// ===========================================
// This endpoint receives App Store Server Notifications V2
// Configure in App Store Connect: App > App Store Server Notifications
exports.appStoreWebhook = onRequest({ cors: true }, async (req, res) => {
  // Set CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const { signedPayload } = req.body;
    
    if (!signedPayload) {
      logger.warn('[appStoreWebhook] No signedPayload received');
      res.status(400).json({ error: 'No signedPayload' });
      return;
    }
    
    // App Store Server Notifications V2 sends JWS (JSON Web Signature) format
    // The payload is a JWT with 3 parts: header.payload.signature
    // For production, you should verify the signature using Apple's public key
    // For now, we'll decode and process the payload
    
    const parts = signedPayload.split('.');
    if (parts.length !== 3) {
      logger.warn('[appStoreWebhook] Invalid JWS format');
      res.status(400).json({ error: 'Invalid JWS format' });
      return;
    }
    
    // Decode the payload (base64url)
    const payloadBase64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
    const payloadJson = Buffer.from(payloadBase64, 'base64').toString('utf-8');
    const notification = JSON.parse(payloadJson);
    
    logger.info('[appStoreWebhook] Received notification:', JSON.stringify(notification));
    
    // Store the raw notification for debugging
    const notificationId = `as_${Date.now()}`;
    await db.collection('iapNotifications').doc(notificationId).set({
      platform: 'app_store',
      rawNotification: notification,
      signedPayloadPreview: signedPayload.substring(0, 100) + '...',
      receivedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    const notificationType = notification.notificationType;
    const subtype = notification.subtype;
    const data = notification.data;
    
    if (!data) {
      logger.warn('[appStoreWebhook] No data in notification');
      res.status(200).json({ success: true, message: 'No data' });
      return;
    }
    
    // Decode the transaction info (also JWS format)
    let transactionInfo = null;
    if (data.signedTransactionInfo) {
      const txParts = data.signedTransactionInfo.split('.');
      if (txParts.length === 3) {
        const txPayloadBase64 = txParts[1].replace(/-/g, '+').replace(/_/g, '/');
        const txPayloadJson = Buffer.from(txPayloadBase64, 'base64').toString('utf-8');
        transactionInfo = JSON.parse(txPayloadJson);
        logger.info('[appStoreWebhook] Transaction info:', JSON.stringify(transactionInfo));
      }
    }
    
    // Decode renewal info if present
    let renewalInfo = null;
    if (data.signedRenewalInfo) {
      const renewParts = data.signedRenewalInfo.split('.');
      if (renewParts.length === 3) {
        const renewPayloadBase64 = renewParts[1].replace(/-/g, '+').replace(/_/g, '/');
        const renewPayloadJson = Buffer.from(renewPayloadBase64, 'base64').toString('utf-8');
        renewalInfo = JSON.parse(renewPayloadJson);
        logger.info('[appStoreWebhook] Renewal info:', JSON.stringify(renewalInfo));
      }
    }
    
    if (!transactionInfo) {
      logger.warn('[appStoreWebhook] Could not decode transaction info');
      res.status(200).json({ success: true, message: 'No transaction info' });
      return;
    }
    
    const originalTransactionId = transactionInfo.originalTransactionId;
    const transactionId = transactionInfo.transactionId;
    const productId = transactionInfo.productId;
    const appAccountToken = transactionInfo.appAccountToken; // This should be the UUID we passed
    
    logger.info(`[appStoreWebhook] Looking up user - appAccountToken: ${appAccountToken}, originalTransactionId: ${originalTransactionId}`);
    
    // Find user by multiple methods
    let userId = null;
    
    // Method 1: Look up appAccountToken (UUID) in users collection
    // appAccountToken is a UUID v5 derived from Firebase UID, stored in user's appleUuid field
    if (appAccountToken) {
      const usersRef = db.collection('users');
      const userQuery = await usersRef.where('appleUuid', '==', appAccountToken).limit(1).get();
      if (!userQuery.empty) {
        userId = userQuery.docs[0].id;
        logger.info(`[appStoreWebhook] Found user via appleUuid: ${userId}`);
      } else {
        logger.info(`[appStoreWebhook] No user found with appleUuid: ${appAccountToken}`);
      }
    }
    
    // Method 2: Try to find by transaction ID in purchases collection
    if (!userId) {
      const purchasesRef = db.collection('purchases');
      
      // Try both transactionId and originalTransactionId
      const purchaseQueries = await Promise.all([
        purchasesRef.where('purchaseId', '==', originalTransactionId).where('platform', '==', 'ios').limit(1).get(),
        purchasesRef.where('purchaseId', '==', transactionId).where('platform', '==', 'ios').limit(1).get(),
        purchasesRef.where('originalTransactionId', '==', originalTransactionId).where('platform', '==', 'ios').limit(1).get(),
      ]);
      
      for (const query of purchaseQueries) {
        if (!query.empty) {
          userId = query.docs[0].data().userId;
          logger.info(`[appStoreWebhook] Found user via purchases collection: ${userId}`);
          break;
        }
      }
    }
    
    // Method 3: Check pending notifications that were stored earlier
    if (!userId) {
      const pendingRef = db.collection('pendingIapNotifications').doc(originalTransactionId);
      const pendingDoc = await pendingRef.get();
      if (pendingDoc.exists) {
        userId = pendingDoc.data().userId;
        logger.info(`[appStoreWebhook] Found user via pending notification: ${userId}`);
      }
    }
    
    if (!userId) {
      logger.warn(`[appStoreWebhook] Could not determine user for transaction: ${originalTransactionId}`);
      
      // Store this notification for later processing when the purchase is verified by client
      // The verifyPurchase endpoint will check this and process it
      await db.collection('pendingIapNotifications').doc(originalTransactionId).set({
        notificationType,
        subtype,
        transactionInfo,
        renewalInfo,
        notificationId,
        receivedAt: admin.firestore.FieldValue.serverTimestamp(),
        processed: false,
      });
      logger.info(`[appStoreWebhook] Stored pending notification for later processing: ${originalTransactionId}`);
      
      res.status(200).json({ success: true, message: 'User not found, stored for later' });
      return;
    }
    
    logger.info(`[appStoreWebhook] Processing for user: ${userId}, product: ${productId}`);
    
    // Get product configuration
    const productConfig = PRODUCT_CREDITS[productId];
    if (!productConfig) {
      logger.warn(`[appStoreWebhook] Unknown product: ${productId}`);
      res.status(200).json({ success: true, message: 'Unknown product' });
      return;
    }
    
    // Handle different notification types
    // See: https://developer.apple.com/documentation/appstoreservernotifications/notificationtype
    switch (notificationType) {
      case 'SUBSCRIBED':
        // New subscription or resubscription
        await db.collection('users').doc(userId).update({
          subscription: productConfig.subscription,
          credits: productConfig.credits,
          subscriptionProductId: productId,
          subscriptionPlatform: 'ios',
          subscriptionVerified: true,
          subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
          lastIapNotification: notificationId,
        });
        
        // Reset monthly usage counter
        const now = new Date();
        const monthYear = `${String(now.getMonth() + 1).padStart(2, '0')}-${now.getFullYear()}`;
        await db.collection('genCount').doc(monthYear).collection('users').doc(userId).set({
          count: 0,
          resetAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        
        logger.info(`[appStoreWebhook] Granted subscription ${productConfig.subscription} to user ${userId}`);
        break;
        
      case 'DID_RENEW':
        // Subscription renewed successfully
        await db.collection('users').doc(userId).update({
          subscription: productConfig.subscription,
          credits: productConfig.credits,
          subscriptionVerified: true,
          subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
          subscriptionGracePeriod: admin.firestore.FieldValue.delete(),
          subscriptionBillingRetry: admin.firestore.FieldValue.delete(),
        });
        
        // Reset monthly usage counter
        const renewNow = new Date();
        const renewMonthYear = `${String(renewNow.getMonth() + 1).padStart(2, '0')}-${renewNow.getFullYear()}`;
        await db.collection('genCount').doc(renewMonthYear).collection('users').doc(userId).set({
          count: 0,
          resetAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        
        logger.info(`[appStoreWebhook] Renewed subscription for user ${userId}`);
        break;
        
      case 'DID_CHANGE_RENEWAL_STATUS':
        // User changed auto-renewal status
        if (subtype === 'AUTO_RENEW_DISABLED') {
          await db.collection('users').doc(userId).update({
            subscriptionCanceled: true,
            subscriptionCanceledAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          logger.info(`[appStoreWebhook] User ${userId} disabled auto-renew`);
        } else if (subtype === 'AUTO_RENEW_ENABLED') {
          await db.collection('users').doc(userId).update({
            subscriptionCanceled: admin.firestore.FieldValue.delete(),
          });
          logger.info(`[appStoreWebhook] User ${userId} enabled auto-renew`);
        }
        break;
        
      case 'GRACE_PERIOD_EXPIRED':
      case 'EXPIRED':
        // Subscription expired
        await db.collection('users').doc(userId).update({
          subscription: 0,
          credits: 3, // Reset to free tier
          subscriptionProductId: null,
          subscriptionExpired: true,
          subscriptionExpiredAt: admin.firestore.FieldValue.serverTimestamp(),
          subscriptionVerified: false,
          subscriptionGracePeriod: admin.firestore.FieldValue.delete(),
          subscriptionCanceled: admin.firestore.FieldValue.delete(),
        });
        logger.info(`[appStoreWebhook] Expired subscription for user ${userId}`);
        break;
        
      case 'DID_FAIL_TO_RENEW':
        // Billing retry period started
        await db.collection('users').doc(userId).update({
          subscriptionBillingRetry: true,
          subscriptionBillingRetryAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        logger.info(`[appStoreWebhook] Billing retry started for user ${userId}`);
        break;
        
      case 'REFUND':
        // User was refunded
        await db.collection('users').doc(userId).update({
          subscription: 0,
          credits: 3,
          subscriptionProductId: null,
          subscriptionRefunded: true,
          subscriptionRefundedAt: admin.firestore.FieldValue.serverTimestamp(),
          subscriptionVerified: false,
        });
        logger.info(`[appStoreWebhook] Refunded subscription for user ${userId}`);
        break;
        
      case 'REVOKE':
        // Family sharing revoked or other revocation
        await db.collection('users').doc(userId).update({
          subscription: 0,
          credits: 3,
          subscriptionProductId: null,
          subscriptionRevoked: true,
          subscriptionRevokedAt: admin.firestore.FieldValue.serverTimestamp(),
          subscriptionVerified: false,
        });
        logger.info(`[appStoreWebhook] Revoked subscription for user ${userId}`);
        break;
        
      default:
        logger.info(`[appStoreWebhook] Unhandled notification type: ${notificationType} (subtype: ${subtype})`);
    }
    
    // App Store expects a 200 response
    res.status(200).json({ success: true });
    
  } catch (error) {
    logger.error('[appStoreWebhook] Error:', error);
    // Still return 200 to prevent retries
    res.status(200).json({ success: false, error: error.message });
  }
});

// ===========================================
// Verify Purchase Endpoint (Client-initiated)
// ===========================================
// Called by the app after a purchase to verify and sync state
exports.verifyPurchase = onRequest({ cors: true }, async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const { authToken, productId, purchaseId, platform, verificationData, originalTransactionId } = req.body;
    
    if (!authToken || !productId || !purchaseId || !platform) {
      res.status(400).json({ 
        success: false, 
        error: 'Missing required fields' 
      });
      return;
    }
    
    // Validate user token
    const user = await validateUserToken(authToken);
    const userId = user.uid;
    
    logger.info(`[verifyPurchase] User ${userId} verifying ${productId} on ${platform}`);
    logger.info(`[verifyPurchase] purchaseId: ${purchaseId}, originalTransactionId: ${originalTransactionId || 'not provided'}`);
    
    // Get product configuration
    const productConfig = PRODUCT_CREDITS[productId];
    if (!productConfig) {
      res.status(400).json({ success: false, error: 'Unknown product' });
      return;
    }
    
    // Store/update purchase record with originalTransactionId for webhook lookup
    const purchaseData = {
      userId,
      productId,
      purchaseId,
      platform,
      verificationData,
      verified: true,
      verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    
    // For iOS, also store originalTransactionId for webhook lookup
    if (platform === 'ios' && originalTransactionId) {
      purchaseData.originalTransactionId = originalTransactionId;
    }
    
    await db.collection('purchases').doc(purchaseId).set(purchaseData, { merge: true });
    
    // Also store by originalTransactionId if different from purchaseId (for webhook lookup)
    if (platform === 'ios' && originalTransactionId && originalTransactionId !== purchaseId) {
      await db.collection('purchases').doc(originalTransactionId).set({
        ...purchaseData,
        purchaseId: originalTransactionId, // Use originalTransactionId as the doc ID
        linkedPurchaseId: purchaseId, // Reference to the main purchase doc
      }, { merge: true });
      logger.info(`[verifyPurchase] Also stored purchase by originalTransactionId: ${originalTransactionId}`);
    }
    
    // Check if user already has the same subscription (this is a restore, not new purchase)
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data() || {};
    const currentSubscription = userData.subscription || 0;
    const currentProductId = userData.subscriptionProductId;
    
    const isRestore = currentSubscription === productConfig.subscription && currentProductId === productId;
    
    // Update user subscription
    await db.collection('users').doc(userId).update({
      subscription: productConfig.subscription,
      credits: productConfig.credits,
      subscriptionProductId: productId,
      subscriptionPlatform: platform,
      subscriptionVerified: true,
      subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastPurchaseId: purchaseId,
    });
    
    // Only reset monthly usage counter for NEW subscriptions, not restores
    if (!isRestore) {
      const now = new Date();
      const monthYear = `${String(now.getMonth() + 1).padStart(2, '0')}-${now.getFullYear()}`;
      await db.collection('genCount').doc(monthYear).collection('users').doc(userId).set({
        count: 0,
        resetAt: admin.firestore.FieldValue.serverTimestamp(),
        resetReason: 'new_subscription_verified',
      }, { merge: true });
      logger.info(`[verifyPurchase] Reset genCount for new subscription`);
    } else {
      logger.info(`[verifyPurchase] Skipped genCount reset - this is a restore of existing subscription`);
    }
    
    // Check for pending notifications that arrived before this verification
    // Process them now that we have the user mapping
    if (platform === 'ios') {
      const transactionIdToCheck = originalTransactionId || purchaseId;
      const pendingRef = db.collection('pendingIapNotifications').doc(transactionIdToCheck);
      const pendingDoc = await pendingRef.get();
      
      if (pendingDoc.exists && !pendingDoc.data().processed) {
        logger.info(`[verifyPurchase] Found pending notification for ${transactionIdToCheck}, processing now...`);
        
        // Mark as processed and store userId for future webhook calls
        await pendingRef.update({
          userId: userId,
          processed: true,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
          processedBy: 'verifyPurchase',
        });
        
        logger.info(`[verifyPurchase] Updated pending notification with userId: ${userId}`);
      }
    }
    
    logger.info(`[verifyPurchase] Verified purchase for user ${userId}: ${productId}`);
    
    res.json({
      success: true,
      subscription: productConfig.subscription,
      credits: productConfig.credits,
    });
    
  } catch (error) {
    logger.error('[verifyPurchase] Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// ===========================================
// Sync Subscription Status
// ===========================================
// Called by app on startup when store shows no subscription but Firestore does
// This catches expired subscriptions that webhooks may have missed
exports.syncSubscription = onRequest({ cors: true }, async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const { authToken, platform } = req.body;
    
    if (!authToken) {
      res.status(400).json({ success: false, error: 'Missing auth token' });
      return;
    }
    
    // Validate user
    const user = await validateUserToken(authToken);
    const userId = user.uid;
    
    logger.info(`[syncSubscription] Checking subscription for user ${userId} on ${platform}`);
    
    // Get current Firestore subscription status
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    
    if (!userData) {
      res.json({ success: true, message: 'No user data found' });
      return;
    }
    
    const currentSubscription = userData.subscription || 0;
    
    // If user doesn't have a subscription in Firestore, nothing to sync
    if (currentSubscription === 0) {
      res.json({ success: true, message: 'No subscription to sync' });
      return;
    }
    
    // Get the last purchase record
    const lastPurchaseId = userData.lastPurchaseId;
    if (!lastPurchaseId) {
      // No purchase record - likely an old account or data issue
      // Reset to free tier to be safe
      logger.warn(`[syncSubscription] User ${userId} has subscription but no lastPurchaseId, resetting`);
      await _resetToFreeTier(userId, 'no_purchase_record');
      res.json({ 
        success: true, 
        message: 'Subscription reset - no purchase record found',
        subscriptionReset: true 
      });
      return;
    }
    
    const purchaseDoc = await db.collection('purchases').doc(lastPurchaseId).get();
    if (!purchaseDoc.exists) {
      logger.warn(`[syncSubscription] Purchase ${lastPurchaseId} not found for user ${userId}, resetting`);
      await _resetToFreeTier(userId, 'purchase_not_found');
      res.json({ 
        success: true, 
        message: 'Subscription reset - purchase not found',
        subscriptionReset: true 
      });
      return;
    }
    
    const purchaseData = purchaseDoc.data();
    
    // Before resetting, check if subscription came from WEB PAYMENT instead of in-app purchase
    // Web payments are tracked in paymentEvents collection
    const webPaymentQuery = await db.collection('paymentEvents')
      .where('data.payerEmail', '==', userData.email)
      .where('status', '==', '1') // status 1 = successful
      .orderBy('receivedAt', 'desc')
      .limit(1)
      .get();
    
    // Also check by userId if email doesn't match
    let hasValidWebPayment = !webPaymentQuery.empty;
    
    if (!hasValidWebPayment && userData.email) {
      // Try alternative query - some payment events might use different email field
      const altPaymentQuery = await db.collection('paymentEvents')
        .where('data.payerEmail', '==', userData.email)
        .where('data.statusCode', '==', '2') // statusCode 2 = successful payment
        .orderBy('receivedAt', 'desc')
        .limit(1)
        .get();
      
      hasValidWebPayment = !altPaymentQuery.empty;
    }
    
    if (hasValidWebPayment) {
      // User has a valid web payment - DO NOT reset their subscription
      logger.info(`[syncSubscription] User ${userId} has valid web payment, keeping subscription`);
      res.json({ 
        success: true, 
        message: 'Subscription valid - web payment found',
        subscriptionReset: false,
        source: 'web_payment'
      });
      return;
    }
    
    // Also check subscriptionPlatform - if it's 'web' or null (legacy), don't reset
    if (userData.subscriptionPlatform === 'web' || userData.subscriptionSource === 'web') {
      logger.info(`[syncSubscription] User ${userId} has web subscription source, keeping subscription`);
      res.json({ 
        success: true, 
        message: 'Subscription valid - web platform',
        subscriptionReset: false,
        source: 'web'
      });
      return;
    }
    
    // Only reset if:
    // 1. No active store subscription AND
    // 2. No valid web payment AND  
    // 3. Subscription platform is android/ios (not web)
    const subscriptionPlatform = userData.subscriptionPlatform;
    if (subscriptionPlatform !== 'android' && subscriptionPlatform !== 'ios') {
      // Unknown or missing platform - could be web payment, don't reset
      logger.info(`[syncSubscription] User ${userId} has unknown platform '${subscriptionPlatform}', not resetting`);
      res.json({ 
        success: true, 
        message: 'Subscription kept - unknown platform (might be web)',
        subscriptionReset: false
      });
      return;
    }
    
    // Safe to reset - confirmed in-app purchase with no active store subscription
    logger.info(`[syncSubscription] User ${userId} has ${subscriptionPlatform} subscription but no active store subscription, resetting`);
    await _resetToFreeTier(userId, 'store_no_active_subscription');
    
    res.json({ 
      success: true, 
      message: 'Subscription reset - no active store subscription found',
      subscriptionReset: true 
    });
    
  } catch (error) {
    logger.error('[syncSubscription] Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// ===========================================
// Delete User Account
// ===========================================
// Deletes user data from userHistory and users collections
// Does NOT delete: couponRedemptions, genCount, iapNotification, paymentEvents, purchases
exports.deleteAccount = onRequest({ cors: true }, async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  try {
    const { authToken } = req.body;
    
    if (!authToken) {
      res.status(400).json({ success: false, error: 'Missing auth token' });
      return;
    }
    
    // Validate user token
    const user = await validateUserToken(authToken);
    const userId = user.uid;
    
    logger.info(`[deleteAccount] Starting account deletion for user: ${userId}`);
    
    // 1. Delete all userHistory documents for this user
    logger.info(`[deleteAccount] Deleting userHistory documents...`);
    const userHistoryRef = db.collection('userHistory');
    const historySnapshot = await userHistoryRef.where('userId', '==', userId).get();
    
    let historyDeleteCount = 0;
    const batch = db.batch();
    
    historySnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
      historyDeleteCount++;
    });
    
    if (historyDeleteCount > 0) {
      // If more than 500 docs, need multiple batches
      if (historyDeleteCount <= 500) {
        await batch.commit();
      } else {
        // Delete in batches of 500
        const chunks = [];
        for (let i = 0; i < historySnapshot.docs.length; i += 500) {
          chunks.push(historySnapshot.docs.slice(i, i + 500));
        }
        
        for (const chunk of chunks) {
          const chunkBatch = db.batch();
          chunk.forEach((doc) => chunkBatch.delete(doc.ref));
          await chunkBatch.commit();
        }
      }
      logger.info(`[deleteAccount] Deleted ${historyDeleteCount} userHistory documents`);
    }
    
    // 2. Delete user's storage files
    logger.info(`[deleteAccount] Deleting storage files...`);
    try {
      const bucket = storage.bucket();
      const [files] = await bucket.getFiles({ prefix: `userHistory/${userId}/` });
      
      if (files.length > 0) {
        await Promise.all(files.map(file => file.delete()));
        logger.info(`[deleteAccount] Deleted ${files.length} storage files`);
      }
    } catch (storageError) {
      // Log but don't fail if storage deletion has issues
      logger.warn(`[deleteAccount] Storage deletion warning: ${storageError.message}`);
    }
    
    // 3. Delete user document from users collection
    logger.info(`[deleteAccount] Deleting user document...`);
    await db.collection('users').doc(userId).delete();
    logger.info(`[deleteAccount] Deleted user document`);
    
    // 4. Delete Firebase Auth user
    logger.info(`[deleteAccount] Deleting Firebase Auth user...`);
    try {
      await admin.auth().deleteUser(userId);
      logger.info(`[deleteAccount] Deleted Firebase Auth user`);
    } catch (authError) {
      // Log but continue - user document is already deleted
      logger.warn(`[deleteAccount] Auth deletion warning: ${authError.message}`);
    }
    
    logger.info(`[deleteAccount] Account deletion completed for user: ${userId}`);
    
    res.json({
      success: true,
      message: 'Account deleted successfully',
      deletedHistoryCount: historyDeleteCount,
    });
    
  } catch (error) {
    logger.error('[deleteAccount] Error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message || 'Error deleting account' 
    });
  }
});

// Helper function to reset user to free tier
async function _resetToFreeTier(userId, reason) {
  await db.collection('users').doc(userId).update({
    subscription: 0,
    credits: 3,
    subscriptionProductId: null,
    subscriptionExpired: true,
    subscriptionExpiredAt: admin.firestore.FieldValue.serverTimestamp(),
    subscriptionVerified: false,
    subscriptionSyncReset: true,
    subscriptionSyncResetReason: reason,
    subscriptionSyncResetAt: admin.firestore.FieldValue.serverTimestamp(),
    // Clean up status flags
    subscriptionPaused: admin.firestore.FieldValue.delete(),
    subscriptionGracePeriod: admin.firestore.FieldValue.delete(),
    subscriptionCanceled: admin.firestore.FieldValue.delete(),
  });
  logger.info(`[_resetToFreeTier] Reset user ${userId} to free tier, reason: ${reason}`);
}

// Helper HTTP function to reset credits for users without subscription
// Finds all users where subscription field doesn't exist or equals 0, and sets their credits to 0
exports.resetCreditsForFreeUsers = onRequest({ cors: true }, async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  try {
    const usersRef = db.collection('users');
    let updatedCount = 0;
    let processedCount = 0;
    let batchCount = 0;
    
    // Get all users
    const allUsersSnapshot = await usersRef.get();
    
    // Firestore batch limit is 500, so we process in chunks
    const BATCH_SIZE = 500;
    let batch = db.batch();
    let currentBatchSize = 0;
    
    for (const doc of allUsersSnapshot.docs) {
      const userData = doc.data();
      processedCount++;
      
      // Check if subscription field doesn't exist or equals 0
      if (userData.subscription === undefined || userData.subscription === null || userData.subscription === 0) {
        batch.update(doc.ref, { credits: 0 });
        updatedCount++;
        currentBatchSize++;
        logger.info(`[resetCreditsForFreeUsers] Marking user ${doc.id} for credits reset (subscription: ${userData.subscription})`);
        
        // Commit batch when reaching limit
        if (currentBatchSize >= BATCH_SIZE) {
          await batch.commit();
          batchCount++;
          logger.info(`[resetCreditsForFreeUsers] Committed batch ${batchCount} with ${currentBatchSize} updates`);
          batch = db.batch();
          currentBatchSize = 0;
        }
      }
    }
    
    // Commit remaining updates
    if (currentBatchSize > 0) {
      await batch.commit();
      batchCount++;
      logger.info(`[resetCreditsForFreeUsers] Committed final batch ${batchCount} with ${currentBatchSize} updates`);
    }
    
    logger.info(`[resetCreditsForFreeUsers] Successfully reset credits for ${updatedCount} users in ${batchCount} batches`);
    
    res.status(200).json({
      success: true,
      message: `Reset credits for ${updatedCount} users without subscription`,
      processedCount,
      updatedCount,
      batchCount,
    });
    
  } catch (error) {
    logger.error('[resetCreditsForFreeUsers] Error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Error resetting credits',
    });
  }
});
