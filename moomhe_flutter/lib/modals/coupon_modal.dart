import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../services/analytics_service.dart';
import '../l10n/localized_options.dart';

class CouponModal extends StatefulWidget {
  final Future<Map<String, dynamic>> Function(String) onRedeemCoupon;
  final Function(int) onCouponSuccess;

  const CouponModal({
    super.key,
    required this.onRedeemCoupon,
    required this.onCouponSuccess,
  });

  @override
  State<CouponModal> createState() => _CouponModalState();
}

class _CouponModalState extends State<CouponModal> {
  final _couponController = TextEditingController();
  final _analytics = AnalyticsService();
  String? _status; // 'loading' | 'success' | 'error'
  String _message = '';

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _handleRedeemCoupon() async {
    final code = _couponController.text.replaceAll(' ', '').toUpperCase().trim();
    final l10n = context.l10n;
    
    if (code.isEmpty) {
      setState(() {
        _status = 'error';
        _message = l10n.mustEnterCoupon;
      });
      return;
    }

    setState(() {
      _status = 'loading';
      _message = '';
    });

    try {
      final result = await widget.onRedeemCoupon(code);
      if (result['success'] == true) {
        setState(() {
          _status = 'success';
          _message = result['message'] ?? l10n.couponActivated;
        });
        
        // Wait a moment to show success, then close
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pop();
          widget.onCouponSuccess(result['creditsAdded'] ?? 0);
        }
      } else {
        // Track coupon failed
        _analytics.logCouponFailed(errorCode: result['errorCode']?.toString());
        setState(() {
          _status = 'error';
          _message = result['error'] ?? l10n.errorRedeemingCoupon;
        });
      }
    } catch (e) {
      // Track coupon failed
      _analytics.logCouponFailed(errorCode: 'exception');
      setState(() {
        _status = 'error';
        _message = l10n.errorRedeemingCoupon;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.2),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceHighlight,
                    ),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF10B981).withValues(alpha: 0.3),
                              Colors.teal.withValues(alpha: 0.3),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.gift,
                          size: 48,
                          color: Color(0xFF34D399),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        context.l10n.enterCouponCodeTitle,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.enterCouponCodeSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Coupon input
                      TextField(
                        controller: _couponController,
                        enabled: _status != 'loading',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: context.l10n.couponCode,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF10B981),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                        ),
                      ),

                      // Status message
                      if (_status != null && _message.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _status == 'error'
                                ? Colors.red.withValues(alpha: 0.2)
                                : const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _status == 'error'
                                  ? Colors.red.withValues(alpha: 0.3)
                                  : const Color(0xFF10B981).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _status == 'error'
                                    ? LucideIcons.alertCircle
                                    : LucideIcons.checkCircle,
                                size: 24,
                                color: _status == 'error'
                                    ? Colors.red[300]
                                    : const Color(0xFF6EE7B7),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _message,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _status == 'error'
                                        ? Colors.red[300]
                                        : const Color(0xFF6EE7B7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _status == 'loading' ? null : _handleRedeemCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _status == 'loading'
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  context.l10n.redeemCoupon,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
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
}
