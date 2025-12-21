// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics, logEvent } from "firebase/analytics";
import { getAI, getGenerativeModel, GoogleAIBackend, ResponseModality } from "firebase/ai";
import { getAuth, signInAnonymously, onAuthStateChanged } from "firebase/auth";
import { getFirestore, doc, setDoc, getDoc, collection, query, orderBy, where, getDocs, limit, startAfter } from "firebase/firestore";
import { getStorage, ref, uploadBytes, getDownloadURL } from "firebase/storage";
import FingerprintJS from '@fingerprintjs/fingerprintjs';

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDexERfe7htllA1aq7vlbnyQAmfgjx6HnI",
  authDomain: "moomhe-6de30.firebaseapp.com",
  projectId: "moomhe-6de30",
  storageBucket: "moomhe-6de30.firebasestorage.app",
  messagingSenderId: "951714207506",
  appId: "1:951714207506:web:0e3a50f5d663095e4345cb",
  measurementId: "G-6PHVQNPHNL"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

// Initialize the Gemini Developer API backend service
const ai = getAI(app, { backend: new GoogleAIBackend() });

// Create a `GenerativeModel` instance with a model that supports your use case
// const model = getGenerativeModel(ai, {
//   model: "gemini-2.5-flash-image",
//   // Configure the model to respond with text and images (required)
//   generationConfig: {
//     responseModalities: [ResponseModality.TEXT, ResponseModality.IMAGE],
//   },
// });

// Prepare an image for the model to edit
async function fileToGenerativePart(file) {
  const base64EncodedDataPromise = new Promise((resolve) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result.split(',')[1]);
    reader.readAsDataURL(file);
  });
  return {
    inlineData: { data: await base64EncodedDataPromise, mimeType: file.type },
  };
}

// Convert image URL to file for AI processing
async function urlToFile(url) {
  const response = await fetch(url);
  const blob = await response.blob();
  return new File([blob], 'image.jpg', { type: blob.type });
}

// Authentication functions
async function signInUser() {
  try {
    const userCredential = await signInAnonymously(auth);
    return userCredential.user;
  } catch (error) {
    console.error('Error signing in:', error);
    throw error;
  }
}

// Helper to get or create a persistent device ID
function getDeviceId() {
  let deviceId = localStorage.getItem('moomhe_device_id');
  if (!deviceId) {
    deviceId = 'device_' + Date.now() + '_' + Math.random().toString(36).substring(2, 15);
    localStorage.setItem('moomhe_device_id', deviceId);
  }
  return deviceId;
}

// Browser fingerprint promise - initialized once
let fingerprintPromise = null;
let cachedFingerprint = null;

// Initialize FingerprintJS and get the visitor ID
async function initFingerprint() {
  if (cachedFingerprint) {
    return cachedFingerprint;
  }
  
  if (!fingerprintPromise) {
    fingerprintPromise = FingerprintJS.load()
      .then(fp => fp.get())
      .then(result => {
        cachedFingerprint = result.visitorId;
        // Also store in localStorage as backup
        localStorage.setItem('moomhe_fingerprint', cachedFingerprint);
        console.log('Browser fingerprint generated:', cachedFingerprint);
        return cachedFingerprint;
      })
      .catch(error => {
        console.error('FingerprintJS error, falling back to localStorage:', error);
        // Fallback to stored fingerprint or generate a random one
        let fallback = localStorage.getItem('moomhe_fingerprint');
        if (!fallback) {
          fallback = 'fallback_' + Date.now() + '_' + Math.random().toString(36).substring(2, 15);
          localStorage.setItem('moomhe_fingerprint', fallback);
        }
        cachedFingerprint = fallback;
        return fallback;
      });
  }
  
  return fingerprintPromise;
}

// Get fingerprint synchronously if available, otherwise return cached/stored value
function getFingerprint() {
  if (cachedFingerprint) {
    return cachedFingerprint;
  }
  
  // Try to get from localStorage as immediate fallback
  const stored = localStorage.getItem('moomhe_fingerprint');
  if (stored) {
    cachedFingerprint = stored;
    return stored;
  }
  
  // If nothing available, return a temporary ID (will be replaced by async call)
  return null;
}

