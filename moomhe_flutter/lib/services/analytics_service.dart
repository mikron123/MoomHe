import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking analytics events throughout the app
/// Uses Firebase Analytics under the hood
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ============================================
  // USER PROPERTIES
  // ============================================

  /// Set user ID for analytics
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
    debugPrint('📊 Analytics: Set user ID: $userId');
  }

  /// Set subscription tier user property
  Future<void> setSubscriptionTier(int tier) async {
    final tierName = switch (tier) {
      1 => 'starter',
      2 => 'pro',
      3 => 'business',
      _ => 'free',
    };
    await _analytics.setUserProperty(name: 'subscription_tier', value: tierName);
    debugPrint('📊 Analytics: Set subscription tier: $tierName');
  }

  /// Set user login status
  Future<void> setLoginStatus(bool isLoggedIn) async {
    await _analytics.setUserProperty(
      name: 'login_status',
      value: isLoggedIn ? 'logged_in' : 'anonymous',
    );
    debugPrint('📊 Analytics: Set login status: ${isLoggedIn ? 'logged_in' : 'anonymous'}');
  }

  /// Set user locale
  Future<void> setUserLocale(String locale) async {
    await _analytics.setUserProperty(name: 'app_locale', value: locale);
    debugPrint('📊 Analytics: Set locale: $locale');
  }

  // ============================================
  // SCREEN TRACKING
  // ============================================

  /// Log screen view
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    debugPrint('📊 Analytics: Screen view: $screenName');
  }

  // ============================================
  // APP LIFECYCLE EVENTS
  // ============================================

  /// Log app open event
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
    debugPrint('📊 Analytics: App opened');
  }

  /// Log first app open (shown onboarding)
  Future<void> logFirstOpen() async {
    await _analytics.logEvent(name: 'first_open_onboarding');
    debugPrint('📊 Analytics: First open with onboarding');
  }

  /// Log onboarding completed
  Future<void> logOnboardingComplete() async {
    await _analytics.logEvent(name: 'onboarding_complete');
    debugPrint('📊 Analytics: Onboarding completed');
  }

  /// Log onboarding skipped
  Future<void> logOnboardingSkipped({int? stepNumber}) async {
    await _analytics.logEvent(
      name: 'onboarding_skipped',
      parameters: stepNumber != null ? {'step_number': stepNumber} : null,
    );
    debugPrint('📊 Analytics: Onboarding skipped at step $stepNumber');
  }

  // ============================================
  // IMAGE EVENTS
  // ============================================

  /// Log image upload from gallery
  Future<void> logImageUploadGallery() async {
    await _analytics.logEvent(
      name: 'image_upload',
      parameters: {'source': 'gallery'},
    );
    debugPrint('📊 Analytics: Image upload from gallery');
  }

  /// Log image capture from camera
  Future<void> logImageUploadCamera() async {
    await _analytics.logEvent(
      name: 'image_upload',
      parameters: {'source': 'camera'},
    );
    debugPrint('📊 Analytics: Image upload from camera');
  }

  /// Log object/item image attached
  Future<void> logObjectImageAttached() async {
    await _analytics.logEvent(name: 'object_image_attached');
    debugPrint('📊 Analytics: Object image attached');
  }

  /// Log object image removed
  Future<void> logObjectImageRemoved() async {
    await _analytics.logEvent(name: 'object_image_removed');
    debugPrint('📊 Analytics: Object image removed');
  }

  // ============================================
  // AI PROCESSING EVENTS
  // ============================================

  /// Log AI processing started
  Future<void> logAIProcessingStarted({
    required String promptType,
    String? styleName,
    String? colorName,
    bool hasObjectImage = false,
  }) async {
    await _analytics.logEvent(
      name: 'ai_processing_started',
      parameters: {
        'prompt_type': promptType, // 'style', 'color', 'custom', 'lighting', 'furniture', etc.
        if (styleName != null) 'style_name': styleName,
        if (colorName != null) 'color_name': colorName,
        'has_object_image': hasObjectImage.toString(),
      },
    );
    debugPrint('📊 Analytics: AI processing started - type: $promptType');
  }

  /// Log AI processing completed successfully
  Future<void> logAIProcessingSuccess({
    required String promptType,
    int? processingTimeMs,
  }) async {
    await _analytics.logEvent(
      name: 'ai_processing_success',
      parameters: {
        'prompt_type': promptType,
        if (processingTimeMs != null) 'processing_time_ms': processingTimeMs,
      },
    );
    debugPrint('📊 Analytics: AI processing success - type: $promptType');
  }

  /// Log AI processing failed
  Future<void> logAIProcessingError({
    required String promptType,
    String? errorMessage,
  }) async {
    await _analytics.logEvent(
      name: 'ai_processing_error',
      parameters: {
        'prompt_type': promptType,
        if (errorMessage != null) 'error_message': errorMessage.substring(0, errorMessage.length.clamp(0, 100)),
      },
    );
    debugPrint('📊 Analytics: AI processing error - type: $promptType');
  }

  /// Log AI result kept by user
  Future<void> logAIResultKept() async {
    await _analytics.logEvent(name: 'ai_result_kept');
    debugPrint('📊 Analytics: AI result kept');
  }

  /// Log AI result reverted by user
  Future<void> logAIResultReverted() async {
    await _analytics.logEvent(name: 'ai_result_reverted');
    debugPrint('📊 Analytics: AI result reverted');
  }

  // ============================================
  // STYLE & COLOR SELECTION EVENTS
  // ============================================

  /// Log style modal opened
  Future<void> logStyleModalOpened() async {
    await _analytics.logEvent(name: 'style_modal_opened');
    debugPrint('📊 Analytics: Style modal opened');
  }

  /// Log style selected
  Future<void> logStyleSelected(String styleName) async {
    await _analytics.logEvent(
      name: 'style_selected',
      parameters: {'style_name': styleName},
    );
    debugPrint('📊 Analytics: Style selected: $styleName');
  }

  /// Log color modal opened
  Future<void> logColorModalOpened() async {
    await _analytics.logEvent(name: 'color_modal_opened');
    debugPrint('📊 Analytics: Color modal opened');
  }

  /// Log color selected
  Future<void> logColorSelected(String colorName) async {
    await _analytics.logEvent(
      name: 'color_selected',
      parameters: {'color_name': colorName},
    );
    debugPrint('📊 Analytics: Color selected: $colorName');
  }

  /// Log options modal opened (lighting, furniture, etc.)
  Future<void> logOptionsModalOpened(String optionType) async {
    await _analytics.logEvent(
      name: 'options_modal_opened',
      parameters: {'option_type': optionType},
    );
    debugPrint('📊 Analytics: Options modal opened: $optionType');
  }

  /// Log option selected from modal
  Future<void> logOptionSelected(String optionType, String optionName) async {
    await _analytics.logEvent(
      name: 'option_selected',
      parameters: {
        'option_type': optionType,
        'option_name': optionName,
      },
    );
    debugPrint('📊 Analytics: Option selected: $optionType - $optionName');
  }

  // ============================================
  // HISTORY EVENTS
  // ============================================

  /// Log history drawer opened
  Future<void> logHistoryOpened() async {
    await _analytics.logEvent(name: 'history_opened');
    debugPrint('📊 Analytics: History opened');
  }

  /// Log history item selected
  Future<void> logHistoryItemSelected() async {
    await _analytics.logEvent(name: 'history_item_selected');
    debugPrint('📊 Analytics: History item selected');
  }

  /// Log history load more
  Future<void> logHistoryLoadMore() async {
    await _analytics.logEvent(name: 'history_load_more');
    debugPrint('📊 Analytics: History load more');
  }

  // ============================================
  // SUBSCRIPTION & PURCHASE EVENTS
  // ============================================

  /// Log subscription modal opened
  Future<void> logSubscriptionModalOpened({String? source}) async {
    await _analytics.logEvent(
      name: 'subscription_modal_opened',
      parameters: source != null ? {'source': source} : null,
    );
    debugPrint('📊 Analytics: Subscription modal opened from: $source');
  }

  /// Log limit reached modal shown
  Future<void> logLimitReachedShown({
    required int currentUsage,
    required int limit,
  }) async {
    await _analytics.logEvent(
      name: 'limit_reached_shown',
      parameters: {
        'current_usage': currentUsage,
        'limit': limit,
      },
    );
    debugPrint('📊 Analytics: Limit reached shown - usage: $currentUsage/$limit');
  }

  /// Log subscription plan selected (purchase initiated)
  Future<void> logSubscriptionPlanSelected({
    required String productId,
    required String tierName,
    required int credits,
    required String price,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_plan_selected',
      parameters: {
        'product_id': productId,
        'tier_name': tierName,
        'credits': credits,
        'price': price,
      },
    );
    debugPrint('📊 Analytics: Subscription plan selected: $tierName ($productId)');
  }

  /// Log subscription purchase completed
  Future<void> logSubscriptionPurchased({
    required String productId,
    required String tierName,
    required int credits,
    required double value,
    required String currency,
  }) async {
    // Use standard Firebase purchase event
    await _analytics.logPurchase(
      currency: currency,
      value: value,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: tierName,
          quantity: 1,
        ),
      ],
    );

    // Also log custom event with more details
    await _analytics.logEvent(
      name: 'subscription_purchased',
      parameters: {
        'product_id': productId,
        'tier_name': tierName,
        'credits': credits,
      },
    );
    debugPrint('📊 Analytics: Subscription purchased: $tierName');
  }

  /// Log subscription purchase failed
  Future<void> logSubscriptionPurchaseFailed({
    required String productId,
    String? errorMessage,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_purchase_failed',
      parameters: {
        'product_id': productId,
        if (errorMessage != null) 'error_message': errorMessage.substring(0, errorMessage.length.clamp(0, 100)),
      },
    );
    debugPrint('📊 Analytics: Subscription purchase failed: $productId');
  }

  /// Log subscription purchase cancelled
  Future<void> logSubscriptionPurchaseCancelled({required String productId}) async {
    await _analytics.logEvent(
      name: 'subscription_purchase_cancelled',
      parameters: {'product_id': productId},
    );
    debugPrint('📊 Analytics: Subscription purchase cancelled: $productId');
  }

  /// Log restore purchases initiated
  Future<void> logRestorePurchases() async {
    await _analytics.logEvent(name: 'restore_purchases');
    debugPrint('📊 Analytics: Restore purchases');
  }

  // ============================================
  // AUTH EVENTS
  // ============================================

  /// Log login started
  Future<void> logLoginStarted() async {
    await _analytics.logEvent(name: 'login_started');
    debugPrint('📊 Analytics: Login started');
  }

  /// Log login success
  Future<void> logLoginSuccess() async {
    await _analytics.logLogin(loginMethod: 'email');
    debugPrint('📊 Analytics: Login success');
  }

  /// Log login failed
  Future<void> logLoginFailed({String? errorCode}) async {
    await _analytics.logEvent(
      name: 'login_failed',
      parameters: errorCode != null ? {'error_code': errorCode} : null,
    );
    debugPrint('📊 Analytics: Login failed: $errorCode');
  }

  /// Log signup started
  Future<void> logSignupStarted() async {
    await _analytics.logEvent(name: 'signup_started');
    debugPrint('📊 Analytics: Signup started');
  }

  /// Log signup success
  Future<void> logSignupSuccess() async {
    await _analytics.logSignUp(signUpMethod: 'email');
    debugPrint('📊 Analytics: Signup success');
  }

  /// Log signup failed
  Future<void> logSignupFailed({String? errorCode}) async {
    await _analytics.logEvent(
      name: 'signup_failed',
      parameters: errorCode != null ? {'error_code': errorCode} : null,
    );
    debugPrint('📊 Analytics: Signup failed: $errorCode');
  }

  /// Log logout
  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
    debugPrint('📊 Analytics: Logout');
  }

  /// Log password reset requested
  Future<void> logPasswordResetRequested() async {
    await _analytics.logEvent(name: 'password_reset_requested');
    debugPrint('📊 Analytics: Password reset requested');
  }

  /// Log account deletion
  Future<void> logAccountDeleted() async {
    await _analytics.logEvent(name: 'account_deleted');
    debugPrint('📊 Analytics: Account deleted');
  }

  // ============================================
  // COUPON EVENTS
  // ============================================

  /// Log coupon modal opened
  Future<void> logCouponModalOpened() async {
    await _analytics.logEvent(name: 'coupon_modal_opened');
    debugPrint('📊 Analytics: Coupon modal opened');
  }

  /// Log coupon redeemed successfully
  Future<void> logCouponRedeemed({required int creditsAdded}) async {
    await _analytics.logEvent(
      name: 'coupon_redeemed',
      parameters: {'credits_added': creditsAdded},
    );
    debugPrint('📊 Analytics: Coupon redeemed - credits: $creditsAdded');
  }

  /// Log coupon redemption failed
  Future<void> logCouponFailed({String? errorCode}) async {
    await _analytics.logEvent(
      name: 'coupon_failed',
      parameters: errorCode != null ? {'error_code': errorCode} : null,
    );
    debugPrint('📊 Analytics: Coupon failed: $errorCode');
  }

  // ============================================
  // SHARING & SOCIAL EVENTS
  // ============================================

  /// Log image shared
  Future<void> logImageShared({String? method}) async {
    await _analytics.logShare(
      contentType: 'image',
      itemId: 'generated_image',
      method: method ?? 'system_share',
    );
    debugPrint('📊 Analytics: Image shared');
  }

  /// Log image saved to gallery
  Future<void> logImageSavedToGallery() async {
    await _analytics.logEvent(name: 'image_saved_to_gallery');
    debugPrint('📊 Analytics: Image saved to gallery');
  }

  // ============================================
  // RATING & FEEDBACK EVENTS
  // ============================================

  /// Log rate app modal shown
  Future<void> logRateAppShown() async {
    await _analytics.logEvent(name: 'rate_app_shown');
    debugPrint('📊 Analytics: Rate app shown');
  }

  /// Log rate app response
  Future<void> logRateAppResponse({required String response}) async {
    await _analytics.logEvent(
      name: 'rate_app_response',
      parameters: {'response': response}, // 'yes', 'no', 'later'
    );
    debugPrint('📊 Analytics: Rate app response: $response');
  }

  /// Log contact/feedback modal opened
  Future<void> logContactModalOpened() async {
    await _analytics.logEvent(name: 'contact_modal_opened');
    debugPrint('📊 Analytics: Contact modal opened');
  }

  /// Log feedback submitted
  Future<void> logFeedbackSubmitted() async {
    await _analytics.logEvent(name: 'feedback_submitted');
    debugPrint('📊 Analytics: Feedback submitted');
  }

  // ============================================
  // MENU & NAVIGATION EVENTS
  // ============================================

  /// Log mobile menu opened
  Future<void> logMobileMenuOpened() async {
    await _analytics.logEvent(name: 'mobile_menu_opened');
    debugPrint('📊 Analytics: Mobile menu opened');
  }

  /// Log more options drawer opened
  Future<void> logMoreOptionsOpened() async {
    await _analytics.logEvent(name: 'more_options_opened');
    debugPrint('📊 Analytics: More options opened');
  }

  /// Log language changed
  Future<void> logLanguageChanged(String newLocale) async {
    await _analytics.logEvent(
      name: 'language_changed',
      parameters: {'new_locale': newLocale},
    );
    debugPrint('📊 Analytics: Language changed to: $newLocale');
  }

  // ============================================
  // IMAGE MODAL EVENTS
  // ============================================

  /// Log image modal opened
  Future<void> logImageModalOpened({bool showComparison = false}) async {
    await _analytics.logEvent(
      name: 'image_modal_opened',
      parameters: {'show_comparison': showComparison.toString()},
    );
    debugPrint('📊 Analytics: Image modal opened (comparison: $showComparison)');
  }

  /// Log comparison view toggled
  Future<void> logComparisonToggled({required bool enabled}) async {
    await _analytics.logEvent(
      name: 'comparison_toggled',
      parameters: {'enabled': enabled.toString()},
    );
    debugPrint('📊 Analytics: Comparison toggled: $enabled');
  }

  // ============================================
  // ERROR EVENTS
  // ============================================

  /// Log generic error
  Future<void> logError({
    required String errorType,
    String? errorMessage,
    String? screenName,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        if (errorMessage != null) 'error_message': errorMessage.substring(0, errorMessage.length.clamp(0, 100)),
        if (screenName != null) 'screen_name': screenName,
      },
    );
    debugPrint('📊 Analytics: Error - type: $errorType');
  }
}
