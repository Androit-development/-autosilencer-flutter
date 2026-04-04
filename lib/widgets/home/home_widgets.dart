import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/index.dart';
import '../../constants/app_constants.dart';

/// Dashed rotating ring painter
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
      final angle = (i * (2 * math.pi) / dashCount);
      final nextAngle = ((i + 1) * (2 * math.pi) / dashCount);

      final s1 = Offset(
        size.width / 2 + radius * 0.95 * math.cos(angle),
        size.height / 2 + radius * 0.95 * math.sin(angle),
      );
      final e1 = Offset(
        size.width / 2 + radius * 0.95 * math.cos(nextAngle) * 0.7,
        size.height / 2 + radius * 0.95 * math.sin(nextAngle) * 0.7,
      );

      canvas.drawLine(s1, e1, paint);
    }
  }

  @override
  bool shouldRepaint(DashedRingPainter old) => old.color != color;
}

/// Status ring with all animations
class StatusRing extends StatelessWidget {
  final bool isDriving;
  final bool isMonitoring;
  final Color stateColor;
  final Color stateGlow;
  final double rotValue;
  final double breatheScale;
  final double pingScale;
  final String statusText;
  final String subText;

  const StatusRing({
    super.key,
    required this.isDriving,
    required this.isMonitoring,
    required this.stateColor,
    required this.stateGlow,
    required this.rotValue,
    required this.breatheScale,
    required this.pingScale,
    required this.statusText,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: UISizes.statusRingSize,
        height: UISizes.statusRingSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ping pulse ring (only driving)
            if (isDriving)
              Transform.scale(
                scale: pingScale,
                child: Container(
                  width: UISizes.statusRingSize,
                  height: UISizes.statusRingSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stateColor.withOpacity(
                        0.3 * (1 - (pingScale - 1) / 0.6),
                      ),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

            // Outer dashed rotating ring
            Transform.rotate(
              angle: rotValue * 2 * math.pi,
              child: CustomPaint(
                size: const Size(
                  UISizes.statusRingOuterSize,
                  UISizes.statusRingOuterSize,
                ),
                painter: DashedRingPainter(
                  color: stateColor.withOpacity(isMonitoring ? 0.30 : 0.12),
                ),
              ),
            ),

            // Middle solid ring
            Container(
              width: UISizes.statusRingMiddleSize,
              height: UISizes.statusRingMiddleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: stateColor.withOpacity(0.45),
                  width: 1.5,
                ),
              ),
            ),

            // Inner glass circle with glow
            Transform.scale(
              scale: isMonitoring ? breatheScale : 1.0,
              child: Container(
                width: UISizes.statusRingInnerSize,
                height: UISizes.statusRingInnerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      stateColor.withOpacity(0.12),
                      AppColors.bgCardHigh.withOpacity(0.9),
                    ],
                  ),
                  border: Border.all(
                    color: stateColor.withOpacity(0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: stateGlow,
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDriving
                          ? Icons.local_shipping_outlined
                          : Icons.directions_car_rounded,
                      size: UISizes.iconLg,
                      color: stateColor,
                    ),
                    const SizedBox(height: UISizes.paddingXl),
                    AnimatedSwitcher(
                      duration: AnimationDurations.switchAnimation,
                      child: Text(
                        statusText,
                        key: ValueKey(isDriving),
                        textAlign: TextAlign.center,
                        style: AppText.label(color: stateColor, size: 10),
                      ),
                    ),
                    const SizedBox(height: UISizes.paddingSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stateColor,
                          ),
                        ),
                        const SizedBox(width: UISizes.paddingSm),
                        Text(
                          subText,
                          style: AppText.body(color: stateColor, size: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

/// Stat card widget
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final List<int> barHeights;
  final Color barColor;
  final String chipLabel;
  final Color chipColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.barHeights,
    required this.barColor,
    required this.chipLabel,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(UISizes.paddingLg),
        decoration: glassCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: UISizes.iconSm),
            const SizedBox(height: UISizes.paddingXl),
            Text(label, style: AppText.label(size: 10)),
            const SizedBox(height: UISizes.paddingSm),
            Text(value, style: AppText.number(color: AppColors.onSurface, size: 22)),
            const SizedBox(height: UISizes.paddingMd),
            Row(
              children: List.generate(
                barHeights.length,
                (i) => Expanded(
                  child: Container(
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: (barHeights[i] / 10) * 28,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: UISizes.paddingMd),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UISizes.paddingMd,
                vertical: UISizes.paddingSm,
              ),
              decoration: BoxDecoration(
                color: chipColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(UISizes.cornerRadiusSm),
                border: Border.all(color: chipColor.withOpacity(0.3)),
              ),
              child: Text(
                chipLabel,
                style: AppText.label(color: chipColor, size: 9),
              ),
            ),
          ],
        ),
      );
}

/// Alert banner
class AlertBanner extends StatelessWidget {
  final String title;
  final String message;

  const AlertBanner({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(UISizes.paddingLg),
        decoration: glassCard(leftBorderColor: AppColors.error),
        child: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error, size: UISizes.iconMd),
            const SizedBox(width: UISizes.paddingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.bodyBold(color: AppColors.error, size: 13)),
                  const SizedBox(height: 2),
                  Text(message, style: AppText.body(size: 12)),
                ],
              ),
            ),
          ],
        ),
      );
}