// Async version that ensures fingerprint is ready
async function getDeviceFingerprint() {
  // First try cached value
  if (cachedFingerprint) {
    return cachedFingerprint;
  }
  
  // Then try localStorage
  const stored = localStorage.getItem('moomhe_fingerprint');
  if (stored) {
    cachedFingerprint = stored;
    return stored;
  }
  
  // Finally, generate new fingerprint
  return await initFingerprint();
}

// Initialize fingerprint on module load
initFingerprint();

// User management functions
async function createOrUpdateUser(user) {
  const deviceId = getDeviceId();
  const appVersion = '1.0.0'; // Hardcoded for now, can be moved to config

  const userData = {
    uid: user.uid,
    email: user.email || null,
    lastActive: new Date(),
    os: navigator.platform,
    userAgent: navigator.userAgent,
    deviceBrand: getDeviceBrand(),
    appVersion: appVersion,
    deviceId: deviceId,
    createdAt: user.metadata.creationTime,
    isAnonymous: user.isAnonymous
  };

  try {
    // Using merge: true to update existing fields without overwriting everything
    // Note: credits and subscription are protected by Firestore Rules and managed by server
    await setDoc(doc(db, 'users', user.uid), userData, { merge: true });
    return userData;
  } catch (error) {
    console.error('Error creating/updating user:', error);
    throw error;
  }
}

// Simple helper to guess device brand from user agent
function getDeviceBrand() {
  const ua = navigator.userAgent.toLowerCase();
  if (ua.includes('iphone') || ua.includes('ipad') || ua.includes('macintosh')) return 'Apple';
  if (ua.includes('samsung')) return 'Samsung';
  if (ua.includes('xiaomi')) return 'Xiaomi';
  if (ua.includes('huawei')) return 'Huawei';
  if (ua.includes('pixel')) return 'Google';
  if (ua.includes('android')) return 'Android Device';
  if (ua.includes('windows')) return 'Windows PC';
  return 'Unknown';
}

// Storage functions
// Helper function to compress and resize image to max 1080p
async function compressImage(imageDataUrl, maxWidth = 1920, maxHeight = 1080, quality = 0.8, isHeicFile = false) {
  // Check if the image is HEIC format (via flag or data URL detection)
  const needsHeicConversion = isHeicFile || imageDataUrl.includes('image/heic') || imageDataUrl.includes('image/heif');
  if (needsHeicConversion) {
    try {
      console.log('Converting HEIC image to JPEG...');
      
      // Convert data URL to blob
      const response = await fetch(imageDataUrl);
      const heicBlob = await response.blob();
      
      // Skip conversion if already a displayable format
      if (heicBlob.type === 'image/jpeg' || heicBlob.type === 'image/png' || heicBlob.type === 'image/webp') {
        console.log('File already in displayable format, skipping HEIC conversion');
        const convertedDataUrl = await new Promise((resolve) => {
          const reader = new FileReader();
          reader.onload = () => resolve(reader.result);
          reader.readAsDataURL(heicBlob);
        });
        return await compressImage(convertedDataUrl, maxWidth, maxHeight, quality);
      }
      
      // Convert HEIC to JPEG using heic-to library
      const { heicTo } = await import('heic-to');
      const convertedBlob = await heicTo({
        blob: heicBlob,
        type: 'image/jpeg',
        quality: quality
      });
      
      // Convert the converted JPEG blob to data URL for further processing
      const convertedDataUrl = await new Promise((resolve) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.readAsDataURL(convertedBlob);
      });
      
      console.log('HEIC converted to JPEG successfully');
      
      // Now process the converted JPEG with the regular compression logic
      return await compressImage(convertedDataUrl, maxWidth, maxHeight, quality);
      
    } catch (heicError) {
      console.error('Error converting HEIC image:', heicError);
      throw new Error('Failed to convert HEIC image to JPEG');
    }
  }
  
  // Regular image compression for non-HEIC images
  return new Promise((resolve, reject) => {
    const img = new Image();
    
    // Set crossOrigin to anonymous to avoid tainted canvas issues
    img.crossOrigin = 'anonymous';
    
    img.onload = () => {
      try {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        
        // Calculate new dimensions while maintaining aspect ratio
        let { width, height } = img;
        
        // If image is smaller than max dimensions, keep original size
        if (width <= maxWidth && height <= maxHeight) {
          canvas.width = width;
          canvas.height = height;
        } else {
          // Calculate scaling factor to fit within max dimensions
          const scaleX = maxWidth / width;
          const scaleY = maxHeight / height;
          const scale = Math.min(scaleX, scaleY);
          
          width = Math.floor(width * scale);
          height = Math.floor(height * scale);
          
          canvas.width = width;
          canvas.height = height;
        }
        
        // Draw compressed image
        ctx.drawImage(img, 0, 0, width, height);
        
        // Convert to blob with specified quality
        canvas.toBlob((blob) => {
          if (blob) {
            console.log(`Image compressed: Original ${img.width}x${img.height} -> ${width}x${height}, Size: ${(blob.size / 1024 / 1024).toFixed(2)}MB`);
            resolve(blob);
          } else {
            reject(new Error('Failed to create compressed image blob'));
          }
        }, 'image/jpeg', quality);
      } catch (error) {
        console.error('Error compressing image:', error);
        reject(error);
      }
    };
    
    img.onerror = () => {
      reject(new Error('Failed to load image for compression'));
    };
    
    img.src = imageDataUrl;
  });
}

