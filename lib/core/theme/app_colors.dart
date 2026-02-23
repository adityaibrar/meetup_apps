import 'package:flutter/material.dart';

/// Palet warna terpusat untuk seluruh aplikasi.
/// Menggunakan gaya Modern Clean Minimalist.
class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primary = Color(0xFF2AC6B6);
  static const Color primaryDark = Color(0xFF1FA89A);
  static const Color primaryLight = Color(0xFF5DDCCE);
  static const Color primarySurface = Color(0xFFE8FAF7);

  // ── Secondary / Accent ──
  static const Color accent = Color(0xFFFF9F1C);
  static const Color accentLight = Color(0xFFFFBF5E);
  static const Color accentSurface = Color(0xFFFFF3E0);

  // ── Neutrals ──
  static const Color backgroundPrimary = Color(0xFFF8F9FB);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F3F5);
  static const Color border = Color(0xFFE8EAED);
  static const Color borderLight = Color(0xFFF2F3F5);
  static const Color divider = Color(0xFFF0F1F3);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ── Semantic ──
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFEFF6FF);

  // ── Shadows ──
  static Color shadowLight = Colors.black.withValues(alpha: 0.04);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.08);
  static Color shadowDark = Colors.black.withValues(alpha: 0.12);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2AC6B6), Color(0xFF1FA89A)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9F1C), Color(0xFFFFBF5E)],
  );
}
