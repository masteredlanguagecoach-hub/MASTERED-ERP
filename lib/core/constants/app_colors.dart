import 'package:flutter/material.dart';

/// Primary brand colors for MASTERED ERP extracted from logo.
class AppColors {
  // Logo extracted primary red and slate accent
  static const Color primary = Color(0xFFDC2626); // Primary Red from logo
  static const Color primaryDark = Color(0xFFB91C1C);
  static const Color primaryLight = Color(0xFFFCA5A5);
  
  static const Color secondary = Color(0xFF1E293B); // Slate corporate secondary
  static const Color secondaryLight = Color(0xFF334155);

  static const Color background = Color(0xFFF8FAFC); // Slate 50 clean background
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Status colors
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color danger = Color(0xFFDC2626); // Red 600
  static const Color info = Color(0xFF2563EB); // Blue 600

  // Neutral tones
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // Shimmer / Skeletons
  static const Color skeletonBase = Color(0xFFE2E8F0);
  static const Color skeletonHighlight = Color(0xFFF8FAFC);
}