// Helper function to compress file directly
function compressFile(file, maxWidth = 1920, maxHeight = 1080, quality = 0.8) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      compressImage(e.target.result, maxWidth, maxHeight, quality)
        .then(resolve)
        .catch(reject);
    };
    reader.onerror = () => reject(new Error('Failed to read file'));
    reader.readAsDataURL(file);
  });
}

// Helper function to create thumbnail
function createThumbnail(imageDataUrl, maxWidth = 200, maxHeight = 200) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    
    // Set crossOrigin to anonymous to avoid tainted canvas issues
    img.crossOrigin = 'anonymous';
    
    img.onload = () => {
      try {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        
        // Calculate thumbnail dimensions
        let { width, height } = img;
        if (width > height) {
          if (width > maxWidth) {
            height = (height * maxWidth) / width;
            width = maxWidth;
          }
        } else {
          if (height > maxHeight) {
            width = (width * maxHeight) / height;
            height = maxHeight;
          }
        }
        
        canvas.width = width;
        canvas.height = height;
        
        // Draw thumbnail
        ctx.drawImage(img, 0, 0, width, height);
        
        // Convert to blob with error handling
        canvas.toBlob((blob) => {
          if (blob) {
            resolve(blob);
          } else {
            reject(new Error('Failed to create thumbnail blob'));
          }
        }, 'image/jpeg', 0.8);
      } catch (error) {
        console.error('Error creating thumbnail:', error);
        reject(error);
      }
    };
    
    img.onerror = () => {
      reject(new Error('Failed to load image for thumbnail creation'));
    };
    
    img.src = imageDataUrl;
  });
}

async function uploadImageToStorage(userId, imageDataUrl, prompt) {
  try {
    // Compress image to max 1080p before uploading
    let compressedBlob;
    try {
      compressedBlob = await compressImage(imageDataUrl, 1920, 1080, 0.8);
    } catch (compressionError) {
      console.warn('Failed to compress image, using original:', compressionError);
      // Fallback: convert data URL to blob without compression
      const response = await fetch(imageDataUrl);
      compressedBlob = await response.blob();
    }
    
    // Create thumbnail with error handling
    let thumbnailBlob;
    try {
      thumbnailBlob = await createThumbnail(imageDataUrl);
    } catch (thumbnailError) {
      console.warn('Failed to create thumbnail, using compressed image:', thumbnailError);
      // Fallback: use the compressed image as thumbnail
      thumbnailBlob = compressedBlob;
    }
    
    // Create unique filename
    const timestamp = Date.now();
    const filename = `image_${timestamp}.jpg`;
    const thumbnailFilename = `thumbnail_${timestamp}.jpg`;
    
    // Upload compressed image
    const storageRef = ref(storage, `userHistory/${userId}/${filename}`);
    const snapshot = await uploadBytes(storageRef, compressedBlob);
    const downloadURL = await getDownloadURL(snapshot.ref);
    
    // Upload thumbnail
    const thumbnailRef = ref(storage, `userHistory/${userId}/${thumbnailFilename}`);
    const thumbnailSnapshot = await uploadBytes(thumbnailRef, thumbnailBlob);
    const thumbnailURL = await getDownloadURL(thumbnailSnapshot.ref);
    
    return { downloadURL, thumbnailURL, filename, thumbnailFilename, timestamp };
  } catch (error) {
    console.error('Error uploading image:', error);
    throw error;
  }
}

