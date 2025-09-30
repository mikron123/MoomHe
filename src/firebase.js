// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAI, getGenerativeModel, GoogleAIBackend, ResponseModality } from "firebase/ai";
import { getAuth, signInAnonymously, onAuthStateChanged } from "firebase/auth";
import { getFirestore, doc, setDoc, getDoc, collection, query, orderBy, where, getDocs, limit, startAfter } from "firebase/firestore";
import { getStorage, ref, uploadBytes, getDownloadURL } from "firebase/storage";

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
const model = getGenerativeModel(ai, {
  model: "gemini-2.5-flash-image-preview",
  // Configure the model to respond with text and images (required)
  generationConfig: {
    responseModalities: [ResponseModality.TEXT, ResponseModality.IMAGE],
  },
});

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

// User management functions
async function createOrUpdateUser(user) {
  const userData = {
    uid: user.uid,
    lastActive: new Date(),
    os: navigator.platform,
    userAgent: navigator.userAgent,
    createdAt: user.metadata.creationTime,
    isAnonymous: user.isAnonymous
  };

  try {
    await setDoc(doc(db, 'users', user.uid), userData, { merge: true });
    return userData;
  } catch (error) {
    console.error('Error creating/updating user:', error);
    throw error;
  }
}

// Storage functions
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
    // Convert data URL to blob
    const response = await fetch(imageDataUrl);
    const blob = await response.blob();
    
    // Create thumbnail with error handling
    let thumbnailBlob;
    try {
      thumbnailBlob = await createThumbnail(imageDataUrl);
    } catch (thumbnailError) {
      console.warn('Failed to create thumbnail, using original image:', thumbnailError);
      // Fallback: use the original image as thumbnail (not ideal but functional)
      thumbnailBlob = blob;
    }
    
    // Create unique filename
    const timestamp = Date.now();
    const filename = `image_${timestamp}.jpg`;
    const thumbnailFilename = `thumbnail_${timestamp}.jpg`;
    
    // Upload full resolution image
    const storageRef = ref(storage, `userHistory/${userId}/${filename}`);
    const snapshot = await uploadBytes(storageRef, blob);
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
    // Convert file to data URL for thumbnail generation
    const dataUrl = await new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.readAsDataURL(file);
    });
    
    // Create thumbnail with error handling
    let thumbnailBlob;
    try {
      thumbnailBlob = await createThumbnail(dataUrl);
    } catch (thumbnailError) {
      console.warn('Failed to create thumbnail, using original image:', thumbnailError);
      // Fallback: use the original file as thumbnail
      thumbnailBlob = file;
    }
    
    // Create unique filename
    const timestamp = Date.now();
    const fileExtension = file.name.split('.').pop() || 'jpg';
    const filename = `upload_${timestamp}.${fileExtension}`;
    const thumbnailFilename = `upload_thumbnail_${timestamp}.jpg`;
    
    // Upload full resolution image
    const storageRef = ref(storage, `userHistory/${userId}/${filename}`);
    const snapshot = await uploadBytes(storageRef, file);
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
    // Convert data URL to blob
    const response = await fetch(imageDataUrl);
    const blob = await response.blob();
    
    // Create temporary filename
    const timestamp = Date.now();
    const filename = `temp_${timestamp}.jpg`;
    
    // Upload to temporary path
    const storageRef = ref(storage, `temp/${userId}/${filename}`);
    const snapshot = await uploadBytes(storageRef, blob);
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


export { 
  app, 
  analytics, 
  model, 
  fileToGenerativePart, 
  urlToFile,
  auth,
  db,
  storage,
  signInUser,
  createOrUpdateUser,
  saveImageToHistory,
  saveUploadToHistory,
  loadUserHistory,
  loadUserHistoryPaginated,
  uploadImageForSharing
};
