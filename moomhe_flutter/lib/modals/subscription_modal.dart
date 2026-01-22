import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../services/purchase_service.dart' show PurchaseService, PurchaseUiStatus, ProductIds;
import '../services/analytics_service.dart';
import '../l10n/localized_options.dart';

class SubscriptionPlan {
  final String name;
  final int credits;
  final String productId;
  final String mainFeature;
  final List<String> extraFeatures;
  final bool isPopular;
  final bool isProfessional;
  final String? discount;
  final String? badgeText;

  const SubscriptionPlan({
    required this.name,
    required this.credits,
    required this.productId,
    required this.mainFeature,
    this.extraFeatures = const [],
    this.isPopular = false,
    this.isProfessional = false,
    this.discount,
    this.badgeText,
  });
}

class SubscriptionModal extends StatefulWidget {
  final int currentSubscription;
  final int currentCredits;
  final VoidCallback? onPurchaseComplete;

  const SubscriptionModal({
    super.key,
    required this.currentSubscription,
    required this.currentCredits,
    this.onPurchaseComplete,
  });

  @override
  State<SubscriptionModal> createState() => _SubscriptionModalState();
}

class _SubscriptionModalState extends State<SubscriptionModal> with TickerProviderStateMixin, WidgetsBindingObserver {
  final PurchaseService _purchaseService = PurchaseService();
  final AnalyticsService _analytics = AnalyticsService();
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  String? _purchasingProductId;
  bool _userInitiatedPurchase = false; // Track if user actually started a purchase
  DateTime? _purchaseStartTime; // Track when purchase was initiated

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _plansController;
  late AnimationController _footerController;
  
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _footerFadeAnimation;

