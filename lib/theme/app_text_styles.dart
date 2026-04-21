import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography (Space Grotesk + Manrope from Stitch)
class AppText {
  AppText._();

  // ── Display — Space Grotesk 800 — big status text ─────────────────
  static TextStyle display({
    Color color = AppColors.onSurface,
    double size = 56,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -1.5,
        height: 1.0,
      );

  // ── Headline — Space Grotesk 700 — screen titles ───────────────────
  static TextStyle headline({
    Color color = AppColors.onSurface,
    double size = 32,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
        height: 1.15,
      );

  // ── Label — Space Grotesk 600 ALL CAPS — data tags ────────────────
  static TextStyle label({
    Color color = AppColors.onSurfaceVariant,
    double size = 11,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 2.0,
      );

  // ── Body — Manrope 400 — descriptive text ─────────────────────────
  static TextStyle body({
    Color color = AppColors.onSurfaceVariant,
    double size = 14,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  // ── Body bold — Manrope 600 ──────────────────────────────────────
  static TextStyle bodyBold({
    Color color = AppColors.onSurface,
    double size = 14,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // ── Number — Space Grotesk 700 tabular ──────────────────────────
  static TextStyle number({
    Color color = AppColors.primary,
    double size = 28,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
