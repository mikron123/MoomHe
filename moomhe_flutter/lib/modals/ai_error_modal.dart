import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

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

  String get title {
    if (isModerationError) {
      return 'תוכן לא מורשה';
    } else if (isTimeoutError) {
      return 'הבקשה נכשלה';
    }
    return 'אופס! משהו השתבש';
  }

  String get message {
    if (isModerationError) {
      return 'לא ניתן לעבד את התמונה או הבקשה.\n\nייתכן שהתמונה או הבקשה מכילות תוכן שאינו מותר לעיבוד.\n\nנסה עם תמונה אחרת או שנה את הבקשה.';
    } else if (isTimeoutError) {
      return 'הבקשה לקחה יותר מדי זמן.\n\nנסה שוב מאוחר יותר.';
    }
    return 'לא הצלחנו לעבד את הבקשה.\n\nנסה שוב או פנה לתמיכה אם הבעיה נמשכת.';
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
              title,
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
              message,
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
                    child: const Text(
                      'סגור',
                      style: TextStyle(
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.refreshCw, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'נסה שוב',
                            style: TextStyle(
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
