import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../l10n/localized_options.dart';

class ContactModal extends StatefulWidget {
  const ContactModal({super.key});

  @override
  State<ContactModal> createState() => _ContactModalState();
}

class _ContactModalState extends State<ContactModal> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _messageFocusNode = FocusNode();
  
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _handleClose() {
    Navigator.of(context).pop(false);
  }

  Future<void> _handleSubmit() async {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();
    final l10n = context.l10n;

    // Validation
    if (phone.isEmpty && email.isEmpty) {
      setState(() => _errorText = l10n.pleaseEnterPhoneOrEmail);
      return;
    }
    if (message.isEmpty) {
      setState(() => _errorText = l10n.pleaseEnterMessage);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await _submitFeedback(phone, email, message);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorText = l10n.errorSendingMessage;
        });
      }
    }
  }

  Future<void> _submitFeedback(String phone, String email, String message) async {
    final user = FirebaseAuth.instance.currentUser;
    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

    final messageData = {
      'id': messageId,
      'uid': user?.uid ?? 'anonymous',
      'email': email.isNotEmpty ? email : null,
      'phone': phone.isNotEmpty ? phone : null,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'userEmail': user?.email,
      'isAnonymous': user?.isAnonymous ?? true,
      'platform': 'flutter_mobile',
    };

    await FirebaseFirestore.instance
        .collection('supportMsgs')
        .doc(messageId)
        .set(messageData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
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
              // Top bar with close button and title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _handleClose,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceHighlight,
                      ),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    Row(
                      children: [
                        Text(
                          context.l10n.contactUs,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          LucideIcons.mail,
                          color: AppColors.primary400,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        context.l10n.contactSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Phone field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.l10n.phone,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        textDirection: TextDirection.ltr,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _emailFocusNode.requestFocus(),
                        decoration: InputDecoration(
                          hintText: '050-1234567',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          prefixIcon: Icon(
                            LucideIcons.phone,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary400, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.l10n.email,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        textDirection: TextDirection.ltr,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _messageFocusNode.requestFocus(),
                        decoration: InputDecoration(
                          hintText: 'example@email.com',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          prefixIcon: Icon(
                            LucideIcons.mail,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary400, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Message field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.l10n.message,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _messageController,
                        focusNode: _messageFocusNode,
                        maxLines: 5,
                        minLines: 3,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: context.l10n.writeYourMessage,
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary400, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Note
                      Text(
                        context.l10n.enterPhoneOrEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),

                      // Error text
                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.alertCircle, size: 18, color: Colors.redAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorText!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.redAccent,
                                  ),
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
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDAA520).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(LucideIcons.send, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.l10n.sendMessage,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      
                      // Extra padding at the bottom for keyboard
                      const SizedBox(height: 40),
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
