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
        purchaseParam = PurchaseParam(
          productDetails: product,
          applicationUserName: userId,
        );
      }

      debugPrint('🛒 Calling buyNonConsumable for product: ${product.id}');
      debugPrint('🛒 Product details - title: ${product.title}, price: ${product.price}');
      
      final bool success =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      debugPrint('🛒 buyNonConsumable returned: $success');
      
      if (!success) {
        debugPrint('❌ Purchase initiation failed - this usually means:');
        debugPrint('   1. Not running release build (flutter run --release)');
        debugPrint('   2. Account not added as License Tester in Play Console');
        debugPrint('   3. App not uploaded to Internal Testing track');
        onPurchaseStatusChanged?.call(
            PurchaseUiStatus.error, 'Failed to initiate purchase');
        return false;
      }

      debugPrint('✅ Purchase initiated');
      return true;
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      onPurchaseStatusChanged?.call(PurchaseUiStatus.error, e.toString());
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

    for (final purchaseDetails in purchaseDetailsList) {
      debugPrint(
          '  - ${purchaseDetails.productID}: ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
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
            onPurchaseStatusChanged?.call(PurchaseUiStatus.success, null);
          } else {
            onPurchaseStatusChanged?.call(
                PurchaseUiStatus.error, 'Verification failed');
          }
          break;

        case PurchaseStatus.error:
          debugPrint('❌ Purchase error: ${purchaseDetails.error?.message}');
          debugPrint('❌ Error code: ${purchaseDetails.error?.code}');
          debugPrint('❌ Error details: ${purchaseDetails.error?.details}');
          debugPrint('❌ Product ID: ${purchaseDetails.productID}');
          // Common error codes:
          // - BillingResponse.itemUnavailable: Product not available for purchase
          // - BillingResponse.itemAlreadyOwned: User already owns this subscription
          onPurchaseStatusChanged?.call(
              PurchaseUiStatus.error, purchaseDetails.error?.message ?? 'Purchase failed');
          break;

        case PurchaseStatus.canceled:
          debugPrint('🚫 Purchase cancelled');
          onPurchaseStatusChanged?.call(PurchaseUiStatus.cancelled, null);
          break;
      }

      // Complete pending purchases
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
        debugPrint('✅ Purchase completed: ${purchaseDetails.productID}');
      }
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

      if (Platform.isAndroid) {
        platform = 'android';
        final androidDetails =
            purchaseDetails as GooglePlayPurchaseDetails;
        verificationData = androidDetails.billingClientPurchase.purchaseToken;
      } else if (Platform.isIOS) {
        platform = 'ios';
        final iosDetails = purchaseDetails as AppStorePurchaseDetails;
        verificationData = iosDetails.verificationData.serverVerificationData;
      } else {
        debugPrint('❌ Unsupported platform');
        return false;
      }

      // Save purchase to Firestore for server-side verification (webhook backup)
      final purchaseId = purchaseDetails.purchaseID ?? DateTime.now().toIso8601String();
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

      await _firestore
          .collection('purchases')
          .doc(purchaseId)
          .set(purchaseRecord);

      debugPrint('✅ Purchase record saved to Firestore');

      // Call verifyPurchase Cloud Function to update subscription
      // (Firestore rules prevent client from updating credits/subscription directly)
      final authToken = await user.getIdToken();
      
      final response = await http.post(
        Uri.parse('https://us-central1-moomhe-6de30.cloudfunctions.net/verifyPurchase'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'authToken': authToken,
          'productId': purchaseDetails.productID,
          'purchaseId': purchaseId,
          'platform': platform,
          'verificationData': verificationData,
        }),
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
