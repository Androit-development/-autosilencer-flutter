import 'dart:math';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Glass Card Decoration
BoxDecoration glassCard({
  Color borderColor = AppColors.outlineVariant,
  double borderOpacity = 0.15,
  Color? leftBorderColor,
}) {
  return BoxDecoration(
    color: AppColors.bgCardHigh.withOpacity(0.4),
    borderRadius: BorderRadius.circular(16),
    border: leftBorderColor != null
        ? Border(
            left: BorderSide(color: leftBorderColor.withOpacity(0.6), width: 4),
            right: BorderSide(color: borderColor.withOpacity(borderOpacity)),
            top: BorderSide(color: borderColor.withOpacity(borderOpacity)),
            bottom: BorderSide(color: borderColor.withOpacity(borderOpacity)),
          )
        : Border.all(color: borderColor.withOpacity(borderOpacity)),
  );
}

/// Particle glow decoration (ambient background blobs)
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

/// Dashed ring painter (for status rings)
class DashedRingPainter extends CustomPainter {
  final Color color;

  const DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    const dashCount = 16;

    for (int i = 0; i < dashCount; i++) {
      final angle = (i * (2 * pi) / dashCount);
      final nextAngle = ((i + 1) * (2 * pi) / dashCount);

      final s1 = Offset(
        size.width / 2 + radius * 0.95 * cos(angle),
        size.height / 2 + radius * 0.95 * sin(angle),
      );
      final e1 = Offset(
        size.width / 2 + radius * 0.95 * (cos(nextAngle) * 0.7),
        size.height / 2 + radius * 0.95 * (sin(nextAngle) * 0.7),
      );

      canvas.drawLine(s1, e1, paint);
    }
  }

  @override
  bool shouldRepaint(DashedRingPainter old) => old.color != color;
}
