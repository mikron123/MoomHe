const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const { logger } = require('firebase-functions');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const sharp = require('sharp');
const { doc, collection, setDoc } = require('firebase-admin/firestore');

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
async function checkAndUpdateGenerationCount(userId) {
  const now = new Date();
  const monthYear = `${String(now.getMonth() + 1).padStart(2, '0')}-${now.getFullYear()}`;
  const genCountRef = db.collection('genCount').doc(monthYear).collection('users').doc(userId);
  
  try {
    const doc = await genCountRef.get();
    
    if (!doc.exists) {
      // Create new document with count 0
      await genCountRef.set({ count: 0 });
      return { count: 0, limit: 50 }; // Default limit of 50 generations per month
    }
    
    const data = doc.data();
    const currentCount = data.count || 0;
    const limit = data.limit || 50; // Default limit
    
    if (currentCount >= limit) {
      throw new Error(`Monthly generation limit reached (${currentCount}/${limit})`);
    }
    
    // Increment count
    await genCountRef.update({ count: admin.firestore.FieldValue.increment(1) });
    
    return { count: currentCount + 1, limit };
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

// Helper function to process image with Gemini
async function processImageWithGemini(prompt, imageData, isObjectDetection = false, objectImageData = null) {
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
      // Prepare content array with prompt and main image
      const content = [prompt, imageData];
      
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
    
    // Check generation count
    const { count, limit } = await checkAndUpdateGenerationCount(userId);
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
      
      result = await processImageWithGemini(docData.prompt, imageData, false, objectImageData);
      
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
    const { imageData, authToken, historyId } = req.body;
    
    if (!imageData || !authToken) {
      res.status(400).json({ error: 'Missing required fields: imageData, authToken' });
      return;
    }
    
    // Validate user token
    const user = await validateUserToken(authToken);
    const userId = user.uid;
    
    // Check generation count
    const { count, limit } = await checkAndUpdateGenerationCount(userId);
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

// HTTP function for health check
exports.healthCheck = onRequest({ cors: true }, (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
