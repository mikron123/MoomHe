import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../l10n/localized_options.dart';

/// A stunning full-screen feature carousel for first-time users
/// Showcases the app's key features with impressive animations
class FeatureCarousel extends StatefulWidget {
  final VoidCallback onComplete;

  const FeatureCarousel({
    super.key,
    required this.onComplete,
  });

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundAnimController;
  late AnimationController _contentAnimController;
  late AnimationController _particleAnimController;
  int _currentPage = 0;

  // Feature slide data
  List<_FeatureSlide> _getSlides(BuildContext context) {
    final l10n = context.l10n;
    return [
      _FeatureSlide(
        icon: LucideIcons.sparkles,
        title: l10n.featureCarouselTitle1,
        subtitle: l10n.featureCarouselSubtitle1,
        description: l10n.featureCarouselDesc1,
        gradientColors: [
          const Color(0xFF667EEA),
          const Color(0xFF764BA2),
        ],
        accentColor: const Color(0xFF667EEA),
      ),
      _FeatureSlide(
        icon: LucideIcons.palette,
        title: l10n.featureCarouselTitle2,
        subtitle: l10n.featureCarouselSubtitle2,
        description: l10n.featureCarouselDesc2,
        gradientColors: [
          const Color(0xFFB59259),
          const Color(0xFFD4A574),
        ],
        accentColor: AppColors.secondary500,
      ),
      _FeatureSlide(
        icon: LucideIcons.zap,
        title: l10n.featureCarouselTitle3,
        subtitle: l10n.featureCarouselSubtitle3,
        description: l10n.featureCarouselDesc3,
        gradientColors: [
          const Color(0xFF11998E),
          const Color(0xFF38EF7D),
        ],
        accentColor: const Color(0xFF11998E),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _particleAnimController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundAnimController.dispose();
    _contentAnimController.dispose();
    _particleAnimController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final slides = _getSlides(context);
    if (_currentPage < slides.length - 1) {
      _contentAnimController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
      _contentAnimController.forward();
    } else {
      widget.onComplete();
    }
  }

  void _goToPage(int page) {
    _contentAnimController.reset();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
    _contentAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _getSlides(context);
    final screenSize = MediaQuery.of(context).size;

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
                      math.cos(_backgroundAnimController.value * math.pi * 2) * 0.5,
                    ),
                    radius: 1.8,
                    colors: [
                      slides[_currentPage].gradientColors[0].withValues(alpha: 0.15),
                      slides[_currentPage].gradientColors[1].withValues(alpha: 0.08),
                      AppColors.background,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              );
            },
          ),

          // Floating particles
          ...List.generate(12, (index) => _buildFloatingParticle(index, screenSize)),

          // Page content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: widget.onComplete,
                      child: Text(
                        context.l10n.skip,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                // Main carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                      _contentAnimController.reset();
                      _contentAnimController.forward();
                    },
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      return _buildSlide(slides[index], index);
                    },
                  ),
                ),

                // Page indicators
                _buildPageIndicators(slides.length),

                const SizedBox(height: 24),

                // CTA Button
                _buildCTAButton(slides.length),

                const SizedBox(height: 40),
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
    final size = 4 + random.nextDouble() * 8;
    final speed = 0.3 + random.nextDouble() * 0.7;
    final delay = random.nextDouble();

    return AnimatedBuilder(
      animation: _particleAnimController,
      builder: (context, child) {
        final t = ((_particleAnimController.value + delay) % 1.0) * speed;
        final x = startX + math.sin(t * math.pi * 2 + index) * 30;
        final y = startY - t * screenSize.height * 0.3;
        final opacity = (1 - t) * 0.3;
        final slides = _getSlides(context);

        return Positioned(
          left: x,
          top: y % screenSize.height,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slides[_currentPage].accentColor.withValues(alpha: opacity),
              boxShadow: [
                BoxShadow(
                  color: slides[_currentPage].accentColor.withValues(alpha: opacity * 0.5),
                  blurRadius: size * 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlide(_FeatureSlide slide, int index) {
    return AnimatedBuilder(
      animation: _contentAnimController,
      builder: (context, child) {
        final slideAnimation = CurvedAnimation(
          parent: _contentAnimController,
          curve: Curves.easeOutCubic,
        );

        final fadeValue = slideAnimation.value;
        final slideValue = Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).evaluate(slideAnimation);

        return Opacity(
          opacity: fadeValue,
          child: Transform.translate(
            offset: Offset(0, slideValue.dy * 50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon container
                  _buildAnimatedIcon(slide),

                  const SizedBox(height: 48),

                  // Subtitle badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: slide.gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: slide.gradientColors[0].withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      slide.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    slide.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    slide.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon(_FeatureSlide slide) {
    return AnimatedBuilder(
      animation: _backgroundAnimController,
      builder: (context, child) {
        final pulseValue = math.sin(_backgroundAnimController.value * math.pi * 4) * 0.05 + 1;
        final rotateValue = math.sin(_backgroundAnimController.value * math.pi * 2) * 0.05;

        return Transform.scale(
          scale: pulseValue,
          child: Transform.rotate(
            angle: rotateValue,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    slide.gradientColors[0].withValues(alpha: 0.2),
                    slide.gradientColors[1].withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: slide.gradientColors[0].withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: slide.gradientColors[0].withValues(alpha: 0.3),
                    blurRadius: 40,
                  ),
                  BoxShadow(
                    color: slide.gradientColors[1].withValues(alpha: 0.2),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: slide.gradientColors,
                  ).createShader(bounds),
                  child: Icon(
                    slide.icon,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        final slides = _getSlides(context);

        return GestureDetector(
          onTap: () => _goToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: isActive ? 32 : 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: isActive
                  ? LinearGradient(colors: slides[_currentPage].gradientColors)
                  : null,
              color: isActive ? null : Colors.white.withValues(alpha: 0.3),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: slides[_currentPage].gradientColors[0].withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCTAButton(int totalSlides) {
    final isLastSlide = _currentPage == totalSlides - 1;
    final slides = _getSlides(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTap: _nextPage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: slides[_currentPage].gradientColors,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: slides[_currentPage].gradientColors[0].withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLastSlide ? context.l10n.getStarted : context.l10n.next,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isLastSlide ? LucideIcons.arrowRight : LucideIcons.chevronRight,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> gradientColors;
  final Color accentColor;

  const _FeatureSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradientColors,
    required this.accentColor,
  });
}