async function uploadImageToUserUploads(userId, file) {
  try {
    // Convert file to data URL for compression and thumbnail generation
    const dataUrl = await new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.readAsDataURL(file);
    });
    
    // Compress image to max 1080p before uploading
    let compressedBlob;
    try {
      compressedBlob = await compressImage(dataUrl, 1920, 1080, 0.8);
    } catch (compressionError) {
      console.warn('Failed to compress image, using original file:', compressionError);
      // Fallback: use the original file
      compressedBlob = file;
    }
    
    // Create thumbnail with error handling
    let thumbnailBlob;
    try {
      thumbnailBlob = await createThumbnail(dataUrl);
    } catch (thumbnailError) {
      console.warn('Failed to create thumbnail, using compressed image:', thumbnailError);
      // Fallback: use the compressed image as thumbnail
      thumbnailBlob = compressedBlob;
    }
    
    // Create unique filename
    const timestamp = Date.now();
    const filename = `upload_${timestamp}.jpg`; // Always use .jpg for compressed images
    const thumbnailFilename = `upload_thumbnail_${timestamp}.jpg`;
    
    // Upload compressed image
    const storageRef = ref(storage, `userHistory/${userId}/${filename}`);
    const snapshot = await uploadBytes(storageRef, compressedBlob);
    const downloadURL = await getDownloadURL(snapshot.ref);
    
    // Upload thumbnail
    const thumbnailRef = ref(storage, `userHistory/${userId}/${thumbnailFilename}`);
    const thumbnailSnapshot = await uploadBytes(thumbnailRef, thumbnailBlob);
    const thumbnailURL = await getDownloadURL(thumbnailSnapshot.ref);
    
    return { downloadURL, thumbnailURL, filename, thumbnailFilename, timestamp };
  } catch (error) {
    console.error('Error uploading user image:', error);
    throw error;
  }
}

// Firestore functions
async function saveImageToHistory(userId, imageData) {
  try {
    const { downloadURL, thumbnailURL, filename, thumbnailFilename, timestamp } = await uploadImageToStorage(userId, imageData.imageUrl, imageData.prompt);
    
    const historyEntry = {
      storageUrl: downloadURL,
      thumbnailUrl: thumbnailURL,
      filename: filename,
      thumbnailFilename: thumbnailFilename,
      prompt: imageData.prompt,
      timestamp: imageData.timestamp,
      createdAt: new Date(),
      userId: userId,
      type: 'generated'
    };
    
    // Use Firebase auto-generated document ID to ensure uniqueness
    const docRef = doc(collection(db, 'userHistory'));
    await setDoc(docRef, historyEntry);
    
    // Return the entry with the Firebase-generated ID
    return {
      id: docRef.id,
      ...historyEntry
    };
  } catch (error) {
    console.error('Error saving image to history:', error);
    throw error;
  }
}

async function saveUploadToHistory(userId, file, prompt = '') {
  try {
    const { downloadURL, thumbnailURL, filename, thumbnailFilename, timestamp } = await uploadImageToUserUploads(userId, file);
    
    const historyEntry = {
      storageUrl: downloadURL,
      thumbnailUrl: thumbnailURL,
      filename: filename,
      thumbnailFilename: thumbnailFilename,
      prompt: prompt || `Uploaded: ${file.name}`,
      timestamp: new Date().toLocaleString('he-IL'),
      createdAt: new Date(),
      userId: userId,
      type: 'uploaded'
    };
    
    // Use Firebase auto-generated document ID to ensure uniqueness
    const docRef = doc(collection(db, 'userHistory'));
    await setDoc(docRef, historyEntry);
    
    // Return the entry with the Firebase-generated ID
    return {
      id: docRef.id,
      ...historyEntry
    };
  } catch (error) {
    console.error('Error saving upload to history:', error);
    throw error;
  }
}

