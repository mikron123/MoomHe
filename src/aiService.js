import { db } from './firebase.js';
import { doc, setDoc, getDoc, onSnapshot, collection } from 'firebase/firestore';

// Service for handling AI requests through Firebase Functions
class AIService {
  constructor() {
    this.activeRequests = new Map(); // Track active requests
  }

  // Submit a request for image generation
  async submitImageGenerationRequest(user, prompt, imageData, objectImageData = null) {
    try {
      // Get user's auth token
      const authToken = await user.getIdToken();
      
      // Create request document
      const requestData = {
        type: 'request',
        requestType: 'imageGeneration',
        userId: user.uid,
        authToken: authToken,
        prompt: prompt,
        imageData: imageData,
        objectImageData: objectImageData,
        isDone: false,
        isError: false,
        createdAt: new Date(),
        timestamp: new Date().toLocaleString('he-IL')
      };

      // Create document reference
      const docRef = doc(collection(db, 'userHistory'));
      await setDoc(docRef, requestData);

      // Return the document ID for tracking
      return docRef.id;
    } catch (error) {
      console.error('Error submitting image generation request:', error);
      throw error;
    }
  }

  // Submit a request for object detection (HTTP function)
  async submitObjectDetectionRequest(user, imageData, historyId = null) {
    try {
      // Get user's auth token
      const authToken = await user.getIdToken();
      
      // Call the HTTP function directly
      const response = await fetch('https://us-central1-moomhe-6de30.cloudfunctions.net/detectObjects', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          imageData: imageData,
          authToken: authToken,
          historyId: historyId
        })
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Object detection failed');
      }
      
      const result = await response.json();
      
      if (!result.success) {
        throw new Error(result.error || 'Object detection failed');
      }
      
      return result;
    } catch (error) {
      console.error('Error submitting object detection request:', error);
      throw error;
    }
  }

  // Wait for request completion
  async waitForRequestCompletion(docId, timeout = 60000) {
    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        this.activeRequests.delete(docId);
        reject(new Error('Request timeout'));
      }, timeout);

      // Listen for document changes
      const unsubscribe = onSnapshot(
        doc(db, 'userHistory', docId),
        (docSnapshot) => {
          if (!docSnapshot.exists()) {
            clearTimeout(timeoutId);
            unsubscribe();
            reject(new Error('Request document not found'));
            return;
          }

          const data = docSnapshot.data();
          
          if (data.isDone) {
            clearTimeout(timeoutId);
            unsubscribe();
            this.activeRequests.delete(docId);
            
            if (data.isError) {
              reject(new Error(data.error || 'Request failed'));
            } else {
              resolve(data.result);
            }
          }
        },
        (error) => {
          clearTimeout(timeoutId);
          unsubscribe();
          this.activeRequests.delete(docId);
          reject(error);
        }
      );

      // Store the unsubscribe function
      this.activeRequests.set(docId, unsubscribe);
    });
  }

  // Cancel a request (cleanup)
  cancelRequest(docId) {
    const unsubscribe = this.activeRequests.get(docId);
    if (unsubscribe) {
      unsubscribe();
      this.activeRequests.delete(docId);
    }
  }

  // Get user's generation count for current month
  async getUserGenerationCount(userId) {
    try {
      const now = new Date();
      const monthYear = `${String(now.getMonth() + 1).padStart(2, '0')}-${now.getFullYear()}`;
      const genCountRef = doc(db, 'genCount', monthYear, 'users', userId);
      const genCountDoc = await getDoc(genCountRef);
      
      if (genCountDoc.exists()) {
        const data = genCountDoc.data();
        return {
          count: data.count || 0,
          limit: data.limit || 50
        };
      } else {
        return { count: 0, limit: 50 };
      }
    } catch (error) {
      console.error('Error getting user generation count:', error);
      return { count: 0, limit: 50 };
    }
  }

  // Check if user can make more requests
  async canMakeRequest(userId) {
    const { count, limit } = await this.getUserGenerationCount(userId);
    return count < limit;
  }
}

// Export singleton instance
export const aiService = new AIService();
