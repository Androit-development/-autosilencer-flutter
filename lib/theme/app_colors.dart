import 'package:flutter/material.dart';

/// All color tokens for the app (from Stitch DESIGN.md)
class AppColors {
  AppColors._();

  // ── Backgrounds — surface hierarchy ────────────────────────────────
  static const Color bgLowest       = Color(0xFF060E1E); // Level 0
  static const Color bgDim          = Color(0xFF0B1323); // Level 0 alt
  static const Color bgContainerLow = Color(0xFF131B2C); // Level 1
  static const Color bgContainer    = Color(0xFF171F30); // Level 1 alt
  static const Color bgCardHigh     = Color(0xFF222A3B); // Level 2 cards
  static const Color bgCardHighest  = Color(0xFF2D3546); // Level 2 top

  // ── Brand colors ──────────────────────────────────────────────────
  static const Color primary           = Color(0xFFB0C6FF); // Electric blue
  static const Color primaryContainer  = Color(0xFF558DFF);
  static const Color tertiary          = Color(0xFF00E475); // Safe green
  static const Color tertiaryContainer = Color(0xFF00A754);
  static const Color error             = Color(0xFFFFB4AB); // Alert red/pink
  static const Color errorContainer    = Color(0xFF93000A);

  // ── Text colors ───────────────────────────────────────────────────
  static const Color onSurface        = Color(0xFFDBE2F9);
  static const Color onSurfaceVariant = Color(0xFFC2C6D7);
  static const Color outline          = Color(0xFF8C90A0);
  static const Color outlineVariant   = Color(0xFF424655);

  // ── Glow helpers ──────────────────────────────────────────────────
  static Color primaryGlow(double opacity) =>
      const Color(0xFFB0C6FF).withOpacity(opacity);

  static Color tertiaryGlow(double opacity) =>
      const Color(0xFF00E475).withOpacity(opacity);

  static Color errorGlow(double opacity) =>
      const Color(0xFFFFB4AB).withOpacity(opacity);
}
