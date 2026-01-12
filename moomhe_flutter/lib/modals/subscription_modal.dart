import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../theme/app_colors.dart';
import '../services/purchase_service.dart' show PurchaseService, PurchaseUiStatus, ProductIds;

class SubscriptionPlan {
  final String name;
  final int credits;
  final String productId;
  final String mainFeature;
  final List<String> extraFeatures;
  final bool isPopular;
  final String? discount;

  const SubscriptionPlan({
    required this.name,
    required this.credits,
    required this.productId,
    required this.mainFeature,
    this.extraFeatures = const [],
    this.isPopular = false,
    this.discount,
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

class _SubscriptionModalState extends State<SubscriptionModal> with TickerProviderStateMixin {
  final PurchaseService _purchaseService = PurchaseService();
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  String? _purchasingProductId;

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _plansController;
  late AnimationController _footerController;
  
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _footerFadeAnimation;

  // Monthly subscription plans (Hebrew)
  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      name: 'מתחיל',
      credits: 50,
      productId: ProductIds.starterMonthly,
      mainFeature: '50 תמונות בחודש',
    ),
    SubscriptionPlan(
      name: 'משתלם',
      credits: 200,
      productId: ProductIds.proMonthly,
      mainFeature: '200 תמונות בחודש',
      extraFeatures: [
        'תמיכה בווצאפ',
        'גישה מוקדמת לפיצ\'רים',
      ],
      isPopular: true,
      discount: 'חסוך 35%',
    ),
    SubscriptionPlan(
      name: 'מקצועי',
      credits: 450,
      productId: ProductIds.businessMonthly,
      mainFeature: '450 תמונות בחודש',
      extraFeatures: [
        'תמיכה VIP בווצאפ',
        'עדיפות בתור העיבוד',
      ],
      discount: 'חסוך 50%',
    ),
  ];

  @override
  void initState() {
    super.initState();
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
    _headerController.dispose();
    _plansController.dispose();
    _footerController.dispose();
    super.dispose();
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
          Navigator.pop(context);
          widget.onPurchaseComplete?.call();
          break;
        case PurchaseUiStatus.error:
          _isPurchasing = false;
          _purchasingProductId = null;
          _errorMessage = message ?? 'הרכישה נכשלה';
          break;
        case PurchaseUiStatus.cancelled:
          _isPurchasing = false;
          _purchasingProductId = null;
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
    setState(() {
      _purchasingProductId = plan.productId;
      _errorMessage = null;
    });

    await _purchaseService.purchaseSubscription(plan.productId);
  }

  bool _isPlanCurrent(SubscriptionPlan plan) {
    return (widget.currentSubscription == 1 && plan.credits == 50) ||
        (widget.currentSubscription == 2 && plan.credits == 200) ||
        (widget.currentSubscription == 3 && plan.credits == 450);
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Text(
                          'מנוי מקצועי',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary500, AppColors.secondary600],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'מחירי השקה מיוחדים 🚀',
                            style: TextStyle(
                              fontSize: 12,
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

              const SizedBox(height: 12),

              // Error message
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

              // Plans - takes remaining space with animations
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary500,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(plans.length, (index) {
                            return AnimatedBuilder(
                              animation: _plansController,
                              builder: (context, child) {
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
                            );
                          }),
                        ),
                      ),
              ),

              // Footer with restore purchases - animated
              FadeTransition(
                opacity: _footerFadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: [
                      // All plans include
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFeatureChip('כל כלי העיצוב'),
                            const SizedBox(width: 8),
                            _buildFeatureChip('תמיכה מהירה'),
                            const SizedBox(width: 8),
                            _buildFeatureChip('ללא פרסומות'),
                          ],
                        ),
                      ),
                      // Restore purchases - required by Apple, only shown on iOS
                      if (Platform.isIOS) ...[
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _isPurchasing
                              ? null
                              : () => _purchaseService.restorePurchases(),
                          child: Text(
                            'שחזור רכישות',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ] else
                        const SizedBox(height: 16),
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

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.check, size: 12, color: AppColors.secondary400),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
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
    final hasExtraFeatures = plan.extraFeatures.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: plan.isPopular
            ? AppColors.surfaceHighlight.withValues(alpha: 0.5)
            : AppColors.surfaceHighlight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isPopular
              ? AppColors.secondary500.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.1),
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: plan.isPopular
            ? [
                BoxShadow(
                  color: AppColors.secondary500.withValues(alpha: 0.2),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Popular badge
          if (plan.isPopular)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary500,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'הכי משתלם 🔥',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.fromLTRB(16, plan.isPopular ? 16 : 12, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Plan info (left side)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                plan.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: plan.isPopular ? AppColors.secondary300 : Colors.white,
                                ),
                              ),
                              if (plan.discount != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    plan.discount!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.mainFeature,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price and button (right side)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: plan.isPopular ? AppColors.secondary400 : Colors.white,
                              ),
                            ),
                            Text(
                              '/חודש',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 100,
                          height: 36,
                          child: ElevatedButton(
                            onPressed: isCurrentPlan || _isPurchasing
                                ? null
                                : () => _handlePurchase(plan),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCurrentPlan
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : plan.isPopular
                                      ? AppColors.secondary500
                                      : Colors.white.withValues(alpha: 0.1),
                              disabledBackgroundColor: isCurrentPlan
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.2),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isCurrentPlan
                                      ? Colors.green.withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                            child: isPurchasingThis
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : isCurrentPlan
                                    ? Icon(
                                        LucideIcons.checkCircle,
                                        size: 18,
                                        color: Colors.green.shade400,
                                      )
                                    : const Text(
                                        'בחר',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Extra features row
                if (hasExtraFeatures) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: plan.extraFeatures.map((feature) => Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.sparkles,
                            size: 12,
                            color: plan.isPopular 
                                ? AppColors.secondary400 
                                : AppColors.primary400,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
