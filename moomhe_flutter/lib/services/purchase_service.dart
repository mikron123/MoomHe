import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// Subscription tier enum
enum SubscriptionTier {
  none,
  starter,
  pro,
  business,
}

/// Billing period enum
enum BillingPeriod {
  monthly,
  yearly,
}

/// Product IDs for subscriptions
class ProductIds {
  // Monthly subscriptions
  static const String starterMonthly = 'moomhe_starter_monthly';
  static const String proMonthly = 'moomhe_pro_monthly';
  static const String businessMonthly = 'moomhe_business_monthly';

  // Yearly subscriptions
  static const String starterYearly = 'moomhe_starter_yearly';
  static const String proYearly = 'moomhe_pro_yearly';
  static const String businessYearly = 'moomhe_business_yearly';

  static const Set<String> allProductIds = {
    starterMonthly,
    proMonthly,
    businessMonthly,
    starterYearly,
    proYearly,
    businessYearly,
  };

  static const Set<String> monthlyProductIds = {
    starterMonthly,
    proMonthly,
    businessMonthly,
  };

  static const Set<String> yearlyProductIds = {
    starterYearly,
    proYearly,
    businessYearly,
  };

  /// Get credits for a product ID
  static int getCredits(String productId) {
    switch (productId) {
      case starterMonthly:
      case starterYearly:
        return 50;
      case proMonthly:
      case proYearly:
        return 200;
      case businessMonthly:
      case businessYearly:
        return 450;
      default:
        return 0;
    }
  }

  /// Get subscription tier for a product ID
  static SubscriptionTier getTier(String productId) {
    if (productId.contains('starter')) return SubscriptionTier.starter;
    if (productId.contains('pro')) return SubscriptionTier.pro;
    if (productId.contains('business')) return SubscriptionTier.business;
    return SubscriptionTier.none;
  }

  /// Get subscription code (1, 2, 3) for a product ID
  static int getSubscriptionCode(String productId) {
    switch (getTier(productId)) {
      case SubscriptionTier.starter:
        return 1;
      case SubscriptionTier.pro:
        return 2;
      case SubscriptionTier.business:
        return 3;
      case SubscriptionTier.none:
        return 0;
    }
  }

  /// Check if product is yearly
  static bool isYearly(String productId) {
    return yearlyProductIds.contains(productId);
  }
}

/// Purchase status for UI updates
enum PurchaseUiStatus {
  idle,
  loading,
  purchasing,
  success,
  error,
  cancelled,
}

