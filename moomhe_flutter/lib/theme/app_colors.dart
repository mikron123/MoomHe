import 'package:flutter/material.dart';

class AppColors {
  // Primary colors (Blue-gray palette from web)
  static const Color primary50 = Color(0xFFF4F7FB);
  static const Color primary100 = Color(0xFFEEF2F6);
  static const Color primary200 = Color(0xFFDCE4ED);
  static const Color primary300 = Color(0xFFBDCDE0);
  static const Color primary400 = Color(0xFF96B0CF);
  static const Color primary500 = Color(0xFF7395BD);
  static const Color primary600 = Color(0xFF567AA3);
  static const Color primary700 = Color(0xFF456285);
  static const Color primary800 = Color(0xFF3B516C);
  static const Color primary900 = Color(0xFF334459);
  static const Color primary950 = Color(0xFF232D3B);

  // Secondary colors (Gold palette from web)
  static const Color secondary50 = Color(0xFFFBF9F5);
  static const Color secondary100 = Color(0xFFF6F3EB);
  static const Color secondary200 = Color(0xFFEAE2D0);
  static const Color secondary300 = Color(0xFFDACBA8);
  static const Color secondary400 = Color(0xFFC8AD7B);
  static const Color secondary500 = Color(0xFFB59259);
  static const Color secondary600 = Color(0xFF9A7646);
  static const Color secondary700 = Color(0xFF7B5B3A);
  static const Color secondary800 = Color(0xFF664B35);
  static const Color secondary900 = Color(0xFF543E2F);
  static const Color secondary950 = Color(0xFF2E2118);

  // Background & Surface colors
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceHighlight = Color(0xFF334155);

  // Text colors
  static const Color text = Color(0xFFF1F5F9);
  static const Color textMuted = Color(0xFF94A3B8);

  // Accent
  static const Color accent = Color(0xFFB59259);

  // Gradient colors for backgrounds
  static const List<Color> backgroundGradient = [
    Color(0xFF0F172A),
    Color(0xFF0F172A),
  ];

  // Glass panel colors
  static Color glassBackground = surface.withValues(alpha: 0.6);
  static Color glassBorder = Colors.white.withValues(alpha: 0.1);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Subscription/Premium colors
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFFFA500);
}