async function loadUserHistory(userId) {
  try {
    const historyRef = collection(db, 'userHistory');
    const q = query(historyRef,
      where('userId', '==', userId),
      orderBy('createdAt', 'desc')
    );
    const querySnapshot = await getDocs(q);

    const history = [];
    querySnapshot.forEach((doc) => {
      const data = doc.data();
      // Only include records that don't have errors
      if (!data.isError) {
        // Handle nested result structure from server-side processing
        const historyEntry = {
          id: doc.id,
          ...data
        };

        // If this is a server-processed result, flatten the result object
        if (data.result && data.result.storageUrl) {
          historyEntry.storageUrl = data.result.storageUrl;
          historyEntry.thumbnailUrl = data.result.thumbnailUrl;
          historyEntry.filename = data.result.filename;
          historyEntry.thumbnailFilename = data.result.thumbnailFilename;
          
          // Also check for originalImageUrl in the result
          if (data.result.originalImageUrl) {
            historyEntry.originalImageUrl = data.result.originalImageUrl;
          }
        }
        
        // Also check at root level for originalImageUrl (for older records or different structure)
        if (data.originalImageUrl) {
          historyEntry.originalImageUrl = data.originalImageUrl;
        } else if (data.imageData) {
           // Fallback to imageData if it's a URL (for some older structures)
           if (typeof data.imageData === 'string' && data.imageData.startsWith('http')) {
             historyEntry.originalImageUrl = data.imageData;
           }
        }

        // Preserve objects field if it exists (from object detection)
        if (data.objects) {
          historyEntry.objects = data.objects;
        }

        history.push(historyEntry);
      }
    });

    return history;
  } catch (error) {
    console.error('Error loading user history:', error);
    return [];
  }
}

async function loadUserHistoryPaginated(userId, page = 1, pageSize = 7) {
  try {
    const historyRef = collection(db, 'userHistory');

    // Get the last document from previous page for cursor-based pagination
    let lastDoc = null;
    if (page > 1) {
      // For subsequent pages, we need to get the cursor from the last item of previous page
      // This is a simplified approach - in a real app, you'd want to store cursors
      const prevPageQuery = query(historyRef,
        where('userId', '==', userId),
        orderBy('createdAt', 'desc'),
        limit((page - 1) * pageSize)
      );
      const prevSnapshot = await getDocs(prevPageQuery);
      if (!prevSnapshot.empty) {
        lastDoc = prevSnapshot.docs[prevSnapshot.docs.length - 1];
      }
    }

    // Build the query for current page - fetch more than needed to account for filtered items
    let q;
    const fetchLimit = pageSize * 2; // Fetch double to account for potential filtering
    if (lastDoc && page > 1) {
      q = query(historyRef,
        where('userId', '==', userId),
        orderBy('createdAt', 'desc'),
        startAfter(lastDoc),
        limit(fetchLimit)
      );
    } else {
      q = query(historyRef,
        where('userId', '==', userId),
        orderBy('createdAt', 'desc'),
        limit(fetchLimit)
      );
    }

    const querySnapshot = await getDocs(q);

    const history = [];
    querySnapshot.forEach((doc) => {
      const data = doc.data();
      // Only include records that don't have errors
      if (!data.isError) {
        // Handle nested result structure from server-side processing
        const historyEntry = {
          id: doc.id,
          ...data
        };

        // If this is a server-processed result, flatten the result object
        if (data.result && data.result.storageUrl) {
          historyEntry.storageUrl = data.result.storageUrl;
          historyEntry.thumbnailUrl = data.result.thumbnailUrl;
          historyEntry.filename = data.result.filename;
          historyEntry.thumbnailFilename = data.result.thumbnailFilename;
          
          // Also check for originalImageUrl in the result
          if (data.result.originalImageUrl) {
            historyEntry.originalImageUrl = data.result.originalImageUrl;
          }
        }
        
        // Also check at root level for originalImageUrl (for older records or different structure)
        if (data.originalImageUrl) {
          historyEntry.originalImageUrl = data.originalImageUrl;
        } else if (data.imageData) {
           // Fallback to imageData if it's a URL (for some older structures)
           if (typeof data.imageData === 'string' && data.imageData.startsWith('http')) {
             historyEntry.originalImageUrl = data.imageData;
           }
        }

        // Preserve objects field if it exists (from object detection)
        if (data.objects) {
          historyEntry.objects = data.objects;
        }

        history.push(historyEntry);
      }
    });

    // Take only the requested page size
    const paginatedHistory = history.slice(0, pageSize);
    
    // Determine if there are more items
    const hasMore = querySnapshot.docs.length === fetchLimit && history.length >= pageSize;

    console.log(`Pagination debug - Page: ${page}, Requested: ${pageSize}, Fetched: ${querySnapshot.docs.length}, Valid: ${history.length}, Returned: ${paginatedHistory.length}, HasMore: ${hasMore}`);

    return { history: paginatedHistory, hasMore };
  } catch (error) {
    console.error('Error loading paginated user history:', error);
    return { history: [], hasMore: false };
  }
}

