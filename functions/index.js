const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const { logger } = require('firebase-functions');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const sharp = require('sharp');

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

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
  // If credits is 4 (free) or 40 (monthly), and genCount is DAILY, then subtraction makes no sense unless credits are DAILY.
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
  // Given "4 images to create" default for new users, and "40/100/200" for subs.
  // If I start with 4 free images. I use 1. genCount = 1. Remaining = 4 - 1 = 3.
  // If genCount resets tomorrow (because of `{date}`), then I get 4 free images EVERY DAY?
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
    let creditLimit = 4; // Default free limit
    let subscriptionStatus = 0;
    
    if (userProfileDoc.exists) {
      const userData = userProfileDoc.data();
      creditLimit = userData.credits || 4;
      subscriptionStatus = userData.subscription || 0;
    }

    // Get Counts
    const userCount = userDoc.exists ? (userDoc.data().count || 0) : 0;
    const deviceCount = deviceDoc.exists ? (deviceDoc.data().count || 0) : 0;
    
    // Logic:
    // If Subscription > 0, we trust the User ID limit (paying user).
    // If Subscription == 0 (Free), we enforce the stricter of User Count OR Device Count against the limit (4).
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
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash-image-preview" });
  
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
  
  // Set default credits (4) and subscription (0 - no subscription)
  // Using set with merge to avoid overwriting other fields if they exist
  return snapshot.ref.set({
    credits: 4,
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
      
      // Update the document with results (don't store large raw response)
      await db.collection('userHistory').doc(docId).update({
        isDone: true,
        result: {
          type: 'objectDetection',
          objects: objects
        },
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        generationCount: count
      });
      
    } else {
      // Image generation request
      let imageData;
      
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
        
        // Update the document with results (don't store large base64 data in Firestore)
        await db.collection('userHistory').doc(docId).update({
          isDone: true,
          result: {
            type: 'imageGeneration',
            storageUrl: imageUrl,
            thumbnailUrl: thumbnailUrl,
            filename: filename,
            thumbnailFilename: thumbnailFilename
          },
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
          generationCount: count
        });
      } else {
        throw new Error('No image was generated');
      }
    }
    
    logger.info(`Successfully processed request ${docId} for user ${userId}`);
    
  } catch (error) {
    logger.error(`Error processing request ${docId}:`, error);
    
    // Update document with error
    await db.collection('userHistory').doc(docId).update({
      isDone: true,
      isError: true,
      error: error.message,
      processedAt: admin.firestore.FieldValue.serverTimestamp()
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
          newCredits = 40;
        } else if (description.includes('moomhe_monthly_budget')) {
          newSubscription = 2;
          newCredits = 100;
        } else if (description.includes('moomhe_monthly_pro')) {
          newSubscription = 3;
          newCredits = 200;
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
// Translation feature added