/// Service for handling in-app purchases
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // UUID namespace for converting Firebase UID to UUID (must match server)
  // Using a custom namespace based on "moomhe.app" domain
  static const String _uuidNamespace = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'; // DNS namespace

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isInitialized = false;
  
  // Current subscription for upgrades (Android)
  // We store the actual PurchaseDetails to use for subscription changes
  GooglePlayPurchaseDetails? _currentAndroidPurchase;
  
  // Track if any active subscription was found during restore
  bool _hasActiveStoreSubscription = false;

  // Callbacks for UI updates
  Function(PurchaseUiStatus status, String? message)? onPurchaseStatusChanged;
  Function(List<ProductDetails> products)? onProductsLoaded;

  /// Check if IAP is available
  bool get isAvailable => _isAvailable;

  /// Get loaded products
  List<ProductDetails> get products => _products;

  /// Get product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Get monthly products
  List<ProductDetails> get monthlyProducts {
    return _products
        .where((p) => ProductIds.monthlyProductIds.contains(p.id))
        .toList();
  }

  /// Get yearly products
  List<ProductDetails> get yearlyProducts {
    return _products
        .where((p) => ProductIds.yearlyProductIds.contains(p.id))
        .toList();
  }

  /// Initialize the purchase service
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🛒 Initializing PurchaseService...');

    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      debugPrint('❌ In-app purchases not available');
      _isInitialized = true;
      return;
    }

    debugPrint('✅ In-app purchases available');

    // Set up purchase stream listener
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _onPurchaseStreamDone,
      onError: _onPurchaseStreamError,
    );

    // Load products
    await loadProducts();

    // Restore purchases on init (this also loads current subscription for upgrades)
    await restorePurchases();

    _isInitialized = true;
    debugPrint('🛒 PurchaseService initialized');
  }

  /// Load available products from the store
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    debugPrint('📦 Loading products...');
    onPurchaseStatusChanged?.call(PurchaseUiStatus.loading, null);

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(ProductIds.allProductIds);

      if (response.error != null) {
        debugPrint('❌ Error loading products: ${response.error!.message}');
        onPurchaseStatusChanged?.call(
            PurchaseUiStatus.error, response.error!.message);
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('⚠️ Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      debugPrint('✅ Loaded ${_products.length} products');

      for (final product in _products) {
        debugPrint('  - ${product.id}: ${product.price}');
        debugPrint('    title: ${product.title}');
        debugPrint('    description: ${product.description}');
      }

      onProductsLoaded?.call(_products);
      onPurchaseStatusChanged?.call(PurchaseUiStatus.idle, null);
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      onPurchaseStatusChanged?.call(PurchaseUiStatus.error, e.toString());
    }
  }

  /// Purchase a subscription (handles new purchases and upgrades)
  Future<bool> purchaseSubscription(String productId) async {
    if (!_isAvailable) {
      onPurchaseStatusChanged?.call(
          PurchaseUiStatus.error, 'In-app purchases not available');
      return false;
    }

    final product = getProduct(productId);
    if (product == null) {
      onPurchaseStatusChanged?.call(
          PurchaseUiStatus.error, 'Product not found: $productId');
      return false;
    }

    debugPrint('🛒 Starting purchase for: $productId');
    onPurchaseStatusChanged?.call(PurchaseUiStatus.purchasing, null);

    try {
      // Get current user ID for obfuscation
      final userId = _auth.currentUser?.uid ?? '';
      
      // Check if this is an upgrade (user has existing Android subscription)
      final isAndroidUpgrade = Platform.isAndroid && 
                               _currentAndroidPurchase != null && 
                               _currentAndroidPurchase!.productID != productId;
      
      if (isAndroidUpgrade) {
        debugPrint('🔄 This is a subscription upgrade from ${_currentAndroidPurchase!.productID} to $productId');
      }

      late PurchaseParam purchaseParam;

      // Use platform-specific purchase param
      if (Platform.isAndroid) {
        if (isAndroidUpgrade && _currentAndroidPurchase != null) {
          // For upgrades on Android, specify the old subscription
          purchaseParam = GooglePlayPurchaseParam(
            productDetails: product,
            applicationUserName: userId,
            changeSubscriptionParam: ChangeSubscriptionParam(
              oldPurchaseDetails: _currentAndroidPurchase!,
              replacementMode: ReplacementMode.withTimeProration,
            ),
          );
          debugPrint('🔄 Using upgrade purchase param with proration');
        } else {
          // New purchase on Android
          purchaseParam = GooglePlayPurchaseParam(
            productDetails: product,
            applicationUserName: userId,
          );
        }
      } else {
        // iOS uses standard purchase param
        // Apple handles upgrades automatically within subscription groups
        // IMPORTANT: applicationUserName must be a valid UUID for appAccountToken to work
        final uuidForApple = _firebaseUidToUuid(userId);
        debugPrint('🍎 iOS purchase - Firebase UID: $userId');
        debugPrint('🍎 iOS purchase - UUID for appAccountToken: $uuidForApple');
        
        // Store the UUID in the user's own document (for webhook lookup)
        // This should work with existing Firestore rules
        try {
          await _firestore.collection('users').doc(userId).set({
            'appleUuid': uuidForApple,
            'appleUuidUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          debugPrint('✅ Stored appleUuid in user document');
        } catch (e) {
          // Non-blocking - webhook has fallback methods
          debugPrint('⚠️ Could not store appleUuid in user document: $e');
        }
        
        purchaseParam = PurchaseParam(
          productDetails: product,
          applicationUserName: uuidForApple,
        );
      }

      debugPrint('🛒 Calling buyNonConsumable for product: ${product.id}');
      debugPrint('🛒 Product details - title: ${product.title}, price: ${product.price}');
      debugPrint('🛒 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      debugPrint('🛒 User ID for purchase: $userId');
      
      final bool success =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      debugPrint('🛒 buyNonConsumable returned: $success');
      
      if (!success) {
        debugPrint('🚫 Purchase not initiated (user likely cancelled or dialog dismissed)');
        // Treat as cancellation, not error - user probably dismissed the dialog
        onPurchaseStatusChanged?.call(PurchaseUiStatus.cancelled, null);
        return false;
      }

      debugPrint('✅ Purchase initiated');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Purchase error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      // Check if it's a user cancellation
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('usercancelled') || 
          errorString.contains('user cancelled') ||
          errorString.contains('cancelled') ||
          errorString.contains('canceled') ||
          errorString.contains('storekit') && errorString.contains('2')) {
        debugPrint('🚫 User cancelled the purchase');
        onPurchaseStatusChanged?.call(PurchaseUiStatus.cancelled, null);
      } else {
        onPurchaseStatusChanged?.call(PurchaseUiStatus.error, e.toString());
      }
      return false;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    debugPrint('🔄 Restoring purchases...');
    onPurchaseStatusChanged?.call(PurchaseUiStatus.loading, 'Restoring...');
    
    // Reset flag before restore
    _hasActiveStoreSubscription = false;

    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('✅ Restore initiated');
      // Reset to idle after initiating restore
      // Actual restore results will come through the purchase stream
      onPurchaseStatusChanged?.call(PurchaseUiStatus.idle, null);
      
      // Wait a bit for restore to complete, then verify subscription status
      Future.delayed(const Duration(seconds: 3), () {
        _verifySubscriptionStatus();
      });
    } catch (e) {
      debugPrint('❌ Restore error: $e');
      onPurchaseStatusChanged?.call(PurchaseUiStatus.error, e.toString());
    }
  }
  
  /// Verify that Firestore subscription matches store subscription
  /// Called after restore to catch expired subscriptions that webhooks missed
  Future<void> _verifySubscriptionStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Get Firestore subscription status
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      
      if (userData == null) return;
      
      final firestoreSubscription = userData['subscription'] as int? ?? 0;
      
      // If Firestore says user has subscription but store says no active subscription
      if (firestoreSubscription > 0 && !_hasActiveStoreSubscription) {
        debugPrint('⚠️ Subscription mismatch! Firestore: $firestoreSubscription, Store: none');
        debugPrint('📤 Calling syncSubscription to verify with server...');
        
        // Call server to verify and potentially reset subscription
        await _syncSubscriptionWithServer(user.uid);
      } else if (firestoreSubscription > 0 && _hasActiveStoreSubscription) {
        debugPrint('✅ Subscription verified: Firestore and Store match');
      } else {
        debugPrint('ℹ️ No subscription in Firestore (free user)');
      }
    } catch (e) {
      debugPrint('❌ Error verifying subscription status: $e');
    }
  }
  
  /// Call server to verify subscription and sync status
  Future<void> _syncSubscriptionWithServer(String userId) async {
    try {
      final authToken = await _auth.currentUser?.getIdToken();
      if (authToken == null) return;
      
      final response = await http.post(
        Uri.parse('https://us-central1-moomhe-6de30.cloudfunctions.net/syncSubscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'authToken': authToken,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('📥 Subscription sync response: ${data['message']}');
        if (data['subscriptionReset'] == true) {
          debugPrint('⚠️ Subscription was reset to free tier');
        }
      } else {
        debugPrint('❌ Sync request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error syncing subscription: $e');
    }
  }

  /// Handle purchase updates from the stream
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    debugPrint('📬 Received ${purchaseDetailsList.length} purchase updates');

    // Track if any verification succeeded (for restored purchases that come in batches)
    bool anyVerificationSucceeded = false;
    bool anyVerificationFailed = false;
    bool hasPendingOrCancelled = false;

    for (final purchaseDetails in purchaseDetailsList) {
      debugPrint(
          '  - ${purchaseDetails.productID}: ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          hasPendingOrCancelled = true;
          onPurchaseStatusChanged?.call(
              PurchaseUiStatus.purchasing, 'Processing...');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Mark that we found an active subscription in the store
          if (ProductIds.allProductIds.contains(purchaseDetails.productID)) {
            _hasActiveStoreSubscription = true;
            debugPrint('✅ Found active store subscription: ${purchaseDetails.productID}');
          }
          
          // Store Android purchase details for future upgrades
          if (Platform.isAndroid && purchaseDetails is GooglePlayPurchaseDetails) {
            _currentAndroidPurchase = purchaseDetails;
            debugPrint('📦 Stored Android purchase for future upgrades: ${purchaseDetails.productID}');
          }
          
          // Verify and deliver the purchase
          final success = await _verifyAndDeliverPurchase(purchaseDetails);
          if (success) {
            anyVerificationSucceeded = true;
          } else {
            anyVerificationFailed = true;
          }
          break;

        case PurchaseStatus.error:
          debugPrint('❌ Purchase error: ${purchaseDetails.error?.message}');
          debugPrint('❌ Error code: ${purchaseDetails.error?.code}');
          debugPrint('❌ Error details: ${purchaseDetails.error?.details}');
          debugPrint('❌ Product ID: ${purchaseDetails.productID}');
          hasPendingOrCancelled = true;
          onPurchaseStatusChanged?.call(
              PurchaseUiStatus.error, purchaseDetails.error?.message ?? 'Purchase failed');
          break;

        case PurchaseStatus.canceled:
          debugPrint('🚫 Purchase cancelled');
          debugPrint('🚫 Product: ${purchaseDetails.productID}');
          hasPendingOrCancelled = true;
          onPurchaseStatusChanged?.call(PurchaseUiStatus.cancelled, null);
          break;
      }

      // Complete pending purchases
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
        debugPrint('✅ Purchase completed: ${purchaseDetails.productID}');
      }
    }
    
    // After processing all purchases, update UI status
    // Only show error if ALL verifications failed (not just some)
    if (anyVerificationSucceeded) {
      debugPrint('🎉 At least one verification succeeded');
      onPurchaseStatusChanged?.call(PurchaseUiStatus.success, null);
    } else if (anyVerificationFailed && !hasPendingOrCancelled) {
      debugPrint('❌ All verifications failed');
      onPurchaseStatusChanged?.call(PurchaseUiStatus.error, 'Verification failed');
    }
  }

  /// Verify purchase and update user subscription via Cloud Function
  Future<bool> _verifyAndDeliverPurchase(PurchaseDetails purchaseDetails) async {
    debugPrint('🔐 Verifying purchase: ${purchaseDetails.productID}');

    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ No user signed in');
        return false;
      }

      // Get verification data based on platform
      String? verificationData;
      String platform;
      String? originalTransactionId;

      if (Platform.isAndroid) {
        platform = 'android';
        final androidDetails =
            purchaseDetails as GooglePlayPurchaseDetails;
        verificationData = androidDetails.billingClientPurchase.purchaseToken;
      } else if (Platform.isIOS) {
        platform = 'ios';
        verificationData = purchaseDetails.verificationData.serverVerificationData;
        
        // Handle both StoreKit 1 (AppStorePurchaseDetails) and StoreKit 2 (SK2PurchaseDetails)
        if (purchaseDetails is AppStorePurchaseDetails) {
          // StoreKit 1
          originalTransactionId = purchaseDetails.skPaymentTransaction.originalTransaction?.transactionIdentifier 
              ?? purchaseDetails.skPaymentTransaction.transactionIdentifier;
          debugPrint('🍎 iOS (SK1) originalTransactionId: $originalTransactionId');
        } else {
          // StoreKit 2 (SK2PurchaseDetails) or any other type - use purchaseID
          originalTransactionId = purchaseDetails.purchaseID;
          debugPrint('🍎 iOS (${purchaseDetails.runtimeType}) originalTransactionId: $originalTransactionId');
        }
      } else {
        debugPrint('❌ Unsupported platform');
        return false;
      }

      // Save purchase to Firestore for server-side verification (webhook backup)
      final purchaseId = purchaseDetails.purchaseID ?? DateTime.now().toIso8601String();
      
      // Check if purchase already exists (for restores) - don't try to update if it does
      // Firestore rules block updates to purchases collection
      bool purchaseExists = false;
      try {
        final existingPurchase = await _firestore.collection('purchases').doc(purchaseId).get();
        purchaseExists = existingPurchase.exists;
      } catch (e) {
        // Permission denied means document exists but we can't read it (different user)
        // or some other issue - just skip the write to be safe
        debugPrint('⚠️ Could not check purchase existence: $e');
        purchaseExists = true; // Assume it exists to skip write
      }
      
      if (!purchaseExists) {
        try {
          final purchaseRecord = {
            'userId': user.uid,
            'productId': purchaseDetails.productID,
            'purchaseId': purchaseId,
            'transactionDate': purchaseDetails.transactionDate,
            'verificationData': verificationData,
            'platform': platform,
            'status': purchaseDetails.status.toString(),
            'createdAt': FieldValue.serverTimestamp(),
            'verified': false, // Will be set to true by verifyPurchase endpoint
          };
          
          // For iOS, also store originalTransactionId
          if (platform == 'ios' && originalTransactionId != null) {
            purchaseRecord['originalTransactionId'] = originalTransactionId;
          }

          await _firestore
              .collection('purchases')
              .doc(purchaseId)
              .set(purchaseRecord);

          debugPrint('✅ Purchase record saved to Firestore');
        } catch (e) {
          // Non-fatal - server verification will still work
          debugPrint('⚠️ Could not save purchase record: $e');
        }
      } else {
        debugPrint('ℹ️ Purchase record already exists, skipping Firestore write');
      }

      // Call verifyPurchase Cloud Function to update subscription
      // (Firestore rules prevent client from updating credits/subscription directly)
      final authToken = await user.getIdToken();
      
      final requestBody = {
        'authToken': authToken,
        'productId': purchaseDetails.productID,
        'purchaseId': purchaseId,
        'platform': platform,
        'verificationData': verificationData,
      };
      
      // Include originalTransactionId for iOS
      if (platform == 'ios' && originalTransactionId != null) {
        requestBody['originalTransactionId'] = originalTransactionId;
      }
      
      final response = await http.post(
        Uri.parse('https://us-central1-moomhe-6de30.cloudfunctions.net/verifyPurchase'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          debugPrint('✅ Purchase verified by server: ${responseData['subscription']} subscription, ${responseData['credits']} credits');
          return true;
        } else {
          debugPrint('❌ Server verification failed: ${responseData['error']}');
          return false;
        }
      } else {
        debugPrint('❌ Server verification request failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error verifying purchase: $e');
      return false;
    }
  }

  void _onPurchaseStreamDone() {
    debugPrint('📬 Purchase stream done');
    _subscription?.cancel();
  }

  void _onPurchaseStreamError(dynamic error) {
    debugPrint('❌ Purchase stream error: $error');
    onPurchaseStatusChanged?.call(PurchaseUiStatus.error, error.toString());
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _isInitialized = false;
    debugPrint('🛒 PurchaseService disposed');
  }

  /// Get user's current subscription info from Firestore
  Future<SubscriptionInfo> getCurrentSubscription() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return SubscriptionInfo.none();
      }

      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data();

      if (data == null) {
        return SubscriptionInfo.none();
      }

      final subscription = data['subscription'] as int? ?? 0;
      final credits = data['credits'] as int? ?? 0;
      final productId = data['subscriptionProductId'] as String?;

      return SubscriptionInfo(
        tier: _getTierFromCode(subscription),
        credits: credits,
        productId: productId,
        isActive: subscription > 0,
      );
    } catch (e) {
      debugPrint('❌ Error getting subscription: $e');
      return SubscriptionInfo.none();
    }
  }

  SubscriptionTier _getTierFromCode(int code) {
    switch (code) {
      case 1:
        return SubscriptionTier.starter;
      case 2:
        return SubscriptionTier.pro;
      case 3:
        return SubscriptionTier.business;
      default:
        return SubscriptionTier.none;
    }
  }
  
  /// Convert Firebase UID to a valid UUID v5 format for iOS appAccountToken
  /// Apple requires appAccountToken to be a valid lowercase UUID with hyphens
  /// This creates a deterministic UUID from the Firebase UID
  String _firebaseUidToUuid(String uid) {
    // Create a UUID v5 by hashing namespace + name with SHA-1
    // Format: xxxxxxxx-xxxx-5xxx-yxxx-xxxxxxxxxxxx
    // where y is 8, 9, a, or b
    
    // Parse namespace UUID to bytes
    final namespaceBytes = _parseUuid(_uuidNamespace);
    
    // Combine namespace bytes + uid bytes
    final nameBytes = utf8.encode(uid);
    final combined = [...namespaceBytes, ...nameBytes];
    
    // SHA-1 hash
    final hash = sha1.convert(combined).bytes;
    
    // Build UUID v5 from hash
    // Set version (4 bits) to 5 (0101)
    final version = (hash[6] & 0x0f) | 0x50;
    // Set variant (2 bits) to 10xx
    final variant = (hash[8] & 0x3f) | 0x80;
    
    // Format as UUID string
    final uuid = '${_byteToHex(hash[0])}${_byteToHex(hash[1])}${_byteToHex(hash[2])}${_byteToHex(hash[3])}-'
        '${_byteToHex(hash[4])}${_byteToHex(hash[5])}-'
        '${_byteToHex(version)}${_byteToHex(hash[7])}-'
        '${_byteToHex(variant)}${_byteToHex(hash[9])}-'
        '${_byteToHex(hash[10])}${_byteToHex(hash[11])}${_byteToHex(hash[12])}${_byteToHex(hash[13])}${_byteToHex(hash[14])}${_byteToHex(hash[15])}';
    
    return uuid.toLowerCase();
  }
  
  List<int> _parseUuid(String uuid) {
    final hex = uuid.replaceAll('-', '');
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }
  
  String _byteToHex(int byte) {
    return byte.toRadixString(16).padLeft(2, '0');
  }
}

/// Subscription info model
class SubscriptionInfo {
  final SubscriptionTier tier;
  final int credits;
  final String? productId;
  final bool isActive;

  SubscriptionInfo({
    required this.tier,
    required this.credits,
    this.productId,
    required this.isActive,
  });

  factory SubscriptionInfo.none() {
    return SubscriptionInfo(
      tier: SubscriptionTier.none,
      credits: 0,
      productId: null,
      isActive: false,
    );
  }

  String get tierName {
    switch (tier) {
      case SubscriptionTier.starter:
        return 'Starter';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.business:
        return 'Business';
      case SubscriptionTier.none:
        return 'Free';
    }
  }
}
