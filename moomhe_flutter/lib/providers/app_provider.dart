import 'dart:io';
import 'package:flutter/material.dart';
import '../models/history_entry.dart';

class AppProvider extends ChangeNotifier {
  // User state
  String? _userId;
  String? _userEmail;
  bool _isAnonymous = true;
  int _userCredits = 0;
  int _userUsage = 0;
  int _userSubscription = 0;
  
  // Subscription state
  String? _subscriptionProductId;
  bool _isYearlyBilling = false;
  DateTime? _subscriptionExpiryDate;
  DateTime? _subscriptionUpdatedAt;

  // Image state
  String? _mainImagePath;
  String? _beforeImagePath;
  File? _uploadedImage;
  File? _objectImage;
  bool _isProcessing = false;
  bool _showComparison = false;

  // History state
  List<HistoryEntry> _imageHistory = [];
  bool _isLoadingHistory = false;
  bool _hasMoreHistory = true;
  // int _historyPage = 1; // For pagination - to be implemented

  // UI state
  bool _showOnboarding = false;
  int _onboardingStep = 0;
  String _customPrompt = '';

  // Getters
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  bool get isAnonymous => _isAnonymous;
  bool get isLoggedIn => _userId != null && !_isAnonymous;
  int get userCredits => _userCredits;
  int get userUsage => _userUsage;
  int get userSubscription => _userSubscription;
  int get remainingCredits => _userCredits - _userUsage;
  
  // Subscription getters
  String? get subscriptionProductId => _subscriptionProductId;
  bool get isYearlyBilling => _isYearlyBilling;
  DateTime? get subscriptionExpiryDate => _subscriptionExpiryDate;
  DateTime? get subscriptionUpdatedAt => _subscriptionUpdatedAt;
  bool get hasActiveSubscription => _userSubscription > 0;
  bool get isSubscriptionExpired => 
      _subscriptionExpiryDate != null && 
      _subscriptionExpiryDate!.isBefore(DateTime.now());

  String? get mainImagePath => _mainImagePath;
  String? get beforeImagePath => _beforeImagePath;
  File? get uploadedImage => _uploadedImage;
  File? get objectImage => _objectImage;
  bool get isProcessing => _isProcessing;
  bool get showComparison => _showComparison;

  List<HistoryEntry> get imageHistory => _imageHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get hasMoreHistory => _hasMoreHistory;

  bool get showOnboarding => _showOnboarding;
  int get onboardingStep => _onboardingStep;
  String get customPrompt => _customPrompt;

  // Subscription helpers
  String get subscriptionName {
    switch (_userSubscription) {
      case 1:
        return 'מתחיל';
      case 2:
        return 'משתלם';
      case 3:
        return 'מקצועי';
      default:
        return 'חינם';
    }
  }

  String get subscriptionNameEnglish {
    switch (_userSubscription) {
      case 1:
        return 'Starter';
      case 2:
        return 'Pro';
      case 3:
        return 'Business';
      default:
        return 'Free';
    }
  }

  String get billingPeriodName => _isYearlyBilling ? 'Yearly' : 'Monthly';

  // User actions
  void setUser({
    required String userId,
    String? email,
    bool isAnonymous = false,
    int credits = 0,
    int usage = 0,
    int subscription = 0,
  }) {
    _userId = userId;
    _userEmail = email;
    _isAnonymous = isAnonymous;
    _userCredits = credits;
    _userUsage = usage;
    _userSubscription = subscription;
    notifyListeners();
  }

  void updateCredits(int credits) {
    _userCredits = credits;
    notifyListeners();
  }

  void updateUsage(int usage) {
    _userUsage = usage;
    notifyListeners();
  }

  void updateSubscription(int subscription) {
    _userSubscription = subscription;
    notifyListeners();
  }

  /// Update full subscription state from purchase
  void updateSubscriptionFromPurchase({
    required int subscription,
    required int credits,
    String? productId,
    bool? isYearly,
    DateTime? expiryDate,
  }) {
    _userSubscription = subscription;
    _userCredits = credits;
    _subscriptionProductId = productId;
    if (isYearly != null) _isYearlyBilling = isYearly;
    if (expiryDate != null) _subscriptionExpiryDate = expiryDate;
    _subscriptionUpdatedAt = DateTime.now();
    notifyListeners();
  }

  /// Set subscription product ID
  void setSubscriptionProductId(String? productId) {
    _subscriptionProductId = productId;
    if (productId != null) {
      _isYearlyBilling = productId.contains('yearly');
    }
    notifyListeners();
  }

  /// Set subscription expiry date
  void setSubscriptionExpiryDate(DateTime? expiryDate) {
    _subscriptionExpiryDate = expiryDate;
    notifyListeners();
  }

  /// Clear subscription state (on cancellation/expiry)
  void clearSubscription() {
    _userSubscription = 0;
    _userCredits = 3; // Reset to free tier credits
    _subscriptionProductId = null;
    _isYearlyBilling = false;
    _subscriptionExpiryDate = null;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _userEmail = null;
    _isAnonymous = true;
    _userCredits = 0;
    _userUsage = 0;
    _userSubscription = 0;
    _subscriptionProductId = null;
    _isYearlyBilling = false;
    _subscriptionExpiryDate = null;
    _subscriptionUpdatedAt = null;
    _imageHistory = [];
    notifyListeners();
  }

  // Image actions
  void setMainImage(String? path) {
    _mainImagePath = path;
    notifyListeners();
  }

  void setBeforeImage(String? path) {
    _beforeImagePath = path;
    notifyListeners();
  }

  void setUploadedImage(File? image) {
    _uploadedImage = image;
    if (image != null) {
      _mainImagePath = image.path;
    }
    notifyListeners();
  }

  void setObjectImage(File? image) {
    _objectImage = image;
    notifyListeners();
  }

  void clearObjectImage() {
    _objectImage = null;
    notifyListeners();
  }

  void setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void toggleComparison() {
    if (_beforeImagePath != null) {
      _showComparison = !_showComparison;
      notifyListeners();
    }
  }

  void setShowComparison(bool show) {
    _showComparison = show;
    notifyListeners();
  }

  // History actions
  void setHistory(List<HistoryEntry> history) {
    _imageHistory = history;
    notifyListeners();
  }

  void addToHistory(HistoryEntry entry) {
    _imageHistory.insert(0, entry);
    notifyListeners();
  }

  void setLoadingHistory(bool loading) {
    _isLoadingHistory = loading;
    notifyListeners();
  }

  void setHasMoreHistory(bool hasMore) {
    _hasMoreHistory = hasMore;
    notifyListeners();
  }

  // Pagination methods - to be implemented with actual Firebase integration
  void incrementHistoryPage() {
    // _historyPage++;
    notifyListeners();
  }

  void resetHistoryPage() {
    // _historyPage = 1;
    notifyListeners();
  }

  // Onboarding actions
  void startOnboarding() {
    _showOnboarding = true;
    _onboardingStep = 0;
    notifyListeners();
  }

  void nextOnboardingStep() {
    _onboardingStep++;
    notifyListeners();
  }

  void completeOnboarding() {
    _showOnboarding = false;
    notifyListeners();
  }

  // Prompt actions
  void setCustomPrompt(String prompt) {
    _customPrompt = prompt;
    notifyListeners();
  }

  void appendToPrompt(String addition) {
    if (_customPrompt.isEmpty) {
      _customPrompt = addition;
    } else {
      _customPrompt = '$_customPrompt $addition';
    }
    notifyListeners();
  }

  void clearPrompt() {
    _customPrompt = '';
    notifyListeners();
  }
}
