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
    .jpeg({ quality: 80 })
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
    
    // Convert to PNG using sharp for consistent format (Azure prefers PNG)
    const pngBuffer = await sharp(imageBuffer)
      .png()
      .toBuffer();
    
    logger.info(`[GPT-Image-1.5] Converted main image to PNG, size: ${pngBuffer.length} bytes`);

    // Convert object image to PNG if provided
    let objectPngBuffer = null;
    if (objectImageData) {
      const objectBuffer = Buffer.from(objectImageData.inlineData.data, 'base64');
      objectPngBuffer = await sharp(objectBuffer)
        .png()
        .toBuffer();
      logger.info(`[GPT-Image-1.5] Converted object image to PNG, size: ${objectPngBuffer.length} bytes`);
    }

    // Build the Azure OpenAI edit endpoint URL
    const editUrl = `${AZURE_OPENAI_ENDPOINT}openai/deployments/${AZURE_DEPLOYMENT_NAME}/images/edits?api-version=${AZURE_API_VERSION}`;
    
    logger.info(`[GPT-Image-1.5] Calling Azure endpoint: ${editUrl}`);

    // Create form data for the multipart request
    // GPT-image-1.5 supports multiple images via image[] array for inpainting
    const formData = new FormData();
    
    // Add main image
    formData.append('image[]', pngBuffer, {
      filename: 'input_image.png',
      contentType: 'image/png',
      knownLength: pngBuffer.length
    });
    
    // Add object image if provided (for inpainting the object into the scene)
    if (objectPngBuffer) {
      formData.append('image[]', objectPngBuffer, {
        filename: 'object_image.png',
        contentType: 'image/png',
        knownLength: objectPngBuffer.length
      });
      logger.info(`[GPT-Image-1.5] Added object image to request for inpainting`);
    }
    
    formData.append('prompt', englishPrompt);
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
exports.processImageRequestExperimental = onDocumentCreated('userHistory/{docId}', async (event) => {
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

// Cloud function triggered when a new userHistory document is created
exports.generateSuggestions = onDocumentCreated('userHistory/{docId}', async (event) => {
  const docId = event.params.docId;
  const docData = event.data.data();

  // Only run for uploaded images (not requests, not generated ones) and if suggestions don't exist yet
  if (docData.type !== 'uploaded' || docData.suggestions) {
    return;
  }

  logger.info(`Generating interior design suggestions for document: ${docId}`);

  try {
    const imageUrl = docData.storageUrl || docData.originalImageUrl;
    if (!imageUrl) {
      logger.warn('No image URL found for generating suggestions');
      return;
    }

    // Fetch the image
    const response = await fetch(imageUrl);
    const arrayBuffer = await response.arrayBuffer();
    const base64Data = Buffer.from(arrayBuffer).toString('base64');
    const mimeType = response.headers.get('content-type') || 'image/jpeg';
    
    const imageData = {
      inlineData: {
        data: base64Data,
        mimeType: mimeType
      }
    };

    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    
    // Prompt for suggestions
    const prompt = `
      You are a witty, creative, and professional interior designer. 
      Analyze this room image and provide 5 specific, actionable suggestions to improve, renovate, or redesign it.
      
      IMPORTANT: Every suggestion must preserve the room's general structure, shape, and window/door openings exactly as they appear in the original image. Only change the interior design elements like furniture, colors, decor, lighting fixtures, etc.
      
      For each suggestion provide:
      1. "label": A short, catchy title in Hebrew (3-6 words) that describes the change.
      2. "prompt": A detailed English prompt that I can feed into an AI image generator to visualize this specific change. It should describe the entire room but emphasize this specific modification. CRITICAL: Each prompt MUST include the instruction to "maintain the exact same room structure, layout, walls, window openings, and door positions as the original image".
      
      Return ONLY a valid JSON array of objects with keys "label" and "prompt". Do not wrap in markdown code blocks.
      Example:
      [
        { "label": "הוספת צמחים ירוקים ורעננים", "prompt": "A modern living room with lush green potted plants added to the corners and shelves, bright natural lighting, photorealistic. Maintain the exact same room structure, layout, walls, window openings, and door positions as the original image." },
        ...
      ]
    `;

    const result = await model.generateContent([prompt, imageData]);
    const responseText = result.response.text();
    
    // Clean and parse JSON
    let cleanResponse = responseText
      .replace(/```json\s*/gi, '')
      .replace(/```\s*/g, '')
      .trim();
      
    let suggestions = [];
    try {
      suggestions = JSON.parse(cleanResponse);
    } catch (e) {
      logger.error('Failed to parse suggestions JSON:', e);
      // Fallback parsing or retry logic could go here
      return;
    }

    if (Array.isArray(suggestions) && suggestions.length > 0) {
      // Update Firestore document
      await db.collection('userHistory').doc(docId).update({
        suggestions: suggestions,
        suggestionsGeneratedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      logger.info(`Successfully generated ${suggestions.length} suggestions for ${docId}`);
    }

  } catch (error) {
    logger.error('Error generating suggestions:', error);
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
            subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
          });
          logger.info(`Updated user ${userId} subscription to ${newSubscription}, credits: ${newCredits}`);
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
          subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        logger.info(`[onUserEmailUpdate] SUCCESS: Granted subscription ${newSubscription} (${newCredits} credits) to user ${event.params.userId} from payment event ${paymentDoc.id}`);
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
    
    // Get credits to add (default 10)
    const creditsToAdd = couponData.credits || 10;
    
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
    
    const userData = userDoc.data();
    const currentCredits = userData.credits || 0;
    const newCredits = currentCredits + creditsToAdd;
    
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
      creditsAdded: creditsToAdd,
      redeemedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Record user redemption
    batch.set(userRedemptionRef, {
      couponCode: couponCode.toUpperCase(),
      deviceId: deviceId,
      userId: userId,
      creditsAdded: creditsToAdd,
      redeemedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Increment coupon redemption count
    batch.update(couponRef, {
      redemptionCount: admin.firestore.FieldValue.increment(1),
      lastRedeemedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    await batch.commit();
    
    logger.info(`[redeemCoupon] SUCCESS: User ${userId} redeemed coupon ${couponCode} for ${creditsToAdd} credits. New balance: ${newCredits}`);
    
    res.json({
      success: true,
      creditsAdded: creditsToAdd,
      newCredits: newCredits,
      message: `נוספו ${creditsToAdd} קרדיטים לחשבונך!`
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
