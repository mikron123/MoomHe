import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../l10n/localized_options.dart';

/// Result returned when auth modal is closed after successful login/signup
class AuthResult {
  final String email;
  final String password;
  final bool isLogin;

  AuthResult({
    required this.email,
    required this.password,
    required this.isLogin,
  });
}

class AuthModal extends StatefulWidget {
  final bool initialIsLogin;
  final Function(String email)? onPasswordReset;

  const AuthModal({
    super.key,
    this.initialIsLogin = false,
    this.onPasswordReset,
  });

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  late bool _isLogin;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _handleSubmit() {
    _dismissKeyboard();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final l10n = context.l10n;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.fillAllFields);
      return;
    }

    if (!_isLogin && password != _confirmPasswordController.text) {
      setState(() => _error = l10n.passwordsDoNotMatch);
      return;
    }

    // Pop with result - let the parent handle the auth
    Navigator.of(context).pop(AuthResult(
      email: email,
      password: password,
      isLogin: _isLogin,
    ));
  }

  void _handleClose() {
    Navigator.of(context).pop(null);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              AppColors.primary900.withValues(alpha: 0.3),
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
                    onPressed: _handleClose,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceHighlight,
                    ),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Logo
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.primary300, Colors.white, AppColors.secondary300],
                        ).createShader(bounds),
                        child: Text(
                          context.l10n.appName,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary400, AppColors.secondary300],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Tab Switcher
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _dismissKeyboard();
                                  setState(() => _isLogin = false);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: !_isLogin ? AppColors.primary600 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    context.l10n.createNewAccount,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal,
                                      color: !_isLogin ? Colors.white : Colors.white60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _dismissKeyboard();
                                  setState(() => _isLogin = true);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: _isLogin ? AppColors.primary600 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    context.l10n.login,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
                                      color: _isLogin ? Colors.white : Colors.white60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isLogin
                            ? context.l10n.welcomeBack
                            : context.l10n.joinUs,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Form
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: context.l10n.email,
                          prefixIcon: const Icon(LucideIcons.mail, size: 22),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: context.l10n.password,
                          prefixIcon: const Icon(LucideIcons.lock, size: 22),
                        ),
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: context.l10n.confirmPassword,
                            prefixIcon: const Icon(LucideIcons.lock, size: 22),
                          ),
                        ),
                      ],

                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.alertCircle, size: 20, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(fontSize: 14, color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _isLogin ? context.l10n.loginButton : context.l10n.createAccountButton,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Forgot password
                      if (_isLogin && widget.onPasswordReset != null) ...[
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            _dismissKeyboard();
                            final email = _emailController.text.trim();
                            if (email.isEmpty) {
                              setState(() => _error = context.l10n.enterEmailFirst);
                              return;
                            }
                            widget.onPasswordReset!(email);
                          },
                          child: Text(
                            context.l10n.forgotPassword,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Terms with clickable links
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          children: [
                            TextSpan(text: '${context.l10n.termsAgreement} '),
                            TextSpan(
                              text: context.l10n.termsOfService,
                              style: TextStyle(
                                color: AppColors.primary400,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchUrl(context.l10n.termsOfServiceUrl),
                            ),
                            TextSpan(text: ' ${context.l10n.and} '),
                            TextSpan(
                              text: context.l10n.privacyPolicy,
                              style: TextStyle(
                                color: AppColors.primary400,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchUrl(context.l10n.privacyPolicyUrl),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
