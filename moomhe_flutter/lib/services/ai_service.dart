import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Service for handling AI image generation requests through Firebase
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  final Map<String, StreamSubscription> _activeRequests = {};
  String? _cachedDeviceId;

  /// Get current user, sign in anonymously if needed
  Future<User> ensureSignedIn() async {
    User user;
    
    if (_auth.currentUser != null) {
      debugPrint('🔐 Already signed in - UID: ${_auth.currentUser!.uid}');
      user = _auth.currentUser!;
    } else {
      final userCredential = await _auth.signInAnonymously();
      debugPrint('🔐 Signed in anonymously - UID: ${userCredential.user!.uid}');
      user = userCredential.user!;
    }
    
    // Create/update user record in Firestore (like web app does)
    await createOrUpdateUser(user);
    
    return user;
  }

  /// Create or update user record in Firestore
  /// This is called client-side after authentication (same as web app)
  Future<void> createOrUpdateUser(User user) async {
    // Get device ID
    final deviceId = await getDeviceId();
    
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'lastActive': FieldValue.serverTimestamp(),
      'os': Platform.isAndroid ? 'Android' : 'iOS',
      'deviceBrand': _getDeviceBrand(),
      'appVersion': '1.0.0',
      'deviceId': deviceId,
      'createdAt': user.metadata.creationTime?.toIso8601String(),
      'isAnonymous': user.isAnonymous,
    };

    try {
      await _firestore.collection('users').doc(user.uid).set(
        userData,
        SetOptions(merge: true), // Don't overwrite credits/subscription
      );
      debugPrint('👤 User record created/updated in Firestore (deviceId: $deviceId)');
    } catch (e) {
      debugPrint('❌ Error creating user record: $e');
    }
  }

  String _getDeviceBrand() {
    if (Platform.isIOS) return 'Apple';
    return 'Android Device';
  }

  /// Get unique device ID
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Use Android ID which is unique per app per device
        _cachedDeviceId = androidInfo.id;
        debugPrint('📱 Android Device ID: $_cachedDeviceId');
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // Use identifierForVendor which is unique per vendor per device
        _cachedDeviceId = iosInfo.identifierForVendor ?? 'ios-unknown';
        debugPrint('📱 iOS Device ID: $_cachedDeviceId');
      } else {
        _cachedDeviceId = 'unknown-platform';
      }
    } catch (e) {
      debugPrint('❌ Error getting device ID: $e');
      _cachedDeviceId = 'error-${DateTime.now().millisecondsSinceEpoch}';
    }

    return _cachedDeviceId!;
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Check if current user is anonymous
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  /// Sign in with email and password (for existing accounts)
  /// Signs out any anonymous user first, then signs in with email
  Future<User> signInWithEmail(String email, String password) async {
    try {
      final currentUser = _auth.currentUser;
      
      // If we have an anonymous user, sign out first
      if (currentUser != null && currentUser.isAnonymous) {
        debugPrint('🔐 Signing out anonymous user before email login...');
        await _auth.signOut();
      }
      
      // Sign in with email/password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('🔐 Signed in with email - UID: ${userCredential.user!.uid}');
      await createOrUpdateUser(userCredential.user!);
      return userCredential.user!;
    } catch (e) {
      debugPrint('❌ Error signing in with email: $e');
      rethrow;
    }
  }

  /// Create account with email and password
  /// If user is anonymous, link the credential to the anonymous account
  Future<User> createAccountWithEmail(String email, String password) async {
    try {
      final currentUser = _auth.currentUser;
      
      // If we have an anonymous user, link the credential
      if (currentUser != null && currentUser.isAnonymous) {
        debugPrint('🔐 Linking anonymous account with new email...');
        final credential = EmailAuthProvider.credential(email: email, password: password);
        final result = await currentUser.linkWithCredential(credential);
        debugPrint('🔐 Successfully linked anonymous account with email: ${result.user?.email}');
        await createOrUpdateUser(result.user!);
        return result.user!;
      }
      
      // Create new account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('🔐 Created account with email - UID: ${userCredential.user!.uid}');
      await createOrUpdateUser(userCredential.user!);
      return userCredential.user!;
    } catch (e) {
      debugPrint('❌ Error creating account with email: $e');
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    debugPrint('🔐 User signed out');
  }

  /// Upload image to Firebase Storage and return download URL
  Future<String> uploadImage(String localPath, String userId) async {
    final file = File(localPath);
    final bytes = await file.readAsBytes();
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'upload_$timestamp.jpg';
    final ref = _storage.ref().child('userHistory/$userId/$filename');
    
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    
    return await uploadTask.ref.getDownloadURL();
  }

  /// Upload image and save to user history with type: 'uploaded'
  /// Returns the history entry with id, storageUrl, etc.
  Future<Map<String, dynamic>> uploadImageToHistory(String localPath) async {
    final user = await ensureSignedIn();
    
    final file = File(localPath);
    final bytes = await file.readAsBytes();
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'upload_$timestamp.jpg';
    final thumbnailFilename = 'upload_${timestamp}_thumb.jpg';
    
    // Upload main image
    final ref = _storage.ref().child('userHistory/${user.uid}/$filename');
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final downloadURL = await uploadTask.ref.getDownloadURL();
    
    // For now, use the same URL for thumbnail (could resize in the future)
    final thumbnailURL = downloadURL;
    
    // Create history entry like web version
    final historyEntry = {
      'storageUrl': downloadURL,
      'thumbnailUrl': thumbnailURL,
      'filename': filename,
      'thumbnailFilename': thumbnailFilename,
      'prompt': 'Uploaded image',
      'timestamp': DateTime.now().toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
      'type': 'uploaded',
    };
    
    // Save to Firestore
    final docRef = await _firestore.collection('userHistory').add(historyEntry);
    
    debugPrint('📷 Uploaded image to history - DocID: ${docRef.id}');
    
    return {
      'id': docRef.id,
      ...historyEntry,
      'createdAt': DateTime.now(), // Return actual DateTime for local use
    };
  }

  /// Convert local image file to base64 data URL
  Future<String> imageToBase64(String localPath) async {
    final file = File(localPath);
    final bytes = await file.readAsBytes();
    final base64Data = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64Data';
  }

  /// Convert local image file to generative part format (like web's fileToGenerativePart)
  /// Returns { inlineData: { data: base64, mimeType: 'image/jpeg' } }
  Future<Map<String, dynamic>> fileToGenerativePart(String localPath) async {
    final file = File(localPath);
    final bytes = await file.readAsBytes();
    final base64Data = base64Encode(bytes);
    
    // Determine MIME type
    String mimeType = 'image/jpeg';
    final extension = localPath.toLowerCase().split('.').last;
    if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'gif') {
      mimeType = 'image/gif';
    } else if (extension == 'webp') {
      mimeType = 'image/webp';
    }
    
    return {
      'inlineData': {
        'data': base64Data,
        'mimeType': mimeType,
      }
    };
  }

  /// Copy asset image to temporary file for uploading
  Future<String> copyAssetToTempFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/asset_$timestamp.jpg');
    await tempFile.writeAsBytes(bytes);
    
    debugPrint('📁 Copied asset to temp file: ${tempFile.path}');
    return tempFile.path;
  }

  /// Submit an image generation request
  /// Returns the document ID for tracking
  Future<String> submitImageGenerationRequest({
    required String prompt,
    required String imageData, // Can be URL or base64
    required String deviceId,
    Map<String, dynamic>? objectImageData,
  }) async {
    final user = await ensureSignedIn();
    final authToken = await user.getIdToken();
    
    debugPrint('📤 Submitting request with deviceId: $deviceId');
    
    final requestData = {
      'type': 'request',
      'requestType': 'imageGeneration',
      'userId': user.uid,
      'authToken': authToken,
      'deviceId': deviceId,
      'prompt': prompt,
      'imageData': imageData,
      'originalImageUrl': imageData.startsWith('http') ? imageData : null,
      'objectImageData': objectImageData,
      'isDone': false,
      'isError': false,
      'createdAt': FieldValue.serverTimestamp(),
      'useExperimentalModel': true, // Use GPT-image-1.5
    };
    
    final docRef = await _firestore.collection('userHistory').add(requestData);
    debugPrint('📤 Request submitted - DocID: ${docRef.id}');
    return docRef.id;
  }

  /// Wait for request completion
  /// Returns the result data when isDone becomes true
  Future<Map<String, dynamic>> waitForRequestCompletion(
    String docId, {
    Duration timeout = const Duration(seconds: 120),
  }) async {
    final completer = Completer<Map<String, dynamic>>();
    Timer? timeoutTimer;
    
    // Set timeout
    timeoutTimer = Timer(timeout, () {
      _activeRequests[docId]?.cancel();
      _activeRequests.remove(docId);
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Request timeout after ${timeout.inSeconds} seconds'));
      }
    });
    
    // Listen for document changes
    final subscription = _firestore
        .collection('userHistory')
        .doc(docId)
        .snapshots()
        .listen(
      (snapshot) {
        if (!snapshot.exists) {
          timeoutTimer?.cancel();
          _activeRequests[docId]?.cancel();
          _activeRequests.remove(docId);
          if (!completer.isCompleted) {
            completer.completeError(Exception('Request document not found'));
          }
          return;
        }
        
        final data = snapshot.data()!;
        
        if (data['isDone'] == true) {
          timeoutTimer?.cancel();
          _activeRequests[docId]?.cancel();
          _activeRequests.remove(docId);
          
          if (!completer.isCompleted) {
            if (data['isError'] == true) {
              debugPrint('❌ Request failed - Error: ${data['error']}');
              completer.completeError(Exception(data['error'] ?? 'Request failed'));
            } else {
              debugPrint('✅ Request completed - Result: ${data['result']}');
              completer.complete(data['result'] as Map<String, dynamic>? ?? {});
            }
          }
        }
      },
      onError: (error) {
        timeoutTimer?.cancel();
        _activeRequests[docId]?.cancel();
        _activeRequests.remove(docId);
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );
    
    _activeRequests[docId] = subscription;
    
    return completer.future;
  }

  /// Cancel a request
  void cancelRequest(String docId) {
    _activeRequests[docId]?.cancel();
    _activeRequests.remove(docId);
  }

  /// Process an image with AI
  /// This is the main method to use for image generation
  /// [objectImagePath] - Optional path to an object image to add to the main image
  Future<AIResult> processImage({
    required String imagePath,
    required String prompt,
    String? objectImagePath,
    Function(String status)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('מתחבר לענן... ☁️');
      
      final user = await ensureSignedIn();
      
      // Get device ID (required by server)
      final deviceId = await getDeviceId();
      
      String imageUrl;
      String actualImagePath = imagePath;
      
      // Check if imagePath is already a URL (from previous AI result) or a local file
      if (imagePath.startsWith('http')) {
        debugPrint('📷 Using existing URL: $imagePath');
        imageUrl = imagePath;
        onStatusUpdate?.call('שולח ל-AI... 🤖');
      } else {
        onStatusUpdate?.call('מעלה תמונה... 📤');
        
        // Handle asset images - copy to temp file first
        if (imagePath.startsWith('assets/')) {
          debugPrint('📷 Copying asset to temp file: $imagePath');
          actualImagePath = await copyAssetToTempFile(imagePath);
        }
        
        // Upload local file to storage first
        imageUrl = await uploadImage(actualImagePath, user.uid);
        debugPrint('📷 Uploaded image to: $imageUrl');
        onStatusUpdate?.call('שולח ל-AI... 🤖');
      }
      
      // Process object image if available (like web's fileToGenerativePart)
      Map<String, dynamic>? objectImageData;
      if (objectImagePath != null) {
        debugPrint('🖼️ Processing object image: $objectImagePath');
        onStatusUpdate?.call('מנתח פריט... 🔍');
        objectImageData = await fileToGenerativePart(objectImagePath);
        debugPrint('🖼️ Object image processed successfully');
      }
      
      // Submit the request
      final docId = await submitImageGenerationRequest(
        prompt: prompt,
        imageData: imageUrl,
        deviceId: deviceId,
        objectImageData: objectImageData,
      );
      
      onStatusUpdate?.call('יוצר עיצוב... ✨');
      
      // Wait for completion
      final result = await waitForRequestCompletion(docId);
      
      return AIResult(
        success: true,
        imageUrl: result['storageUrl'] as String?,
        thumbnailUrl: result['thumbnailUrl'] as String?,
        originalImageUrl: result['originalImageUrl'] as String? ?? imageUrl,
        prompt: prompt,
      );
    } catch (e) {
      return AIResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get user's generation count and limit
  Future<UserCreditsInfo> getUserCreditsInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return UserCreditsInfo(count: 0, limit: 0);
      }
      
      final now = DateTime.now();
      final monthYear = '${now.month.toString().padLeft(2, '0')}-${now.year}';
      
      // Get generation count for this month (user-based only, server handles device checks)
      final userGenCountDoc = await _firestore
          .collection('genCount')
          .doc(monthYear)
          .collection('users')
          .doc(user.uid)
          .get();
      
      // Get user profile for credits limit and subscription status
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      final userCount = userGenCountDoc.exists ? (userGenCountDoc.data()?['count'] ?? 0) as int : 0;
      final userData = userDoc.data();
      final limit = userData?['credits'] as int? ?? 0;
      final subscription = userData?['subscription'] as int? ?? 0;
      
      debugPrint('📊 Credits Info: userCount=$userCount, limit=$limit, subscription=$subscription');
      
      return UserCreditsInfo(count: userCount, limit: limit, subscription: subscription);
    } catch (e) {
      debugPrint('❌ Error getting credits info: $e');
      return UserCreditsInfo(count: 0, limit: 0);
    }
  }

  /// Check if user can make more requests
  Future<bool> canMakeRequest() async {
    final info = await getUserCreditsInfo();
    return info.count < info.limit;
  }

  /// Load user history from Firestore
  Future<List<Map<String, dynamic>>> loadUserHistory({int limit = 20}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      
      final query = _firestore
          .collection('userHistory')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      final snapshot = await query.get();
      
      final history = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['isError'] != true) {
          final entry = {
            'id': doc.id,
            ...data,
          };
          
          // Flatten result if exists
          if (data['result'] is Map && data['result']['storageUrl'] != null) {
            entry['storageUrl'] = data['result']['storageUrl'];
            entry['thumbnailUrl'] = data['result']['thumbnailUrl'];
            if (data['result']['originalImageUrl'] != null) {
              entry['originalImageUrl'] = data['result']['originalImageUrl'];
            }
          }
          
          history.add(entry);
        }
      }
      
      return history;
    } catch (e) {
      print('Error loading history: $e');
      return [];
    }
  }

  /// Redeem a coupon code
  /// Returns a map with success/error status and credits info
  Future<Map<String, dynamic>> redeemCoupon(String couponCode) async {
    try {
      final user = await ensureSignedIn();
      final authToken = await user.getIdToken();
      final deviceId = await getDeviceId();
      
      debugPrint('🎟️ Redeeming coupon: $couponCode');
      debugPrint('🎟️ User: ${user.uid}, DeviceID: $deviceId');
      
      // Make HTTP POST request to the cloud function
      final client = HttpClient();
      final request = await client.postUrl(
        Uri.parse('https://us-central1-moomhe-6de30.cloudfunctions.net/redeemCoupon'),
      );
      
      request.headers.set('Content-Type', 'application/json');
      
      final body = jsonEncode({
        'couponCode': couponCode,
        'authToken': authToken,
        'deviceId': deviceId,
      });
      
      request.add(utf8.encode(body));
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      debugPrint('🎟️ Response status: ${response.statusCode}');
      debugPrint('🎟️ Response body: $responseBody');
      
      final result = jsonDecode(responseBody) as Map<String, dynamic>;
      
      if (result['success'] == true) {
        debugPrint('🎟️ Coupon redeemed successfully! Credits added: ${result['creditsAdded']}');
        return {
          'success': true,
          'creditsAdded': result['creditsAdded'] ?? 0,
          'newCredits': result['newCredits'] ?? 0,
          'message': result['message'] ?? 'קופון הופעל בהצלחה!',
        };
      } else {
        debugPrint('🎟️ Coupon redemption failed: ${result['error']}');
        return {
          'success': false,
          'error': result['error'] ?? 'שגיאה במימוש הקופון',
          'errorCode': result['errorCode'],
        };
      }
    } catch (e) {
      debugPrint('🎟️ Coupon redemption error: $e');
      return {
        'success': false,
        'error': 'שגיאה במימוש הקופון. נסה שוב.',
      };
    }
  }
}

/// Result from AI processing
class AIResult {
  final bool success;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? originalImageUrl;
  final String? prompt;
  final String? error;

  AIResult({
    required this.success,
    this.imageUrl,
    this.thumbnailUrl,
    this.originalImageUrl,
    this.prompt,
    this.error,
  });
}

/// User credits information
class UserCreditsInfo {
  final int count;
  final int limit;
  final int subscription;

  UserCreditsInfo({required this.count, required this.limit, this.subscription = 0});
  
  int get remaining => limit - count;
  bool get canGenerate => count < limit;
}