// Temporary upload for WhatsApp sharing
async function uploadImageForSharing(userId, imageDataUrl) {
  try {
    // Compress image to max 1080p before uploading for sharing
    let compressedBlob;
    try {
      compressedBlob = await compressImage(imageDataUrl, 1920, 1080, 0.8);
    } catch (compressionError) {
      console.warn('Failed to compress image for sharing, using original:', compressionError);
      // Fallback: convert data URL to blob without compression
      const response = await fetch(imageDataUrl);
      compressedBlob = await response.blob();
    }
    
    // Create temporary filename
    const timestamp = Date.now();
    const filename = `temp_${timestamp}.jpg`;
    
    // Upload compressed image to temporary path
    const storageRef = ref(storage, `temp/${userId}/${filename}`);
    const snapshot = await uploadBytes(storageRef, compressedBlob);
    const downloadURL = await getDownloadURL(snapshot.ref);
    
    // Schedule cleanup after 1 hour (3600000 ms)
    setTimeout(() => {
      try {
        // Note: In a production app, you'd want to implement proper cleanup
        // For now, we'll just log that cleanup would happen
        console.log('🧹 Cleanup scheduled for temporary file:', filename);
      } catch (cleanupError) {
        console.error('Error during cleanup:', cleanupError);
      }
    }, 3600000);
    
    return { downloadURL, filename, timestamp };
  } catch (error) {
    console.error('Error uploading image for sharing:', error);
    throw error;
  }
}


// ==========================================
// ANALYTICS HELPER FUNCTIONS
// ==========================================

/**
 * Log a custom analytics event
 * @param {string} eventName - The name of the event
 * @param {Object} params - Optional parameters for the event
 */
function logAnalyticsEvent(eventName, params = {}) {
  try {
    logEvent(analytics, eventName, {
      ...params,
      timestamp: new Date().toISOString()
    });
    console.log(`📊 Analytics: ${eventName}`, params);
  } catch (error) {
    console.error('Analytics error:', error);
  }
}

// Authentication Events
const trackSignUp = (method = 'email') => logAnalyticsEvent('sign_up', { method });
const trackLogin = (method = 'email') => logAnalyticsEvent('login', { method });
const trackAnonymousSignIn = () => logAnalyticsEvent('anonymous_sign_in');
const trackLogout = () => logAnalyticsEvent('logout');
const trackAccountLink = (success) => logAnalyticsEvent('account_link', { success });

// Image Events
const trackImageUpload = (fileType) => logAnalyticsEvent('image_upload', { file_type: fileType });
const trackObjectImageUpload = () => logAnalyticsEvent('object_image_upload');
const trackImageDownload = () => logAnalyticsEvent('image_download');
const trackImageShare = (platform) => logAnalyticsEvent('image_share', { platform });

// AI Generation Events
const trackGenerationStart = (promptType, hasObjectImage = false) => 
  logAnalyticsEvent('generation_start', { prompt_type: promptType, has_object_image: hasObjectImage });
const trackGenerationComplete = (promptType, durationMs) => 
  logAnalyticsEvent('generation_complete', { prompt_type: promptType, duration_ms: durationMs });
const trackGenerationError = (errorType) => 
  logAnalyticsEvent('generation_error', { error_type: errorType });
