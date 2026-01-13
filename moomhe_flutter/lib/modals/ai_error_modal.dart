import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../l10n/localized_options.dart';

/// Modal to display AI processing errors in a user-friendly way
class AIErrorModal extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onClose;
  final VoidCallback? onRetry;

  const AIErrorModal({
    super.key,
    required this.errorMessage,
    this.onClose,
    this.onRetry,
  });

  /// Check if this is a content moderation error
  bool get isModerationError {
    final lowerError = errorMessage.toLowerCase();
    return lowerError.contains('moderation_blocked') ||
        lowerError.contains('safety system') ||
        lowerError.contains('content policy') ||
        lowerError.contains('rejected');
  }

  /// Check if this is a timeout error
  bool get isTimeoutError {
    final lowerError = errorMessage.toLowerCase();
    return lowerError.contains('timeout') || lowerError.contains('timed out');
  }

  String _getTitle(BuildContext context) {
    final l10n = context.l10n;
    if (isModerationError) {
      return l10n.contentNotAllowed;
    } else if (isTimeoutError) {
      return l10n.requestFailed;
    }
    return l10n.oopsSomethingWrong;
  }

  String _getMessage(BuildContext context) {
    final l10n = context.l10n;
    if (isModerationError) {
      return l10n.moderationError;
    } else if (isTimeoutError) {
      return l10n.timeoutError;
    }
    return l10n.genericError;
  }

  IconData get icon {
    if (isModerationError) {
      return LucideIcons.shieldAlert;
    } else if (isTimeoutError) {
      return LucideIcons.clock;
    }
    return LucideIcons.alertTriangle;
  }

  Color get iconColor {
    if (isModerationError) {
      return Colors.orange;
    } else if (isTimeoutError) {
      return Colors.amber;
    }
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _getTitle(context),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Message
            Text(
              _getMessage(context),
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Buttons
            Row(
              children: [
                // Close button
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onClose?.call();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: Text(
                      context.l10n.close,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: 12),
                  // Retry button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onRetry?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.refreshCw, size: 18, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            context.l10n.tryAgain,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show the error modal
  static void show(
    BuildContext context, {
    required String errorMessage,
    VoidCallback? onClose,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AIErrorModal(
        errorMessage: errorMessage,
        onClose: onClose,
        onRetry: onRetry,
      ),
    );
  }
}
