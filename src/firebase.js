// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAI, getGenerativeModel, GoogleAIBackend, ResponseModality } from "firebase/ai";
import { getAuth, signInAnonymously, onAuthStateChanged } from "firebase/auth";
import { getFirestore, doc, setDoc, getDoc, collection, query, orderBy, getDocs } from "firebase/firestore";
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
async function uploadImageToStorage(userId, imageDataUrl, prompt) {
  try {
    // Convert data URL to blob
    const response = await fetch(imageDataUrl);
    const blob = await response.blob();
    
    // Create unique filename
    const timestamp = Date.now();
    const filename = `image_${timestamp}.jpg`;
    const storageRef = ref(storage, `userHistory/${userId}/${filename}`);
    
    // Upload the file
    const snapshot = await uploadBytes(storageRef, blob);
    
    // Get download URL
    const downloadURL = await getDownloadURL(snapshot.ref);
    
    return { downloadURL, filename, timestamp };
  } catch (error) {
    console.error('Error uploading image:', error);
    throw error;
  }
}

async function uploadImageToUserUploads(userId, file) {
  try {
    // Create unique filename
    const timestamp = Date.now();
    const fileExtension = file.name.split('.').pop() || 'jpg';
    const filename = `upload_${timestamp}.${fileExtension}`;
    const storageRef = ref(storage, `userUploads/${userId}/${filename}`);
    
    // Upload the file
    const snapshot = await uploadBytes(storageRef, file);
    
    // Get download URL
    const downloadURL = await getDownloadURL(snapshot.ref);
    
    return { downloadURL, filename, timestamp };
  } catch (error) {
    console.error('Error uploading user image:', error);
    throw error;
  }
}

// Firestore functions
async function saveImageToHistory(userId, imageData) {
  try {
    const { downloadURL, filename, timestamp } = await uploadImageToStorage(userId, imageData.imageUrl, imageData.prompt);
    
    const historyEntry = {
      id: imageData.id,
      storageUrl: downloadURL,
      filename: filename,
      prompt: imageData.prompt,
      timestamp: imageData.timestamp,
      createdAt: new Date(),
      userId: userId
    };
    
    // Store directly under userHistory/{imageUid}/
    await setDoc(doc(db, 'userHistory', imageData.id), historyEntry);
    return historyEntry;
  } catch (error) {
    console.error('Error saving image to history:', error);
    throw error;
  }
}

async function loadUserHistory(userId) {
  try {
    const historyRef = collection(db, 'userHistory');
    const q = query(historyRef, orderBy('createdAt', 'desc'));
    const querySnapshot = await getDocs(q);
    
    const history = [];
    querySnapshot.forEach((doc) => {
      const data = doc.data();
      // Only include records that belong to the current user
      if (data.userId === userId) {
        history.push({
          id: doc.id,
          ...data
        });
      }
    });
    
    return history;
  } catch (error) {
    console.error('Error loading user history:', error);
    return [];
  }
}

// User uploads functions
async function saveUploadToUserUploads(userId, uploadData) {
  try {
    const { downloadURL, filename, timestamp } = await uploadImageToUserUploads(userId, uploadData.file);
    
    const uploadEntry = {
      id: uploadData.id,
      storageUrl: downloadURL,
      filename: filename,
      originalName: uploadData.file.name,
      fileSize: uploadData.file.size,
      fileType: uploadData.file.type,
      timestamp: uploadData.timestamp,
      createdAt: new Date(),
      userId: userId
    };
    
    // Store directly under userUploads/{uploadUid}/
    await setDoc(doc(db, 'userUploads', uploadData.id), uploadEntry);
    return uploadEntry;
  } catch (error) {
    console.error('Error saving upload to userUploads:', error);
    throw error;
  }
}

async function loadUserUploads(userId) {
  try {
    const uploadsRef = collection(db, 'userUploads');
    const q = query(uploadsRef, orderBy('createdAt', 'desc'));
    const querySnapshot = await getDocs(q);
    
    const uploads = [];
    querySnapshot.forEach((doc) => {
      const data = doc.data();
      // Only include records that belong to the current user
      if (data.userId === userId) {
        uploads.push({
          id: doc.id,
          ...data
        });
      }
    });
    
    return uploads;
  } catch (error) {
    console.error('Error loading user uploads:', error);
    return [];
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
  loadUserHistory,
  saveUploadToUserUploads,
  loadUserUploads
};