const trackLimitReached = (subscription, usage, limit) => 
  logAnalyticsEvent('limit_reached', { subscription, usage, limit });

// Object Detection Events
const trackObjectDetection = (success, objectCount = 0) => 
  logAnalyticsEvent('object_detection', { success, object_count: objectCount });

// Feature Usage Events
const trackFeatureUse = (feature, value = null) => 
  logAnalyticsEvent('feature_use', { feature, value });
const trackStyleSelect = (style) => logAnalyticsEvent('style_select', { style });
const trackColorSelect = (color, category) => logAnalyticsEvent('color_select', { color, category });
const trackAngleSelect = (angle) => logAnalyticsEvent('angle_select', { angle });
const trackLightingSelect = (lighting) => logAnalyticsEvent('lighting_select', { lighting });
const trackFurnitureSelect = (furniture) => logAnalyticsEvent('furniture_select', { furniture });
const trackRepairsSelect = (repair) => logAnalyticsEvent('repairs_select', { repair });
const trackDoorsWindowsSelect = (option) => logAnalyticsEvent('doors_windows_select', { option });
const trackBathroomSelect = (option) => logAnalyticsEvent('bathroom_select', { option });

// Onboarding Events
const trackOnboardingStart = () => logAnalyticsEvent('onboarding_start');
const trackOnboardingStep = (step) => logAnalyticsEvent('onboarding_step', { step });
const trackOnboardingComplete = () => logAnalyticsEvent('onboarding_complete');
const trackOnboardingSkip = (atStep) => logAnalyticsEvent('onboarding_skip', { at_step: atStep });

// Subscription Events
const trackSubscriptionModalView = () => logAnalyticsEvent('subscription_modal_view');
const trackSubscriptionClick = (tier) => logAnalyticsEvent('subscription_click', { tier });
const trackWelcomePremiumShow = () => logAnalyticsEvent('welcome_premium_show');

// History Events
const trackHistoryClick = () => logAnalyticsEvent('history_click');
const trackHistoryLoadMore = (page) => logAnalyticsEvent('history_load_more', { page });

// Contact Events
const trackContactFormSubmit = () => logAnalyticsEvent('contact_form_submit');
const trackContactFormSuccess = () => logAnalyticsEvent('contact_form_success');

// Category Events
const trackCategorySelect = (category) => logAnalyticsEvent('category_select', { category });

// Page View / Session Events
const trackPageView = (page) => logAnalyticsEvent('page_view', { page });
const trackAppOpen = () => logAnalyticsEvent('app_open');

export { 
  app, 
  analytics, 
  // model, 
  fileToGenerativePart, 
  urlToFile,
  auth,
  db,
  storage,
  signInUser,
  createOrUpdateUser,
  getDeviceId, // Legacy - kept for backward compatibility
  getDeviceFingerprint, // New async fingerprint function
  getFingerprint, // Sync fingerprint getter
  initFingerprint, // Initialize fingerprint
  saveImageToHistory,
  saveUploadToHistory,
  loadUserHistory,
  loadUserHistoryPaginated,
  uploadImageForSharing,
  compressImage,
  compressFile,
  // Analytics exports
  logAnalyticsEvent,
  trackSignUp,
  trackLogin,
  trackAnonymousSignIn,
  trackLogout,
  trackAccountLink,
  trackImageUpload,
  trackObjectImageUpload,
  trackImageDownload,
  trackImageShare,
  trackGenerationStart,
  trackGenerationComplete,
  trackGenerationError,
  trackLimitReached,
  trackObjectDetection,
  trackFeatureUse,
  trackStyleSelect,
  trackColorSelect,
  trackAngleSelect,
  trackLightingSelect,
  trackFurnitureSelect,
  trackRepairsSelect,
  trackDoorsWindowsSelect,
  trackBathroomSelect,
  trackOnboardingStart,
  trackOnboardingStep,
  trackOnboardingComplete,
  trackOnboardingSkip,
  trackSubscriptionModalView,
  trackSubscriptionClick,
  trackWelcomePremiumShow,
  trackHistoryClick,
  trackHistoryLoadMore,
  trackContactFormSubmit,
  trackContactFormSuccess,
  trackCategorySelect,
  trackPageView,
  trackAppOpen
};
