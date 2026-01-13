import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../l10n/localized_options.dart';

class OnboardingStep {
  final String title;
  final String description;
  final GlobalKey? targetKey;

  const OnboardingStep({
    required this.title,
    required this.description,
    this.targetKey,
  });
}

class OnboardingOverlay extends StatefulWidget {
  final List<OnboardingStep> steps;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final int initialStep;

  const OnboardingOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    required this.onSkip,
    this.initialStep = 0,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with SingleTickerProviderStateMixin {
  late int _currentStep;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _updateTargetRect();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateTargetRect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final step = widget.steps[_currentStep];
      if (step.targetKey?.currentContext != null) {
        final renderBox = step.targetKey!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          setState(() {
            _targetRect = Rect.fromLTWH(
              position.dx - 8,
              position.dy - 8,
              renderBox.size.width + 16,
              renderBox.size.height + 16,
            );
          });
        }
      } else {
        setState(() => _targetRect = null);
      }
    });
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      _animationController.reverse().then((_) {
        setState(() => _currentStep++);
        _updateTargetRect();
        _animationController.forward();
      });
    } else {
      widget.onComplete();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _animationController.reverse().then((_) {
        setState(() => _currentStep--);
        _updateTargetRect();
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark overlay with spotlight
          CustomPaint(
            size: screenSize,
            painter: _SpotlightPainter(
              targetRect: _targetRect,
              overlayColor: Colors.black.withValues(alpha: 0.8),
            ),
          ),

          // Tooltip content - Force LTR to display correctly in all languages
          Positioned(
            left: 20,
            right: 20,
            bottom: _targetRect != null && _targetRect!.top > screenSize.height / 2
                ? screenSize.height - _targetRect!.top + 20
                : null,
            top: _targetRect != null && _targetRect!.bottom < screenSize.height / 2
                ? _targetRect!.bottom + 20
                : _targetRect == null
                    ? screenSize.height * 0.3
                    : null,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: Container(
                  constraints: const BoxConstraints(maxWidth: 340),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surface,
                        AppColors.surface.withValues(alpha: 0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary500.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500.withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.steps.length,
                          (index) => Container(
                            width: index == _currentStep ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: index == _currentStep
                                  ? AppColors.primary500
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary500.withValues(alpha: 0.2),
                              AppColors.secondary500.withValues(alpha: 0.2),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primary500.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.sparkles,
                            size: 28,
                            color: AppColors.primary400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        step.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: widget.onSkip,
                            child: Text(
                              context.l10n.skip,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              if (_currentStep > 0)
                                IconButton(
                                  onPressed: _prevStep,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                                  ),
                                  icon: const Icon(
                                    LucideIcons.chevronLeft,
                                    color: Colors.white,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _nextStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary500,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentStep < widget.steps.length - 1
                                          ? context.l10n.next
                                          : context.l10n.finish,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _currentStep < widget.steps.length - 1
                                          ? LucideIcons.chevronRight
                                          : LucideIcons.check,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final Color overlayColor;

  _SpotlightPainter({
    this.targetRect,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    
    if (targetRect != null) {
      // Create path with hole for spotlight
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(
          targetRect!,
          const Radius.circular(12),
        ))
        ..fillType = PathFillType.evenOdd;
      
      canvas.drawPath(path, paint);

      // Draw highlight border around target
      final borderPaint = Paint()
        ..color = AppColors.primary500.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(targetRect!, const Radius.circular(12)),
        borderPaint,
      );
    } else {
      // Just draw overlay without spotlight
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect;
  }
}
