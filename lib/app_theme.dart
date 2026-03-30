// ═══════════════════════════════════════════════════════════════════════════
// app_theme.dart — "The Sentinel Glow" Design System
// All colors, text styles, and decorations in one place.
// Every screen imports this file.
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color Tokens (from Stitch DESIGN.md) ────────────────────────────────────
class AppColors {
  AppColors._();

  // Backgrounds — surface hierarchy
  static const Color bgLowest       = Color(0xFF060E1E); // Level 0
  static const Color bgDim          = Color(0xFF0B1323); // Level 0 alt
  static const Color bgContainerLow = Color(0xFF131B2C); // Level 1
  static const Color bgContainer    = Color(0xFF171F30); // Level 1 alt
  static const Color bgCardHigh     = Color(0xFF222A3B); // Level 2 cards
  static const Color bgCardHighest  = Color(0xFF2D3546); // Level 2 top

  // Brand colors
  static const Color primary        = Color(0xFFB0C6FF); // Electric blue
  static const Color primaryContainer = Color(0xFF558DFF);
  static const Color tertiary       = Color(0xFF00E475); // Safe green
  static const Color tertiaryContainer = Color(0xFF00A754);
  static const Color error          = Color(0xFFFFB4AB); // Alert red/pink
  static const Color errorContainer = Color(0xFF93000A);

  // Text
  static const Color onSurface        = Color(0xFFDBE2F9);
  static const Color onSurfaceVariant = Color(0xFFC2C6D7);
  static const Color outline          = Color(0xFF8C90A0);
  static const Color outlineVariant   = Color(0xFF424655);

  // Glow helpers
  static Color primaryGlow(double opacity) =>
      const Color(0xFFB0C6FF).withOpacity(opacity);
  static Color tertiaryGlow(double opacity) =>
      const Color(0xFF00E475).withOpacity(opacity);
  static Color errorGlow(double opacity) =>
      const Color(0xFFFFB4AB).withOpacity(opacity);
}

// ── Typography (Space Grotesk + Manrope from Stitch) ────────────────────────
class AppText {
  AppText._();

  // Display — Space Grotesk 800 — big status text
  static TextStyle display({Color color = AppColors.onSurface, double size = 56}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -1.5,
        height: 1.0,
      );

  // Headline — Space Grotesk 700 — screen titles
  static TextStyle headline({Color color = AppColors.onSurface, double size = 32}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
        height: 1.15,
      );

  // Label — Space Grotesk 600 ALL CAPS — data tags
  static TextStyle label({Color color = AppColors.onSurfaceVariant, double size = 11}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 2.0,
      );

  // Body — Manrope 400 — descriptive text
  static TextStyle body({Color color = AppColors.onSurfaceVariant, double size = 14}) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  // Body bold — Manrope 600
  static TextStyle bodyBold({Color color = AppColors.onSurface, double size = 14}) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Number — Space Grotesk 700 tabular
  static TextStyle number({Color color = AppColors.primary, double size = 28}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

// ── Glass Card Decoration ────────────────────────────────────────────────────
BoxDecoration glassCard({
  Color borderColor = AppColors.outlineVariant,
  double borderOpacity = 0.15,
  double blurRadius = 20,
  Color? leftBorderColor,
}) {
  return BoxDecoration(
    color: AppColors.bgCardHigh.withOpacity(0.4),
    borderRadius: BorderRadius.circular(16),
    border: leftBorderColor != null
        ? Border(
            left:   BorderSide(color: leftBorderColor.withOpacity(0.6), width: 4),
            right:  BorderSide(color: borderColor.withOpacity(borderOpacity)),
            top:    BorderSide(color: borderColor.withOpacity(borderOpacity)),
            bottom: BorderSide(color: borderColor.withOpacity(borderOpacity)),
          )
        : Border.all(color: borderColor.withOpacity(borderOpacity)),
  );
}

// ── Particle glow decoration (ambient background blobs) ─────────────────────
class ParticleGlowPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final Offset center;
  final double radius;

  const ParticleGlowPainter({
    required this.color,
    required this.opacity,
    required this.center,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(opacity), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(ParticleGlowPainter old) =>
      old.color != color || old.opacity != opacity;
}