  // Monthly subscription plans - loaded from localization
  List<SubscriptionPlan> _getPlans(BuildContext context) {
    final l10n = context.l10n;
    return [
      SubscriptionPlan(
        name: l10n.starterPlan,
        credits: 50,
        productId: ProductIds.starterMonthly,
        mainFeature: l10n.imagesPerMonth(50),
      ),
      SubscriptionPlan(
        name: l10n.valuePlan,
        credits: 200,
        productId: ProductIds.proMonthly,
        mainFeature: l10n.imagesPerMonth(200),
        extraFeatures: [
          l10n.whatsappSupport,
          l10n.historyStorage,
        ],
        isPopular: true,
        badgeText: l10n.bestValue,
        discount: l10n.savePerImage('35'),
      ),
      SubscriptionPlan(
        name: l10n.proPlan,
        credits: 450,
        productId: ProductIds.businessMonthly,
        mainFeature: l10n.imagesPerMonth(450),
        extraFeatures: [
          l10n.vipWhatsappSupport,
          l10n.processingPriority,
        ],
        isProfessional: true,
        badgeText: l10n.forProfessionals,
        discount: l10n.savePerImage('42'),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAnimations();
    _initializePurchases();
  }

  void _initAnimations() {
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

    // Plans animation
    _plansController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Footer animation
    _footerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _footerController, curve: Curves.easeOut),
    );

    // Start animations with stagger
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _plansController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _footerController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _headerController.dispose();
    _plansController.dispose();
    _footerController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes from background (after purchase dialog dismissed)
    if (state == AppLifecycleState.resumed && _purchasingProductId != null) {
      // Give a longer delay for purchase callbacks to fire first
      // The purchase verification can take a few seconds
      Future.delayed(const Duration(seconds: 5), () {
        // If still showing loader after resuming, user likely cancelled
        if (mounted && _purchasingProductId != null && _purchaseStartTime != null) {
          final elapsed = DateTime.now().difference(_purchaseStartTime!);
          // Only reset loader if purchase was started more than 5 seconds ago
          if (elapsed.inSeconds >= 5) {
            debugPrint('📱 App resumed - resetting loader (purchase likely cancelled or completed)');
            setState(() {
              _isPurchasing = false;
              _purchasingProductId = null;
              _purchaseStartTime = null;
              // DON'T reset _userInitiatedPurchase here!
              // The success callback might still come through
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
          // Always call onPurchaseComplete to refresh user data
          widget.onPurchaseComplete?.call();
          // Only close modal if user actually initiated a purchase
          // (not for automatic restore on init)
          if (_userInitiatedPurchase) {
            _userInitiatedPurchase = false;
            Navigator.pop(context);
          }
          break;
        case PurchaseUiStatus.error:
          _isPurchasing = false;
          _purchasingProductId = null;
          _purchaseStartTime = null;
          // Only show error if user initiated purchase
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

  ProductDetails? _getProductDetails(SubscriptionPlan plan) {
    return _purchaseService.getProduct(plan.productId);
  }

  String _getPrice(SubscriptionPlan plan) {
    final product = _getProductDetails(plan);
    if (product != null) {
      return product.price;
    }
    // Fallback prices
    switch (plan.credits) {
      case 50:
        return '\$5';
      case 200:
        return '\$13';
      case 450:
        return '\$27';
    }
    return '';
  }

  Future<void> _handlePurchase(SubscriptionPlan plan) async {
    final productId = plan.productId;
    final price = _getPrice(plan);
    
    // Track subscription plan selected
    _analytics.logSubscriptionPlanSelected(
      productId: productId,
      tierName: plan.name,
      credits: plan.credits,
      price: price,
    );
    
    setState(() {
      _purchasingProductId = productId;
      _errorMessage = null;
      _userInitiatedPurchase = true;
      _purchaseStartTime = DateTime.now();
    });

    final success = await _purchaseService.purchaseSubscription(productId);
    
    // If purchase initiation returned false, reset immediately
    if (!success && mounted && _purchasingProductId == productId) {
      // Track purchase cancelled
      _analytics.logSubscriptionPurchaseCancelled(productId: productId);
      setState(() {
        _isPurchasing = false;
        _purchasingProductId = null;
        _userInitiatedPurchase = false;
        _purchaseStartTime = null;
      });
    }
    // If success, the lifecycle observer will handle resetting if user cancels
  }

  bool _isPlanCurrent(SubscriptionPlan plan) {
    return (widget.currentSubscription == 1 && plan.credits == 50) ||
        (widget.currentSubscription == 2 && plan.credits == 200) ||
        (widget.currentSubscription == 3 && plan.credits == 450);
  }

  Future<void> _launchUrlInApp(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  // Check if we're on a tablet/iPad (width > 600)
  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.secondary500.withValues(alpha: 0.15),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with close button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 8, vertical: isTablet ? 12 : 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceHighlight,
                    ),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),

              // Header - animated
              SlideTransition(
                position: _headerSlideAnimation,
                child: FadeTransition(
                  opacity: _headerFadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
                    child: Column(
                      children: [
                        Text(
                          context.l10n.professionalSubscription,
                          style: TextStyle(
                            fontSize: isTablet ? 36 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 18 : 14,
                            vertical: isTablet ? 7 : 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary500, AppColors.secondary600],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            context.l10n.specialLaunchPrices,
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 24 : 12),

              // Error message
              if (_errorMessage != null)
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 48 : 16,
                    vertical: 4,
                  ),
                  constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertCircle, color: Colors.red.shade400, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Plans - takes remaining space with animations and scroll support
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary500,
                        ),
                      )
                    : Builder(
                        builder: (builderContext) {
                          final plans = _getPlans(builderContext);
                          
                          // Tablet layout: horizontal row of plan cards
                          if (isTablet) {
                            return Center(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth > 1000 ? 80 : 32,
                                  vertical: 16,
                                ),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 1100),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(plans.length, (index) {
                                      return Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: index == 0 ? 0 : 12,
                                            right: index == plans.length - 1 ? 0 : 12,
                                          ),
                                          child: AnimatedBuilder(
                                            animation: _plansController,
                                            builder: (animContext, child) {
                                              final delay = index * 0.15;
                                              final start = delay;
                                              final end = (delay + 0.6).clamp(0.0, 1.0);
                                              
                                              final curvedAnimation = CurvedAnimation(
                                                parent: _plansController,
                                                curve: Interval(start, end, curve: Curves.easeOutCubic),
                                              );
                                              
                                              final slideOffset = Tween<Offset>(
                                                begin: const Offset(0, 0.3),
                                                end: Offset.zero,
                                              ).evaluate(curvedAnimation);
                                              
                                              final opacity = Tween<double>(
                                                begin: 0.0,
                                                end: 1.0,
                                              ).evaluate(curvedAnimation);
                                              
                                              final scale = Tween<double>(
                                                begin: 0.9,
                                                end: 1.0,
                                              ).evaluate(curvedAnimation);
                                              
                                              return Transform.translate(
                                                offset: Offset(0, slideOffset.dy * 50),
                                                child: Opacity(
                                                  opacity: opacity,
                                                  child: Transform.scale(
                                                    scale: scale,
                                                    child: _buildTabletPlanCard(plans[index]),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          // Phone layout: vertical list of compact cards
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: List.generate(plans.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: index == 0 ? 8 : 12,
                                    bottom: index == plans.length - 1 ? 8 : 0,
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _plansController,
                                    builder: (animContext, child) {
                                      final delay = index * 0.15;
                                      final start = delay;
                                      final end = (delay + 0.6).clamp(0.0, 1.0);
                                      
                                      final curvedAnimation = CurvedAnimation(
                                        parent: _plansController,
                                        curve: Interval(start, end, curve: Curves.easeOutCubic),
                                      );
                                      
                                      final slideOffset = Tween<Offset>(
                                        begin: Offset(index.isEven ? -0.5 : 0.5, 0),
                                        end: Offset.zero,
                                      ).evaluate(curvedAnimation);
                                      
                                      final opacity = Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).evaluate(curvedAnimation);
                                      
                                      final scale = Tween<double>(
                                        begin: 0.9,
                                        end: 1.0,
                                      ).evaluate(curvedAnimation);
                                      
                                      return Transform.translate(
                                        offset: Offset(slideOffset.dx * 100, 0),
                                        child: Opacity(
                                          opacity: opacity,
                                          child: Transform.scale(
                                            scale: scale,
                                            child: _buildCompactPlanCard(plans[index]),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                            ),
                          );
                        },
                      ),
              ),

              // Footer with restore purchases - animated
              FadeTransition(
                opacity: _footerFadeAnimation,
                child: Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 16 : 8),
                  child: Column(
                    children: [
                      // All plans include
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: isTablet ? 16 : 8,
                          runSpacing: 8,
                          children: [
                            _buildFeatureChip(context.l10n.allDesignTools, isTablet: isTablet),
                            _buildFeatureChip(context.l10n.fastSupport, isTablet: isTablet),
                            _buildFeatureChip(context.l10n.noAds, isTablet: isTablet),
                          ],
                        ),
                      ),
                      // Restore purchases - required by Apple, only shown on iOS
                      if (Platform.isIOS) ...[
                        SizedBox(height: isTablet ? 16 : 10),
                        TextButton(
                          onPressed: _isPurchasing
                              ? null
                              : () {
                                  // Track restore purchases
                                  _analytics.logRestorePurchases();
                                  setState(() {
                                    _userInitiatedPurchase = true; // User explicitly requested restore
                                  });
                                  _purchaseService.restorePurchases();
                                },
                          child: Text(
                            context.l10n.restorePurchases,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: isTablet ? 15 : 13,
                            ),
                          ),
                        ),
                      ] else
                        SizedBox(height: isTablet ? 24 : 16),
                      // Privacy Policy and Terms of Use links
                      Padding(
                        padding: EdgeInsets.only(
                          top: Platform.isIOS ? 0 : 0,
                          bottom: isTablet ? 8 : 4,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 11,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            children: [
                              TextSpan(
                                text: context.l10n.privacyPolicy,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _launchUrlInApp(context.l10n.privacyPolicyUrl),
                              ),
                              const TextSpan(text: '  |  '),
                              TextSpan(
                                text: context.l10n.termsOfService,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String text, {bool isTablet = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 14 : 10,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.check, size: isTablet ? 14 : 12, color: AppColors.secondary400),
          SizedBox(width: isTablet ? 6 : 4),
          Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = _isPlanCurrent(plan);
    final isPurchasingThis = _purchasingProductId == plan.productId;
    final price = _getPrice(plan);

    // Define colors based on plan type
    final Color accentColor;
    final Color priceColor;
    final Color checkColor;
    
    if (plan.isProfessional) {
      accentColor = const Color(0xFFFFB300);
      priceColor = const Color(0xFFFFB300);
      checkColor = const Color(0xFFFFB300);
    } else if (plan.isPopular) {
      accentColor = const Color(0xFFFFD54F);
      priceColor = const Color(0xFFFFD54F);
      checkColor = const Color(0xFF26A69A);
    } else {
      accentColor = Colors.white;
      priceColor = Colors.white;
      checkColor = const Color(0xFF26A69A);
    }

    Widget cardContent = Container(
      decoration: BoxDecoration(
        gradient: plan.isProfessional
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D2E1F), Color(0xFF2A2015)],
              )
            : null,
        color: plan.isProfessional
            ? null
            : plan.isPopular
                ? AppColors.surfaceHighlight.withValues(alpha: 0.5)
                : AppColors.surfaceHighlight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: plan.isProfessional
              ? const Color(0xFFFFB300).withValues(alpha: 0.5)
              : plan.isPopular
                  ? const Color(0xFFFFD54F).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
          width: (plan.isPopular || plan.isProfessional) ? 1.5 : 1,
        ),
        boxShadow: plan.isProfessional
            ? [BoxShadow(color: const Color(0xFFFFB300).withValues(alpha: 0.2), blurRadius: 12)]
            : plan.isPopular
                ? [BoxShadow(color: const Color(0xFFFFD54F).withValues(alpha: 0.12), blurRadius: 10)]
                : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Badge - Popular
          if (plan.isPopular && plan.badgeText != null)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFC107)]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: const Color(0xFFFFD54F).withValues(alpha: 0.4), blurRadius: 6)],
                  ),
                  child: Text(
                    plan.badgeText!,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ),
            ),

          // Badge - Professional (centered like popular badge)
          if (plan.isProfessional && plan.badgeText != null)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF8F00)]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: const Color(0xFFFFB300).withValues(alpha: 0.4), blurRadius: 6)],
                  ),
                  child: Text(
                    plan.badgeText!,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.fromLTRB(12, (plan.isPopular || plan.isProfessional) ? 14 : 10, 12, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: plan.isProfessional ? const Color(0xFFFFD54F) : accentColor,
                            ),
                          ),
                          if (plan.discount != null)
                            Text(
                              plan.discount!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: plan.isProfessional 
                                    ? const Color(0xFFFFB300)
                                    : plan.isPopular
                                        ? const Color(0xFFFFD54F)
                                        : Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(price, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: priceColor)),
                        Text(context.l10n.perMonth, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                Column(
                  children: [
                    _buildFeatureRow(plan.mainFeature, checkColor),
                    ...plan.extraFeatures.map((feature) => _buildFeatureRow(feature, checkColor)),
                  ],
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: isPurchasingThis
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          ),
                        )
                      : isCurrentPlan
                          ? Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF26A69A).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF26A69A).withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.checkCircle, size: 14, color: const Color(0xFF26A69A)),
                                  const SizedBox(width: 6),
                                  Text(context.l10n.yourCurrentPlan, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF26A69A))),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: plan.isProfessional ? const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF8F00)]) : null,
                                color: plan.isProfessional ? null : Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: plan.isProfessional ? null : Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Center(
                                child: Text(
                                  context.l10n.selectPlan,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: plan.isProfessional ? Colors.black87 : Colors.white),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: (isCurrentPlan || _isPurchasing) ? null : () => _handlePurchase(plan),
      child: cardContent,
    );
  }

  // Tablet-optimized plan card with vertical layout for side-by-side display
  Widget _buildTabletPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = _isPlanCurrent(plan);
    final isPurchasingThis = _purchasingProductId == plan.productId;
    final price = _getPrice(plan);

    // Define colors based on plan type
    final Color accentColor;
    final Color priceColor;
    final Color checkColor;
    
    if (plan.isProfessional) {
      accentColor = const Color(0xFFFFB300);
      priceColor = const Color(0xFFFFB300);
      checkColor = const Color(0xFFFFB300);
    } else if (plan.isPopular) {
      accentColor = const Color(0xFFFFD54F);
      priceColor = const Color(0xFFFFD54F);
      checkColor = const Color(0xFF26A69A);
    } else {
      accentColor = Colors.white;
      priceColor = Colors.white;
      checkColor = const Color(0xFF26A69A);
    }

    Widget cardContent = Container(
      constraints: const BoxConstraints(minHeight: 320),
      decoration: BoxDecoration(
        gradient: plan.isProfessional
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D2E1F), Color(0xFF2A2015)],
              )
            : null,
        color: plan.isProfessional
            ? null
            : plan.isPopular
                ? AppColors.surfaceHighlight.withValues(alpha: 0.5)
                : AppColors.surfaceHighlight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.isProfessional
              ? const Color(0xFFFFB300).withValues(alpha: 0.5)
              : plan.isPopular
                  ? const Color(0xFFFFD54F).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
          width: (plan.isPopular || plan.isProfessional) ? 2 : 1,
        ),
        boxShadow: plan.isProfessional
            ? [BoxShadow(color: const Color(0xFFFFB300).withValues(alpha: 0.25), blurRadius: 20)]
            : plan.isPopular
                ? [BoxShadow(color: const Color(0xFFFFD54F).withValues(alpha: 0.15), blurRadius: 16)]
                : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Badge - Popular
          if (plan.isPopular && plan.badgeText != null)
            Positioned(
              top: -14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFC107)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: const Color(0xFFFFD54F).withValues(alpha: 0.4), blurRadius: 8)],
                  ),
                  child: Text(
                    plan.badgeText!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ),
            ),

          // Badge - Professional
          if (plan.isProfessional && plan.badgeText != null)
            Positioned(
              top: -14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF8F00)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: const Color(0xFFFFB300).withValues(alpha: 0.4), blurRadius: 8)],
                  ),
                  child: Text(
                    plan.badgeText!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, (plan.isPopular || plan.isProfessional) ? 24 : 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Plan name
                Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: plan.isProfessional ? const Color(0xFFFFD54F) : accentColor,
                  ),
                ),
                if (plan.discount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan.discount!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: plan.isProfessional 
                          ? const Color(0xFFFFB300)
                          : plan.isPopular
                              ? const Color(0xFFFFD54F)
                              : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(price, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: priceColor)),
                    Text(context.l10n.perMonth, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Features
                Column(
                  children: [
                    _buildTabletFeatureRow(plan.mainFeature, checkColor),
                    ...plan.extraFeatures.map((feature) => _buildTabletFeatureRow(feature, checkColor)),
                    // Add placeholder rows for consistent height
                    if (plan.extraFeatures.isEmpty) ...[
                      _buildTabletFeatureRow('', Colors.transparent, isEmpty: true),
                      _buildTabletFeatureRow('', Colors.transparent, isEmpty: true),
                    ] else if (plan.extraFeatures.length == 1)
                      _buildTabletFeatureRow('', Colors.transparent, isEmpty: true),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: isPurchasingThis
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          ),
                        )
                      : isCurrentPlan
                          ? Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF26A69A).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF26A69A).withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.checkCircle, size: 18, color: const Color(0xFF26A69A)),
                                  const SizedBox(width: 8),
                                  Text(context.l10n.yourCurrentPlan, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF26A69A))),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: plan.isProfessional ? const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF8F00)]) : null,
                                color: plan.isProfessional ? null : Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: plan.isProfessional ? null : Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Center(
                                child: Text(
                                  context.l10n.selectPlan,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: plan.isProfessional ? Colors.black87 : Colors.white),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: (isCurrentPlan || _isPurchasing) ? null : () => _handlePurchase(plan),
      child: cardContent,
    );
  }

  Widget _buildTabletFeatureRow(String feature, Color checkColor, {bool isEmpty = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isEmpty) Icon(LucideIcons.check, size: 16, color: checkColor),
          if (!isEmpty) const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
              fontSize: 14,
              color: isEmpty ? Colors.transparent : Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, Color checkColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(LucideIcons.check, size: 14, color: checkColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(feature, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
          ),
        ],
      ),
    );
  }
}
