import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../viewmodels/driving_viewmodel.dart';
import '../viewmodels/language_viewmodel.dart';
import '../services/permissions_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _rotCtrl;
  late final AnimationController _breatheCtrl;
  late final Animation<double>   _breatheAnim;
  late final AnimationController _pingCtrl;
  late final Animation<double>   _pingAnim;
  late final AnimationController _entranceCtrl;
  late final Animation<double>   _entranceAnim;

  @override
  void initState() {
    super.initState();

    // Slow rotation of outer dashed ring
    _rotCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 14))..repeat();

    // Breathing pulse on inner circle when monitoring
    _breatheCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 1.0, end: 1.07)
        .animate(CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut));

    // Ping expansion ring when driving
    _pingCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _pingAnim = Tween<double>(begin: 0.85, end: 1.65)
        .animate(CurvedAnimation(parent: _pingCtrl, curve: Curves.easeOut));

    // Entrance fade-slide on first load
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _entranceAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _breatheCtrl.dispose();
    _pingCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm         = context.watch<DrivingViewModel>();
    final lang       = context.watch<LanguageViewModel>();
    final stateColor = vm.isDriving
        ? AppColors.error
        : vm.isMonitoring
            ? AppColors.tertiary
            : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      body: Stack(
        children: [
          // ── Ambient background glows ──────────────────────────────────
          Positioned(top: 60, left: -100,
            child: _GlowBlob(color: AppColors.primary, r: 250, o: 0.09)),
          Positioned(bottom: 150, right: -100,
            child: _GlowBlob(color: stateColor, r: 260, o: 0.11)),
          Positioned(top: 300, right: -60,
            child: _GlowBlob(color: AppColors.tertiary, r: 180, o: 0.05)),

          SafeArea(
            child: FadeTransition(
              opacity: _entranceAnim,
              // ── SCROLLABLE — fixes overflow and makes it movable ──────
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ── Top bar ─────────────────────────────────────────
                    _TopBar(lang: lang),
                    const SizedBox(height: 20),

                    // ── Status label ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.t('CURRENT STATUS', 'STATUT ACTUEL'),
                            style: AppText.label(size: 10),
                          ),
                          const SizedBox(height: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              vm.isDriving
                                  ? lang.t('Driving detected.\nStay focused.',
                                            'Conduite détectée.\nRestez concentré.')
                                  : vm.isMonitoring
                                      ? lang.t('All clear.\nDrive safely.',
                                                'Tout va bien.\nConduisez prudemment.')
                                      : lang.t('Ready to\nmonitor.',
                                                'Prêt à\nsurveiller.'),
                              key: ValueKey('${vm.isDriving}${vm.isMonitoring}'),
                              style: AppText.headline(size: 26),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Animated status ring ─────────────────────────────
                    AnimatedBuilder(
                      animation: Listenable.merge(
                          [_rotCtrl, _breatheCtrl, _pingCtrl]),
                      builder: (_, __) => _StatusRing(
                        vm:           vm,
                        lang:         lang,
                        stateColor:   stateColor,
                        rotValue:     _rotCtrl.value,
                        breatheScale: _breatheAnim.value,
                        pingScale:    _pingAnim.value,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Sensor stat cards ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(child: _StatCard(
                            icon:      Icons.bolt_rounded,
                            iconColor: AppColors.primary,
                            label:     lang.t('MOTION', 'MOUVEMENT'),
                            value:     vm.isMonitoring
                                ? '${vm.motionLevel.toStringAsFixed(2)}'
                                : '—',
                            unit:      'm/s²',
                            chipLabel: vm.isDriving
                                ? lang.t('HIGH', 'ÉLEVÉ')
                                : lang.t('Normal', 'Normal'),
                            chipColor: vm.isDriving
                                ? AppColors.error
                                : AppColors.tertiary,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(
                            icon:      Icons.graphic_eq_rounded,
                            iconColor: AppColors.tertiary,
                            label:     lang.t('NOISE', 'BRUIT'),
                            value:     vm.isMonitoring
                                ? '${vm.noiseLevel.toStringAsFixed(0)}'
                                : '—',
                            unit:      'dB',
                            chipLabel: vm.isDriving
                                ? lang.t('HIGH', 'ÉLEVÉ')
                                : lang.t('Calm', 'Calme'),
                            chipColor: vm.isDriving
                                ? AppColors.error
                                : AppColors.tertiary,
                          )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Alert banner (driving only) ──────────────────────
                    if (vm.isDriving) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _AlertBanner(lang: lang),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Start / Stop button ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _ActionButton(vm: vm, lang: lang),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      lang.t(
                        'Tap to activate automatic detection',
                        'Appuyez pour activer la détection automatique',
                      ),
                      style: AppText.body(size: 11),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS RING — the animated concentric rings
// ─────────────────────────────────────────────────────────────────────────────
class _StatusRing extends StatelessWidget {
  final DrivingViewModel vm;
  final LanguageViewModel lang;
  final Color stateColor;
  final double rotValue, breatheScale, pingScale;

  const _StatusRing({
    required this.vm, required this.lang, required this.stateColor,
    required this.rotValue, required this.breatheScale, required this.pingScale,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240, height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Outermost ping ring — only when driving
          if (vm.isDriving)
            Transform.scale(
              scale: pingScale,
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: stateColor.withOpacity(
                      (0.5 * (1 - (pingScale - 0.85) / 0.8)).clamp(0, 0.5)),
                    width: 1.5,
                  ),
                ),
              ),
            ),

          // Second ping ring offset
          if (vm.isDriving)
            Transform.scale(
              scale: (pingScale * 0.78).clamp(0.6, 1.3),
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: stateColor.withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
            ),

          // Rotating dashed outer ring
          Transform.rotate(
            angle: rotValue * 2 * math.pi,
            child: CustomPaint(
              size: const Size(220, 220),
              painter: _DashedRingPainter(
                color: stateColor.withOpacity(
                    vm.isMonitoring ? 0.40 : 0.18),
              ),
            ),
          ),

          // Middle solid ring
          Container(
            width: 186, height: 186,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: stateColor.withOpacity(0.35), width: 1.5),
            ),
          ),

          // Inner glowing filled circle — breathes when monitoring
          Transform.scale(
            scale: vm.isMonitoring ? breatheScale : 1.0,
            child: Container(
              width: 154, height: 154,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  stateColor.withOpacity(0.18),
                  AppColors.bgCardHigh.withOpacity(0.96),
                ]),
                border: Border.all(
                    color: stateColor.withOpacity(0.45), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: stateColor.withOpacity(0.22),
                    blurRadius: 40,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon switch
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      vm.isDriving
                          ? Icons.directions_car_filled_rounded
                          : vm.isMonitoring
                              ? Icons.shield_rounded
                              : Icons.shield_outlined,
                      key: ValueKey('${vm.isDriving}${vm.isMonitoring}'),
                      size: 48,
                      color: stateColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      vm.isDriving
                          ? lang.t('DRIVING', 'CONDUITE')
                          : vm.isMonitoring
                              ? lang.t('SAFE', 'SÛR')
                              : lang.t('IDLE', 'EN ATTENTE'),
                      key: ValueKey(
                          '${vm.isDriving}${vm.isMonitoring}_label'),
                      style: AppText.label(color: stateColor, size: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final LanguageViewModel lang;
  const _TopBar({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          // Shield icon + app name
          Icon(Icons.shield_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Text('AutoSilencer', style: AppText.headline(size: 18)),
          const Spacer(),

          // Language toggle pill
          GestureDetector(
            onTap: lang.toggle,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.bgCardHigh.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(lang.langLabel,
                  style:
                      AppText.label(color: AppColors.primary, size: 11)),
            ),
          ),

          const SizedBox(width: 10),

          // Settings icon → navigate to settings screen
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: Icon(Icons.settings_outlined,
                color: AppColors.onSurfaceVariant, size: 22),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value, unit, chipLabel;
  final Color chipColor;

  const _StatCard({
    required this.icon, required this.iconColor,
    required this.label, required this.value,
    required this.unit,  required this.chipLabel,
    required this.chipColor,
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
                style: AppText.number(
                    color: AppColors.onSurface, size: 22),
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
              width: 6, height: 6,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: chipColor),
            ),
            const SizedBox(width: 5),
            Text(chipLabel,
                style: AppText.label(
                    color: AppColors.onSurfaceVariant, size: 9)),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ALERT BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  final LanguageViewModel lang;
  const _AlertBanner({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left:   BorderSide(
              color: AppColors.error.withOpacity(0.6), width: 4),
          right:  BorderSide(
              color: AppColors.error.withOpacity(0.15)),
          top:    BorderSide(
              color: AppColors.error.withOpacity(0.15)),
          bottom: BorderSide(
              color: AppColors.error.withOpacity(0.15)),
        ),
      ),
      child: Row(children: [
        const Icon(Icons.volume_off_rounded,
            color: AppColors.error, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            lang.t(
              'Phone silenced — Drive safely!',
              'Téléphone silencieux — Conduisez prudemment!',
            ),
            style:
                AppText.bodyBold(color: AppColors.onSurface, size: 13),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTON
// ── FIX: removed Border(top:...) that caused the yellow line
// ── FIX: uses AppShellState (public) not _AppShellState (private)
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final DrivingViewModel vm;
  final LanguageViewModel lang;
  const _ActionButton({required this.vm, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isOn = vm.isMonitoring;
    final c1   = isOn ? AppColors.error          : AppColors.primary;
    final c2   = isOn ? AppColors.errorContainer : AppColors.primaryContainer;

    return GestureDetector(
      onTap: () async {
        if (isOn) {
          await vm.stopMonitoring();
          if (context.mounted) {
            // ✅ FIX: AppShellState is public in main.dart
            context
                .findAncestorStateOfType<AppShellState>()
                ?.switchToHistory();
          }
        } else {
          // 🎤 Check permissions before starting monitoring
          final permissionsGranted = 
              await PermissionsService.checkAllPermissions();
          
          if (!context.mounted) return;

          if (!(permissionsGranted['microphone'] ?? false) ||
              !(permissionsGranted['sensors'] ?? false)) {
            // Show permission request dialog
            _showPermissionDialog(context, permissionsGranted);
            return;
          }

          // All permissions granted, start monitoring
          await vm.startMonitoring();
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
          // ✅ FIX: removed Border(top:...) — that was the yellow line
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOn
                  ? Icons.stop_circle_outlined
                  : Icons.play_circle_outline_rounded,
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

  // 🎤 Show permission request dialog
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
            _PermissionCheckItem(
              icon: Icons.mic_rounded,
              label: lang.t('Microphone', 'Microphone'),
              description: lang.t(
                'Detect road noise',
                'Détecter les bruits de la route',
              ),
              granted: micGranted,
            ),
            const SizedBox(height: 12),
            _PermissionCheckItem(
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
              // Request permissions again
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
// Permission check item widget
// ─────────────────────────────────────────────────────────────────────────────
class _PermissionCheckItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool granted;

  const _PermissionCheckItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.granted,
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

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double r, o;
  const _GlowBlob({required this.color, required this.r, required this.o});

  @override
  Widget build(BuildContext context) => Container(
    width: r * 2, height: r * 2,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(o),
          blurRadius: r * 1.6,
          spreadRadius: r * 0.25,
        ),
      ],
    ),
  );
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  const _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color      = color
      ..strokeWidth = 2
      ..style      = PaintingStyle.stroke
      ..strokeCap  = StrokeCap.round;

    const segments  = 28;
    const dashAngle = math.pi * 2 / segments * 0.58;
    const gapAngle  = math.pi * 2 / segments * 0.42;
    final radius    = size.width / 2;
    final center    = Offset(radius, radius);
    double angle    = 0;

    for (int i = 0; i < segments; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle, dashAngle, false, paint,
      );
      angle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.color != color;
}