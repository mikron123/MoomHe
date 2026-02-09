import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../services/purchase_service.dart' show PurchaseService, PurchaseUiStatus, ProductIds;
import '../services/analytics_service.dart';
import '../l10n/localized_options.dart';

/// Alternative Subscription Modal with Monthly/Yearly toggle
/// Focused on the Pro tier (200 credits/month) with clean 2-option UX
class SubscriptionModalV2 extends StatefulWidget {
  final int currentSubscription;
  final int currentCredits;
  final VoidCallback? onPurchaseComplete;

  const SubscriptionModalV2({
    super.key,
    required this.currentSubscription,
    required this.currentCredits,
    this.onPurchaseComplete,
  });

  @override
  State<SubscriptionModalV2> createState() => _SubscriptionModalV2State();
}

class _SubscriptionModalV2State extends State<SubscriptionModalV2> with TickerProviderStateMixin, WidgetsBindingObserver {
  final PurchaseService _purchaseService = PurchaseService();
  final AnalyticsService _analytics = AnalyticsService();
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  String? _purchasingProductId;
  bool _userInitiatedPurchase = false;
  DateTime? _purchaseStartTime;

  // Billing period selection - default to yearly (better value)
  bool _isYearly = true;

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _footerController;
  late AnimationController _backgroundAnimController;
  late AnimationController _particleAnimController;
  late AnimationController _toggleAnimController;
  
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _footerFadeAnimation;

  // Gold gradient matching the existing theme
  static const List<Color> _primaryGradient = [Color(0xFFB59259), Color(0xFFD4A574)];
  static const List<Color> _businessGradient = [Color(0xFF11998E), Color(0xFF38EF7D)];
  static const Color _accentColor = Color(0xFFB59259);

  // Tier configuration
  // currentSubscription: 0=none, 1=starter, 2=pro, 3=business
  
  /// Determines which tier to show based on user's current subscription
  /// - No subscription or Starter → Show Pro (200 credits)
  /// - Pro → Show Business (450 credits)
  /// - Business → Already on best plan
  int get _targetTier {
    if (widget.currentSubscription >= 2) {
      return 3; // Show Business tier for Pro users (upgrade path)
    }
    return 2; // Show Pro tier for free/Starter users
  }
  
  bool get _isShowingBusinessTier => _targetTier == 3;
  bool get _isAlreadyOnBestPlan => widget.currentSubscription >= 3;
  
  int get _targetCredits => _isShowingBusinessTier ? 450 : 200;
  String get _targetPlanName => _isShowingBusinessTier ? 'Professional' : 'Value';
  int get _freeTrialDays => _isShowingBusinessTier ? 0 : 3; // Only Pro has trial
  
  List<Color> get _currentGradient => _isShowingBusinessTier ? _businessGradient : _primaryGradient;
  Color get _currentAccentColor => _isShowingBusinessTier ? const Color(0xFF11998E) : _accentColor;

  // Fallback prices (when store prices aren't loaded)
  double get _monthlyPriceFallback => _isShowingBusinessTier ? 26.99 : 12.99;
  double get _yearlyPriceFallback => _isShowingBusinessTier ? 159.99 : 79.99;
  
  // Product IDs based on target tier
  String get _monthlyProductId => _isShowingBusinessTier 
      ? ProductIds.businessMonthly 
      : ProductIds.proMonthly;
  String get _yearlyProductId => _isShowingBusinessTier 
      ? ProductIds.businessYearly 
      : ProductIds.proYearly;
  
  // Yearly savings percentage
  int get _savingsPercent {
    final monthlyPrice = _getMonthlyPrice();
    final yearlyPrice = _getYearlyPrice();
    final yearlyMonthlyEquivalent = monthlyPrice * 12;
    if (yearlyMonthlyEquivalent <= 0) return 40; // fallback
    return ((yearlyMonthlyEquivalent - yearlyPrice) / yearlyMonthlyEquivalent * 100).round();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAnimations();
    _initializePurchases();
  }

