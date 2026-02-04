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
  final IconData icon;
  final List<Color> gradientColors;
  final int? freeTrialDays;

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
    required this.icon,
    required this.gradientColors,
    this.freeTrialDays,
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
  bool _userInitiatedPurchase = false;
  DateTime? _purchaseStartTime;

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _plansController;
  late AnimationController _footerController;
  late AnimationController _backgroundAnimController;
  late AnimationController _particleAnimController;
  
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _footerFadeAnimation;

  // Primary gradient colors matching carousel gold theme
  static const List<Color> _primaryGradient = [Color(0xFFB59259), Color(0xFFD4A574)];
  static const Color _accentColor = Color(0xFFB59259);

  // Monthly subscription plans
  List<SubscriptionPlan> _getPlans(BuildContext context) {
    final l10n = context.l10n;
    return [
      SubscriptionPlan(
        name: l10n.starterPlan,
        credits: 50,
        productId: ProductIds.starterMonthly,
        mainFeature: l10n.imagesPerMonth(50),
        icon: LucideIcons.sparkle,
        gradientColors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
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
        icon: LucideIcons.flame,
        gradientColors: _primaryGradient,
        freeTrialDays: 3,
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
        icon: LucideIcons.crown,
        gradientColors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
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
    // Background animation for gradient movement
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
    _backgroundAnimController.dispose();
    _particleAnimController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _purchasingProductId != null) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _purchasingProductId != null && _purchaseStartTime != null) {
          final elapsed = DateTime.now().difference(_purchaseStartTime!);
          if (elapsed.inSeconds >= 5) {
            debugPrint('📱 App resumed - resetting loader (purchase likely cancelled or completed)');
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

  ProductDetails? _getProductDetails(SubscriptionPlan plan) {
    return _purchaseService.getProduct(plan.productId);
  }

  String _getPrice(SubscriptionPlan plan) {
    final product = _getProductDetails(plan);
    if (product != null) {
      return product.price;
    }
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

  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background gradient (matching carousel)
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

          // Floating particles (matching carousel)
          ...List.generate(10, (index) => _buildFloatingParticle(index, screenSize)),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with close button and header badge on the same row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 12 : 8),
                  child: Row(
                    children: [
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 22),
                        ),
                      ),
                      
                      // Spacer to center the badge
                      const Spacer(),
                      
                      // Header badge - animated (matching carousel style)
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
                      
                      // Spacer to balance the close button width
                      const Spacer(),
                      
                      // Invisible placeholder to balance the row
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 16 : 8),

                // Error message
                if (_errorMessage != null)
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isTablet ? 48 : 16,
                      vertical: 4,
                    ),
                    constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
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

                // Plans
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
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                      : Builder(
                          builder: (builderContext) {
                            final plans = _getPlans(builderContext);
                            
                            if (isTablet) {
                              return Center(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenSize.width > 1000 ? 80 : 32,
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
                                            child: _buildAnimatedPlanCard(plans[index], index, isTablet: true),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            return SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Column(
                                children: List.generate(plans.length, (index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: index == 0 ? 8 : 16,
                                      bottom: index == plans.length - 1 ? 8 : 0,
                                    ),
                                    child: _buildAnimatedPlanCard(plans[index], index, isTablet: false),
                                  );
                                }),
                              ),
                            );
                          },
                        ),
                ),

                // Footer
                FadeTransition(
                  opacity: _footerFadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isTablet ? 16 : 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: isTablet ? 16 : 10,
                            runSpacing: 8,
                            children: [
                              _buildFeatureChip(context.l10n.allDesignTools, isTablet: isTablet),
                              _buildFeatureChip(context.l10n.fastSupport, isTablet: isTablet),
                              _buildFeatureChip(context.l10n.noAds, isTablet: isTablet),
                            ],
                          ),
                        ),
                        if (Platform.isIOS) ...[
                          SizedBox(height: isTablet ? 16 : 10),
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
        ],
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

  Widget _buildFeatureChip(String text, {bool isTablet = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 14 : 12,
        vertical: isTablet ? 6 : 5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryGradient[0].withValues(alpha: 0.15),
            _primaryGradient[1].withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryGradient[0].withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(colors: _primaryGradient).createShader(bounds),
            child: Icon(LucideIcons.check, size: isTablet ? 14 : 12, color: Colors.white),
          ),
          SizedBox(width: isTablet ? 6 : 5),
          Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 12 : 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPlanCard(SubscriptionPlan plan, int index, {required bool isTablet}) {
    return AnimatedBuilder(
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
          begin: isTablet ? const Offset(0, 0.3) : Offset(index.isEven ? -0.5 : 0.5, 0),
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
          offset: isTablet 
              ? Offset(0, slideOffset.dy * 50)
              : Offset(slideOffset.dx * 100, 0),
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: isTablet 
                  ? _buildTabletPlanCard(plan)
                  : _buildCompactPlanCard(plan),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = _isPlanCurrent(plan);
    final isPurchasingThis = _purchasingProductId == plan.productId;
    final price = _getPrice(plan);
    final gradientColors = plan.gradientColors;

    Widget cardContent = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0].withValues(alpha: 0.12),
            gradientColors[1].withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradientColors[0].withValues(alpha: plan.isPopular ? 0.5 : 0.3),
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: plan.isPopular ? 0.25 : 0.15),
            blurRadius: plan.isPopular ? 20 : 12,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Badge
          if (plan.badgeText != null)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    plan.badgeText!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.fromLTRB(16, plan.badgeText != null ? 20 : 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            gradientColors[0].withValues(alpha: 0.2),
                            gradientColors[1].withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                          color: gradientColors[0].withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(colors: gradientColors).createShader(bounds),
                          child: Icon(plan.icon, size: 24, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (plan.discount != null)
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(colors: gradientColors).createShader(bounds),
                              child: Text(
                                plan.discount!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(colors: gradientColors).createShader(bounds),
                          child: Text(
                            price,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          context.l10n.perMonth,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Column(
                  children: [
                    _buildFeatureRow(plan.mainFeature, gradientColors[0]),
                    ...plan.extraFeatures.map((feature) => _buildFeatureRow(feature, gradientColors[0])),
                  ],
                ),
                
                // Free trial badge - prominent design
                if (plan.freeTrialDays != null && !isCurrentPlan) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          gradientColors[0].withValues(alpha: 0.25),
                          gradientColors[1].withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: gradientColors[0].withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: gradientColors),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.gift, size: 16, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(colors: gradientColors).createShader(bounds),
                              child: Text(
                                context.l10n.freeTrialDays(plan.freeTrialDays!).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.thenPrice(price),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 14),

                // CTA Button (visual only - entire card is clickable)
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isCurrentPlan
                        ? null
                        : LinearGradient(colors: gradientColors),
                    color: isCurrentPlan ? const Color(0xFF26A69A).withValues(alpha: 0.2) : null,
                    borderRadius: BorderRadius.circular(14),
                    border: isCurrentPlan
                        ? Border.all(color: const Color(0xFF26A69A).withValues(alpha: 0.5))
                        : null,
                    boxShadow: isCurrentPlan
                        ? null
                        : [
                            BoxShadow(
                              color: gradientColors[0].withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: isPurchasingThis
                      ? const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isCurrentPlan) ...[
                              const Icon(LucideIcons.checkCircle, size: 18, color: Color(0xFF26A69A)),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              isCurrentPlan 
                                  ? context.l10n.yourCurrentPlan 
                                  : (plan.freeTrialDays != null ? context.l10n.freeTrialDays(plan.freeTrialDays!) : context.l10n.selectPlan),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isCurrentPlan ? const Color(0xFF26A69A) : Colors.white,
                              ),
                            ),
                            if (!isCurrentPlan) ...[
                              const SizedBox(width: 6),
                              const Icon(LucideIcons.arrowRight, size: 18, color: Colors.white),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Wrap entire card in GestureDetector
    return GestureDetector(
      onTap: (isCurrentPlan || _isPurchasing) ? null : () => _handlePurchase(plan),
      child: cardContent,
    );
  }

  Widget _buildTabletPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = _isPlanCurrent(plan);
    final isPurchasingThis = _purchasingProductId == plan.productId;
    final price = _getPrice(plan);
    final gradientColors = plan.gradientColors;

    Widget cardContent = Container(
      constraints: const BoxConstraints(minHeight: 380),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0].withValues(alpha: 0.12),
            gradientColors[1].withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: gradientColors[0].withValues(alpha: plan.isPopular ? 0.5 : 0.3),
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: plan.isPopular ? 0.3 : 0.15),
            blurRadius: plan.isPopular ? 24 : 16,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Badge
          if (plan.badgeText != null)
            Positioned(
              top: -14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    plan.badgeText!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.fromLTRB(24, plan.badgeText != null ? 28 : 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        gradientColors[0].withValues(alpha: 0.2),
                        gradientColors[1].withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: gradientColors[0].withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(colors: gradientColors).createShader(bounds),
                      child: Icon(plan.icon, size: 36, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Plan name
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (plan.discount != null) ...[
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(colors: gradientColors).createShader(bounds),
                    child: Text(
                      plan.discount!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
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
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(colors: gradientColors).createShader(bounds),
                      child: Text(
                        price,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.perMonth,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Features
                Column(
                  children: [
                    _buildTabletFeatureRow(plan.mainFeature, gradientColors[0]),
                    ...plan.extraFeatures.map((feature) => _buildTabletFeatureRow(feature, gradientColors[0])),
                    if (plan.extraFeatures.isEmpty) ...[
                      _buildTabletFeatureRow('', Colors.transparent, isEmpty: true),
                      _buildTabletFeatureRow('', Colors.transparent, isEmpty: true),
                    ] else if (plan.extraFeatures.length == 1)
                      _buildTabletFeatureRow('', Colors.transparent, isEmpty: true),
                  ],
                ),
                
                // Free trial badge - prominent design
                if (plan.freeTrialDays != null && !isCurrentPlan) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          gradientColors[0].withValues(alpha: 0.25),
                          gradientColors[1].withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: gradientColors[0].withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 0,
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
                                gradient: LinearGradient(colors: gradientColors),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.gift, size: 20, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(colors: gradientColors).createShader(bounds),
                              child: Text(
                                context.l10n.freeTrialDays(plan.freeTrialDays!).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
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
                          context.l10n.thenPrice(price),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // CTA Button (visual only - entire card is clickable)
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: isCurrentPlan
                        ? null
                        : LinearGradient(colors: gradientColors),
                    color: isCurrentPlan ? const Color(0xFF26A69A).withValues(alpha: 0.2) : null,
                    borderRadius: BorderRadius.circular(16),
                    border: isCurrentPlan
                        ? Border.all(color: const Color(0xFF26A69A).withValues(alpha: 0.5))
                        : null,
                    boxShadow: isCurrentPlan
                        ? null
                        : [
                            BoxShadow(
                              color: gradientColors[0].withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: isPurchasingThis
                      ? const Center(
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isCurrentPlan) ...[
                              const Icon(LucideIcons.checkCircle, size: 20, color: Color(0xFF26A69A)),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              isCurrentPlan 
                                  ? context.l10n.yourCurrentPlan 
                                  : (plan.freeTrialDays != null ? context.l10n.freeTrialDays(plan.freeTrialDays!) : context.l10n.selectPlan),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isCurrentPlan ? const Color(0xFF26A69A) : Colors.white,
                              ),
                            ),
                            if (!isCurrentPlan) ...[
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.arrowRight, size: 20, color: Colors.white),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Wrap entire card in GestureDetector
    return GestureDetector(
      onTap: (isCurrentPlan || _isPurchasing) ? null : () => _handlePurchase(plan),
      child: cardContent,
    );
  }

  Widget _buildTabletFeatureRow(String feature, Color checkColor, {bool isEmpty = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(LucideIcons.check, size: 16, color: checkColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
