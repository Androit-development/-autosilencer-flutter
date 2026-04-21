import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/index.dart';
import '../../constants/app_constants.dart';
import '../../viewmodels/driving_viewmodel.dart';
import '../../viewmodels/language_viewmodel.dart';
import '../../services/permissions_service.dart';
import '../../services/background_service.dart';
import '../../main.dart' show AppShellState;

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

// ─────────────────────────────────────────────────────────────────────────────
// GLOW BLOB — Ambient background effect
// ─────────────────────────────────────────────────────────────────────────────
class GlowBlob extends StatelessWidget {
  final Color color;
  final double radius;
  final double opacity;

  const GlowBlob({
    required this.color,
    required this.radius,
    required this.opacity,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: radius * 2,
    height: radius * 2,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: radius * 1.6,
          spreadRadius: radius * 0.25,
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME TOP BAR
// ─────────────────────────────────────────────────────────────────────────────
class HomeTopBar extends StatelessWidget {
  final LanguageViewModel lang;

  const HomeTopBar({required this.lang, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Icon(Icons.shield_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Text('AutoSilencer', style: AppText.headline(size: 18)),
          const Spacer(),
          GestureDetector(
            onTap: lang.toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.bgCardHigh.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                lang.langLabel,
                style: AppText.label(color: AppColors.primary, size: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SENSOR STAT CARD — Motion and noise readings
// ─────────────────────────────────────────────────────────────────────────────
class SensorStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final String chipLabel;
  final Color chipColor;

  const SensorStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.chipLabel,
    required this.chipColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Text(label, style: AppText.label(size: 10)),
          ]),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: value,
                style: AppText.number(color: AppColors.onSurface, size: 22),
              ),
              TextSpan(
                text: '  $unit',
                style: AppText.body(size: 11),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: chipColor),
            ),
            const SizedBox(width: 5),
            Text(
              chipLabel,
              style: AppText.label(
                color: AppColors.onSurfaceVariant,
                size: 9,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MONITORING ACTION BUTTON — Start/Stop button with permissions
// ─────────────────────────────────────────────────────────────────────────────
class MonitoringActionButton extends StatelessWidget {
  final DrivingViewModel vm;
  final LanguageViewModel lang;

  const MonitoringActionButton({
    required this.vm,
    required this.lang,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = vm.isMonitoring;
    final c1 = isOn ? AppColors.error : AppColors.primary;
    final c2 = isOn ? AppColors.errorContainer : AppColors.primaryContainer;

    return GestureDetector(
      onTap: () async {
        if (isOn) {
          await vm.stopMonitoring();
          await BackgroundServiceManager.stopService();
          if (context.mounted) {
            context.findAncestorStateOfType<AppShellState>()?.switchToHistory();
          }
        } else {
          final permissionsGranted =
              await PermissionsService.checkAllPermissions();

          if (!context.mounted) return;

          if (!(permissionsGranted['microphone'] ?? false) ||
              !(permissionsGranted['sensors'] ?? false)) {
            _showPermissionDialog(context, permissionsGranted);
            return;
          }

          await vm.startMonitoring();
          await BackgroundServiceManager.startService();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c1, c2],
          ),
          boxShadow: [
            BoxShadow(
              color: c1.withOpacity(0.40),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOn ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              isOn
                  ? lang.t('STOP MONITORING', 'ARRÊTER LA SURVEILLANCE')
                  : lang.t('START MONITORING', 'DÉMARRER LA SURVEILLANCE'),
              style: AppText.label(color: Colors.white, size: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog(
    BuildContext context,
    Map<String, bool> permissions,
  ) {
    final micGranted = permissions['microphone'] ?? false;
    final sensorGranted = permissions['sensors'] ?? false;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCardHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          lang.t('Permissions Required', 'Permissions requises'),
          style: AppText.headline(size: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.t(
                'AutoSilencer needs these permissions:',
                'AutoSilencer a besoin de ces permissions:',
              ),
              style: AppText.body(size: 14),
            ),
            const SizedBox(height: 16),
            PermissionCheckItem(
              icon: Icons.mic_rounded,
              label: lang.t('Microphone', 'Microphone'),
              description: lang.t(
                'Detect road noise',
                'Détecter les bruits de la route',
              ),
              granted: micGranted,
            ),
            const SizedBox(height: 12),
            PermissionCheckItem(
              icon: Icons.sensors_rounded,
              label: lang.t('Motion Sensors', 'Capteurs de mouvement'),
              description: lang.t(
                'Detect vehicle movement',
                'Détecter le mouvement du véhicule',
              ),
              granted: sensorGranted,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.t('Cancel', 'Annuler')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await PermissionsService.requestAllPermissions();
            },
            child: Text(lang.t('Request Permissions', 'Demander les permissions')),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERMISSION CHECK ITEM
// ─────────────────────────────────────────────────────────────────────────────
class PermissionCheckItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool granted;

  const PermissionCheckItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.granted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: granted
                ? AppColors.tertiary.withOpacity(0.2)
                : AppColors.error.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: granted ? AppColors.tertiary : AppColors.error,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.bodyBold(size: 13),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppText.body(
                  color: AppColors.onSurfaceVariant,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
        Icon(
          granted ? Icons.check_circle : Icons.cancel,
          color: granted ? AppColors.tertiary : AppColors.error,
          size: 20,
        ),
      ],
    );
  }
}