  void _initAnimations() {
    // Background animation
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Particle animation
    _particleAnimController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Header animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));

    // Content animation
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    // Footer animation
    _footerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _footerController, curve: Curves.easeOut),
    );

    // Toggle animation
    _toggleAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1.0, // Start at yearly
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _footerController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _headerController.dispose();
    _contentController.dispose();
    _footerController.dispose();
    _backgroundAnimController.dispose();
    _particleAnimController.dispose();
    _toggleAnimController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _purchasingProductId != null) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _purchasingProductId != null && _purchaseStartTime != null) {
          final elapsed = DateTime.now().difference(_purchaseStartTime!);
          if (elapsed.inSeconds >= 5) {
            debugPrint('📱 App resumed - resetting loader');
            setState(() {
              _isPurchasing = false;
              _purchasingProductId = null;
              _purchaseStartTime = null;
            });
          }
        }
      });
    }
  }

  Future<void> _initializePurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _purchaseService.onPurchaseStatusChanged = _onPurchaseStatusChanged;
    _purchaseService.onProductsLoaded = _onProductsLoaded;

    await _purchaseService.initialize();

    setState(() {
      _isLoading = false;
    });
  }

  void _onProductsLoaded(List<ProductDetails> products) {
    if (mounted) {
      setState(() {});
    }
  }

  void _onPurchaseStatusChanged(PurchaseUiStatus status, String? message) {
    if (!mounted) return;

    setState(() {
      switch (status) {
        case PurchaseUiStatus.purchasing:
        case PurchaseUiStatus.loading:
          _isPurchasing = true;
          _errorMessage = null;
          break;
        case PurchaseUiStatus.success:
          _isPurchasing = false;
          _purchasingProductId = null;
          _purchaseStartTime = null;
          widget.onPurchaseComplete?.call();
          if (_userInitiatedPurchase) {
            _userInitiatedPurchase = false;
            Navigator.pop(context);
          }
          break;
        case PurchaseUiStatus.error:
          _isPurchasing = false;
          _purchasingProductId = null;
          _purchaseStartTime = null;
          if (_userInitiatedPurchase) {
            _errorMessage = message ?? context.l10n.purchaseFailed;
          }
          _userInitiatedPurchase = false;
          break;
        case PurchaseUiStatus.cancelled:
          _isPurchasing = false;
          _purchasingProductId = null;
          _purchaseStartTime = null;
          _userInitiatedPurchase = false;
          break;
        case PurchaseUiStatus.idle:
          _isPurchasing = false;
          break;
      }
    });
  }

  double _getMonthlyPrice() {
    final product = _purchaseService.getProduct(_monthlyProductId);
    if (product != null) {
      // Extract numeric value from price string
      final priceStr = product.price.replaceAll(RegExp(r'[^\d.,]'), '');
      return double.tryParse(priceStr.replaceAll(',', '.')) ?? _monthlyPriceFallback;
    }
    return _monthlyPriceFallback;
  }

  double _getYearlyPrice() {
    final product = _purchaseService.getProduct(_yearlyProductId);
    if (product != null) {
      final priceStr = product.price.replaceAll(RegExp(r'[^\d.,]'), '');
      return double.tryParse(priceStr.replaceAll(',', '.')) ?? _yearlyPriceFallback;
    }
    return _yearlyPriceFallback;
  }

  String _getDisplayPrice(bool yearly) {
    final productId = yearly ? _yearlyProductId : _monthlyProductId;
    final product = _purchaseService.getProduct(productId);
    if (product != null) {
      return product.price;
    }
    return yearly ? '\$${_yearlyPriceFallback.toStringAsFixed(2)}' : '\$${_monthlyPriceFallback.toStringAsFixed(2)}';
  }

  String _getYearlyMonthlyBreakdown() {
    final yearlyPrice = _getYearlyPrice();
    final monthlyEquivalent = yearlyPrice / 12;
    // Get currency symbol from yearly product
    final product = _purchaseService.getProduct(_yearlyProductId);
    final currencySymbol = product != null 
        ? product.price.replaceAll(RegExp(r'[\d.,\s]'), '').trim()
        : '\$';
    return '$currencySymbol${monthlyEquivalent.toStringAsFixed(2)}';
  }

  Future<void> _handlePurchase() async {
    final productId = _isYearly ? _yearlyProductId : _monthlyProductId;
    final price = _getDisplayPrice(_isYearly);
    
    _analytics.logSubscriptionPlanSelected(
      productId: productId,
      tierName: _targetPlanName,
      credits: _targetCredits,
      price: price,
    );
    
    setState(() {
      _purchasingProductId = productId;
      _errorMessage = null;
      _userInitiatedPurchase = true;
      _purchaseStartTime = DateTime.now();
    });

    final success = await _purchaseService.purchaseSubscription(productId);
    
    if (!success && mounted && _purchasingProductId == productId) {
      _analytics.logSubscriptionPurchaseCancelled(productId: productId);
      setState(() {
        _isPurchasing = false;
        _purchasingProductId = null;
        _userInitiatedPurchase = false;
        _purchaseStartTime = null;
      });
    }
  }

  bool _isCurrentPlan() {
    // Check if user is already on the tier we're showing
    // Pro plan = 2, Business plan = 3
    return widget.currentSubscription == _targetTier;
  }

  Future<void> _launchUrlInApp(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  void _toggleBillingPeriod(bool yearly) {
    setState(() {
      _isYearly = yearly;
    });
    if (yearly) {
      _toggleAnimController.forward();
    } else {
      _toggleAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final screenSize = MediaQuery.of(context).size;
    final isCurrentPlan = _isCurrentPlan();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedBuilder(
            animation: _backgroundAnimController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      math.sin(_backgroundAnimController.value * math.pi * 2) * 0.5,
                      math.cos(_backgroundAnimController.value * math.pi * 2) * 0.3 - 0.3,
                    ),
                    radius: 1.8,
                    colors: [
                      _primaryGradient[0].withValues(alpha: 0.18),
                      _primaryGradient[1].withValues(alpha: 0.08),
                      AppColors.background,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              );
            },
          ),

          // Floating particles
          ...List.generate(10, (index) => _buildFloatingParticle(index, screenSize)),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with close button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 12 : 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 22),
                        ),
                      ),
                      const Spacer(),
                      // Header badge
                      SlideTransition(
                        position: _headerSlideAnimation,
                        child: FadeTransition(
                          opacity: _headerFadeAnimation,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 20 : 16,
                              vertical: isTablet ? 10 : 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: _primaryGradient),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryGradient[0].withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              context.l10n.specialLaunchPrices,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                // Error message
                if (_errorMessage != null)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 16, vertical: 4),
                    constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertCircle, color: Colors.red.shade400, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade400, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main scrollable content area
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _primaryGradient[0].withValues(alpha: 0.2),
                                  _primaryGradient[1].withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                          ),
                        )
                      : FadeTransition(
                          opacity: _contentFadeAnimation,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 48 : 24,
                              vertical: 16,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: isTablet ? 500 : 400),
                                child: Column(
                                  children: [
                                    // Plan icon and title
                                    _buildPlanHeader(isTablet),
                                    
                                    SizedBox(height: isTablet ? 28 : 20),
                                    
                                    // Billing toggle
                                    _buildBillingToggle(isTablet),
                                    
                                    SizedBox(height: isTablet ? 28 : 20),
                                    
                                    // Price display card
                                    _buildPriceCard(isTablet),
                                    
                                    SizedBox(height: isTablet ? 24 : 16),
                                    
                                    // Features list
                                    _buildFeaturesList(isTablet),
                                    
                                    // Free trial badge (only for monthly with trial)
                                    if (!_isYearly && _freeTrialDays > 0) ...[
                                      SizedBox(height: isTablet ? 20 : 14),
                                      _buildFreeTrialBadge(isTablet),
                                    ],
                                    
                                    // Bottom padding to ensure content doesn't hide behind fixed CTA
                                    SizedBox(height: isTablet ? 24 : 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                ),

                // Fixed bottom section with CTA and footer
                FadeTransition(
                  opacity: _footerFadeAnimation,
                  child: _buildFixedBottomSection(isTablet, isCurrentPlan),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(bool isTablet) {
    return Column(
      children: [
        // Icon with glow
        Container(
          width: isTablet ? 90 : 72,
          height: isTablet ? 90 : 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _currentGradient[0].withValues(alpha: 0.2),
                _currentGradient[1].withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(color: _currentGradient[0].withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: _currentGradient[0].withValues(alpha: 0.3),
                blurRadius: 24,
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(colors: _currentGradient).createShader(bounds),
              child: Icon(
                _isShowingBusinessTier ? LucideIcons.crown : LucideIcons.flame, 
                size: isTablet ? 44 : 36, 
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        SizedBox(height: isTablet ? 20 : 16),
        
        // Plan name
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(colors: _currentGradient).createShader(bounds),
          child: Text(
            _isShowingBusinessTier ? context.l10n.proPlan : context.l10n.valuePlan,
            style: TextStyle(
              fontSize: isTablet ? 32 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Credits info
        Text(
          context.l10n.imagesPerMonth(_targetCredits),
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBillingToggle(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Monthly option
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleBillingPeriod(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                decoration: BoxDecoration(
                  gradient: !_isYearly
                      ? LinearGradient(colors: _currentGradient)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isYearly
                      ? [
                          BoxShadow(
                            color: _currentGradient[0].withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      context.l10n.perMonth.replaceAll('/', ''),
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w600,
                        color: !_isYearly 
                            ? Colors.white 
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 4),
          
          // Yearly option with savings badge
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleBillingPeriod(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                decoration: BoxDecoration(
                  gradient: _isYearly
                      ? LinearGradient(colors: _currentGradient)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isYearly
                      ? [
                          BoxShadow(
                            color: _currentGradient[0].withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Yearly',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w600,
                            color: _isYearly 
                                ? Colors.white 
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    // Savings badge
                    Positioned(
                      top: isTablet ? -26 : -24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          'SAVE $_savingsPercent%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(bool isTablet) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_isYearly),
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 28 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _currentGradient[0].withValues(alpha: 0.15),
              _currentGradient[1].withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _currentGradient[0].withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _currentGradient[0].withValues(alpha: 0.2),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          children: [
            // Main price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(colors: _currentGradient).createShader(bounds),
                  child: Text(
                    _getDisplayPrice(_isYearly),
                    style: TextStyle(
                      fontSize: isTablet ? 48 : 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isYearly ? '/year' : context.l10n.perMonth,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            
            // Monthly breakdown for yearly - prominent green badge
            if (_isYearly) ...[
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20, 
                  vertical: isTablet ? 14 : 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF22C55E).withValues(alpha: 0.25),
                      const Color(0xFF16A34A).withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: isTablet ? 20 : 18,
                      color: const Color(0xFF22C55E),
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Text(
                      'Just ${_getYearlyMonthlyBreakdown()}${context.l10n.perMonth}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF22C55E),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Crossed out original price for yearly
            if (_isYearly) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Was ${_getDisplayPrice(false)} × 12 = ',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    '\$${(_getMonthlyPrice() * 12).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      color: Colors.white.withValues(alpha: 0.5),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(bool isTablet) {
    final features = [
      (LucideIcons.image, context.l10n.imagesPerMonth(_targetCredits)),
      (LucideIcons.messageCircle, context.l10n.whatsappSupport),
      (LucideIcons.history, context.l10n.historyStorage),
      (LucideIcons.palette, context.l10n.allDesignTools),
      (LucideIcons.headphones, context.l10n.fastSupport),
      (LucideIcons.banknote, context.l10n.noAds),
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _currentGradient[0].withValues(alpha: 0.2),
                      _currentGradient[1].withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(feature.$1, size: 14, color: _currentAccentColor),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                feature.$2,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFreeTrialBadge(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _currentGradient[0].withValues(alpha: 0.25),
            _currentGradient[1].withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentGradient[0].withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _currentGradient[0].withValues(alpha: 0.3),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _currentGradient),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.gift, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(colors: _currentGradient).createShader(bounds),
                child: Text(
                  context.l10n.freeTrialDays(_freeTrialDays).toUpperCase(),
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.thenPrice(_getDisplayPrice(false)),
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(bool isTablet, bool isCurrentPlan) {
    // Determine button text
    String buttonText;
    if (isCurrentPlan) {
      buttonText = context.l10n.yourCurrentPlan;
    } else if (_isAlreadyOnBestPlan) {
      buttonText = context.l10n.yourCurrentPlan; // Already on best plan
    } else if (!_isYearly && _freeTrialDays > 0) {
      buttonText = context.l10n.freeTrialDays(_freeTrialDays);
    } else {
      buttonText = context.l10n.selectPlan;
    }
    
    final isDisabled = isCurrentPlan || _isPurchasing || _isAlreadyOnBestPlan;
    
    return GestureDetector(
      onTap: isDisabled ? null : _handlePurchase,
      child: Container(
        width: double.infinity,
        height: isTablet ? 60 : 54,
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : LinearGradient(colors: _currentGradient),
          color: isDisabled ? const Color(0xFF26A69A).withValues(alpha: 0.2) : null,
          borderRadius: BorderRadius.circular(16),
          border: isDisabled
              ? Border.all(color: const Color(0xFF26A69A).withValues(alpha: 0.5))
              : null,
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: _currentGradient[0].withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: _isPurchasing
            ? const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isDisabled) ...[
                    const Icon(LucideIcons.checkCircle, size: 22, color: Color(0xFF26A69A)),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? const Color(0xFF26A69A) : Colors.white,
                    ),
                  ),
                  if (!isDisabled) ...[
                    const SizedBox(width: 8),
                    Directionality.of(context) == TextDirection.rtl
                        ? Transform.flip(
                            flipX: true,
                            child: const Icon(LucideIcons.arrowRight, size: 22, color: Colors.white),
                          )
                        : const Icon(LucideIcons.arrowRight, size: 22, color: Colors.white),
                  ],
                ],
              ),
      ),
    );
  }

  /// Fixed bottom section with CTA button, restore purchases, and legal links
  Widget _buildFixedBottomSection(bool isTablet, bool isCurrentPlan) {
    return Container(
      decoration: BoxDecoration(
        // Subtle gradient background to separate from scrollable content
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0.0),
            AppColors.background.withValues(alpha: 0.95),
            AppColors.background,
          ],
          stops: const [0.0, 0.15, 0.3],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 48 : 24,
            isTablet ? 16 : 12,
            isTablet ? 48 : 24,
            isTablet ? 12 : 8,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 500 : 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CTA Button - always visible
                  _buildCTAButton(isTablet, isCurrentPlan),
                  
                  // Restore purchases (iOS only)
                  if (Platform.isIOS) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isPurchasing
                          ? null
                          : () {
                              _analytics.logRestorePurchases();
                              setState(() {
                                _userInitiatedPurchase = true;
                              });
                              _purchaseService.restorePurchases();
                            },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(
                        context.l10n.restorePurchases,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ),
                  ] else
                    const SizedBox(height: 12),
                  
                  // Legal links
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: isTablet ? 11 : 10,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        children: [
                          TextSpan(
                            text: context.l10n.privacyPolicy,
                            style: const TextStyle(decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _launchUrlInApp(context.l10n.privacyPolicyUrl),
                          ),
                          const TextSpan(text: '  |  '),
                          TextSpan(
                            text: context.l10n.termsOfService,
                            style: const TextStyle(decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _launchUrlInApp(context.l10n.termsOfServiceUrl),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index, Size screenSize) {
    final random = math.Random(index * 42);
    final startX = random.nextDouble() * screenSize.width;
    final startY = random.nextDouble() * screenSize.height;
    final size = 4 + random.nextDouble() * 6;
    final speed = 0.3 + random.nextDouble() * 0.7;
    final delay = random.nextDouble();

    return AnimatedBuilder(
      animation: _particleAnimController,
      builder: (context, child) {
        final t = ((_particleAnimController.value + delay) % 1.0) * speed;
        final x = startX + math.sin(t * math.pi * 2 + index) * 30;
        final y = startY - t * screenSize.height * 0.3;
        final opacity = (1 - t) * 0.25;

        return Positioned(
          left: x,
          top: y % screenSize.height,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentColor.withValues(alpha: opacity),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withValues(alpha: opacity * 0.5),
                  blurRadius: size * 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
