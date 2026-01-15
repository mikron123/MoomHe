import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../l10n/localized_options.dart';
import '../main.dart';

class MobileMenuModal extends StatefulWidget {
  final bool isLoggedIn;
  final String? userEmail;
  final int userCredits;
  final int userUsage;
  final int userSubscription;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  final VoidCallback onSubscriptionClick;
  final VoidCallback onCouponClick;
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onLanguageChanged;

  const MobileMenuModal({
    super.key,
    required this.isLoggedIn,
    this.userEmail,
    required this.userCredits,
    required this.userUsage,
    required this.userSubscription,
    required this.onLogin,
    required this.onLogout,
    required this.onSubscriptionClick,
    required this.onCouponClick,
    this.onDeleteAccount,
    this.onLanguageChanged,
  });

  @override
  State<MobileMenuModal> createState() => _MobileMenuModalState();
}

class _MobileMenuModalState extends State<MobileMenuModal> {
  String get _initial => (widget.userEmail ?? 'U')[0].toUpperCase();
  String _displayName(BuildContext context) => widget.userEmail?.split('@')[0] ?? context.l10n.guest;
  bool get _hasEmail => widget.userEmail != null && widget.userEmail!.isNotEmpty;

  String _getCurrentLanguageName(BuildContext context) {
    final currentLocale = MoomheApp.of(context)?.currentLocale ?? 
        Localizations.localeOf(context);
    
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.locale.languageCode == currentLocale.languageCode &&
          (supportedLocale.locale.countryCode == currentLocale.countryCode ||
           (supportedLocale.locale.countryCode == null && currentLocale.countryCode == null))) {
        return supportedLocale.nativeName;
      }
    }
    return 'English';
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _LanguageSelectorModal(
        onLanguageSelected: (locale) {
          MoomheApp.of(context)?.setLocale(locale);
          Navigator.pop(modalContext);
          Navigator.pop(context);
          widget.onLanguageChanged?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade900.withValues(alpha: 0.5),
                  Colors.indigo.shade900.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary500, AppColors.secondary500],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1A1A2E),
                    ),
                    child: Center(
                      child: _hasEmail
                          ? Text(
                              _initial,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              LucideIcons.user,
                              size: 32,
                              color: Colors.white70,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _hasEmail ? _displayName(context) : context.l10n.guest,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _hasEmail
                      ? widget.userEmail!
                      : context.l10n.loginToSaveDesigns,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Auth Button - LOGIN/LOGOUT at top
                _buildMenuButton(
                  icon: _hasEmail ? LucideIcons.logOut : LucideIcons.logIn,
                  iconColor: _hasEmail ? Colors.red : Colors.blue,
                  gradientColors: _hasEmail
                      ? [Colors.red.withValues(alpha: 0.1), Colors.red.withValues(alpha: 0.1)]
                      : [Colors.blue.withValues(alpha: 0.1), Colors.blue.withValues(alpha: 0.1)],
                  borderColor: _hasEmail
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  title: _hasEmail ? context.l10n.logout : context.l10n.login,
                  subtitle: _hasEmail ? context.l10n.exitAccount : context.l10n.loginWithEmail,
                  onTap: () {
                    Navigator.pop(context);
                    if (_hasEmail) {
                      widget.onLogout();
                    } else {
                      widget.onLogin();
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Subscription Button
                _buildMenuButton(
                  icon: LucideIcons.crown,
                  iconColor: Colors.amber,
                  gradientColors: [
                    Colors.amber.withValues(alpha: 0.1),
                    Colors.orange.withValues(alpha: 0.1),
                  ],
                  borderColor: Colors.amber.withValues(alpha: 0.2),
                  title: context.l10n.mySubscription,
                  subtitle: widget.userCredits > 0
                      ? context.l10n.creditsRemaining(widget.userCredits)
                      : context.l10n.upgradeToPremium,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSubscriptionClick();
                  },
                ),
                // Coupon Button - hidden on iOS
                if (!Platform.isIOS) ...[
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    icon: LucideIcons.gift,
                    iconColor: const Color(0xFF10B981),
                    gradientColors: [
                      const Color(0xFF10B981).withValues(alpha: 0.1),
                      Colors.teal.withValues(alpha: 0.1),
                    ],
                    borderColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                    title: context.l10n.iHaveCoupon,
                    subtitle: context.l10n.enterCouponCode,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onCouponClick();
                    },
                  ),
                ],
                
                // Language Selector Button
                const SizedBox(height: 16),
                _buildMenuButton(
                  icon: LucideIcons.globe,
                  iconColor: Colors.cyan,
                  gradientColors: [
                    Colors.cyan.withValues(alpha: 0.1),
                    Colors.blue.withValues(alpha: 0.1),
                  ],
                  borderColor: Colors.cyan.withValues(alpha: 0.2),
                  title: context.l10n.language,
                  subtitle: _getCurrentLanguageName(context),
                  onTap: () => _showLanguageSelector(context),
                ),
                
                // Delete Account Button - only show for logged in users with email
                if (_hasEmail && widget.onDeleteAccount != null) ...[
                  const SizedBox(height: 24),
                  _buildDeleteAccountButton(context),
                ],
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: () => _showDeleteConfirmation(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.trash2,
              size: 14,
              color: Colors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 6),
            Text(
              l10n.deleteAccount,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.4),
                decoration: TextDecoration.underline,
                decorationColor: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.deleteAccountWarning1Title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteAccountWarning1Message,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showFinalDeleteConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(LucideIcons.alertOctagon, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.deleteAccountWarning2Title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteAccountWarning2Message,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Close the menu modal
              widget.onDeleteAccount?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required Color borderColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: iconColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronLeft,
              size: 20,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }

}

/// Modal for selecting app language
class _LanguageSelectorModal extends StatelessWidget {
  final void Function(Locale locale) onLanguageSelected;

  const _LanguageSelectorModal({
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = MoomheApp.of(context)?.currentLocale ?? 
        Localizations.localeOf(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.globe, color: Colors.cyan, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.selectLanguage,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          // Language list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: supportedLocales.length,
              itemBuilder: (context, index) {
                final supportedLocale = supportedLocales[index];
                final isSelected = 
                    supportedLocale.locale.languageCode == currentLocale.languageCode &&
                    (supportedLocale.locale.countryCode == currentLocale.countryCode ||
                     (supportedLocale.locale.countryCode == null && currentLocale.countryCode == null));

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary500.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _getLanguageEmoji(supportedLocale.locale.languageCode),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  title: Text(
                    supportedLocale.nativeName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    supportedLocale.name,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(LucideIcons.check, color: AppColors.primary500, size: 20)
                      : null,
                  onTap: () => onLanguageSelected(supportedLocale.locale),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  String _getLanguageEmoji(String languageCode) {
    switch (languageCode) {
      case 'en': return '🇬🇧';
      case 'ar': return '🇸🇦';
      case 'cs': return '🇨🇿';
      case 'da': return '🇩🇰';
      case 'de': return '🇩🇪';
      case 'el': return '🇬🇷';
      case 'es': return '🇪🇸';
      case 'et': return '🇪🇪';
      case 'fi': return '🇫🇮';
      case 'fr': return '🇫🇷';
      case 'ga': return '🇮🇪';
      case 'he': return '🇮🇱';
      case 'hr': return '🇭🇷';
      case 'hu': return '🇭🇺';
      case 'is': return '🇮🇸';
      case 'it': return '🇮🇹';
      case 'ja': return '🇯🇵';
      case 'ka': return '🇬🇪';
      case 'ko': return '🇰🇷';
      case 'lt': return '🇱🇹';
      case 'nb': return '🇳🇴';
      case 'nl': return '🇳🇱';
      case 'pl': return '🇵🇱';
      case 'pt': return '🇵🇹';
      case 'ro': return '🇷🇴';
      case 'sl': return '🇸🇮';
      case 'sv': return '🇸🇪';
      case 'zh': return '🇨🇳';
      default: return '🌐';
    }
  }
}
