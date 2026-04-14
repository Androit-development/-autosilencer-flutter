import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../viewmodels/driving_viewmodel.dart';
import '../viewmodels/language_viewmodel.dart';
import '../models/driving_log.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {

  int _filterIndex = 0;
  String? _selectedApp; // Filter by specific driving app
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();

    // Load real data from Supabase when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DrivingViewModel>().loadLogs();
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  List<DrivingLog> _filtered(List<DrivingLog> logs) {
    final now = DateTime.now();
    var result = logs;
    
    // Filter by time period
    switch (_filterIndex) {
      case 1:
        result = result.where((l) =>
          l.timestamp.year  == now.year &&
          l.timestamp.month == now.month &&
          l.timestamp.day   == now.day).toList();
        break;
      case 2:
        final weekAgo = now.subtract(const Duration(days: 7));
        result = result.where((l) => l.timestamp.isAfter(weekAgo)).toList();
        break;
    }
    
    // Filter by app
    if (_selectedApp != null) {
      result = result.where((l) => l.drivingApp?.toLowerCase() == _selectedApp?.toLowerCase()).toList();
    }
    
    return result;
  }

  // Get all unique apps from logs
  List<String> _getUniqueDrivingApps(List<DrivingLog> logs) {
    final apps = <String>{};
    for (var log in logs) {
      if (log.drivingApp != null && log.drivingApp!.isNotEmpty) {
        apps.add(log.drivingApp!);
      }
    }
    return apps.toList()..sort();
  }

  void _showAnalytics(BuildContext ctx, DrivingViewModel vm, LanguageViewModel lang) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: AppColors.bgCardHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.analytics_outlined,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(lang.t('Analytics', 'Analytiques'),
                    style: AppText.headline(size: 20)),
              ]),
              const SizedBox(height: 4),
              Text(lang.t('Your driving overview', 'Aperçu de votre conduite'),
                  style: AppText.body(size: 12)),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withOpacity(0.06)),
              const SizedBox(height: 16),
              _AnalyticRow(
                icon: Icons.directions_car_filled_rounded,
                color: AppColors.primary,
                label: lang.t('Total trips', 'Total trajets'),
                value: '${vm.totalTrips}',
              ),
              const SizedBox(height: 14),
              _AnalyticRow(
                icon: Icons.timer_rounded,
                color: AppColors.primary,
                label: lang.t('Total drive time', 'Temps total de conduite'),
                value: vm.totalTimeLabel,
              ),
              const SizedBox(height: 14),
              _AnalyticRow(
                icon: Icons.volume_off_rounded,
                color: AppColors.tertiary,
                label: lang.t('Times silenced', 'Fois silencieux'),
                value: '${vm.totalSilences}',
              ),
              const SizedBox(height: 14),
              _AnalyticRow(
                icon: Icons.shield_rounded,
                color: AppColors.tertiary,
                label: lang.t('Safe sessions', 'Sessions sûres'),
                value: '${(vm.totalTrips - vm.totalSilences).clamp(0, 9999)}',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(lang.t('Close', 'Fermer'),
                      style: AppText.bodyBold(color: AppColors.primary, size: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm       = context.watch<DrivingViewModel>();
    final lang     = context.watch<LanguageViewModel>();
    final filtered = _filtered(vm.logs);

    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      body: Stack(
        children: [
          // Ambient glows
          Positioned(top: 60, right: -40,
            child: _GlowBlob(color: AppColors.primary, r: 180, o: 0.08)),
          Positioned(bottom: 160, left: -40,
            child: _GlowBlob(color: AppColors.tertiary, r: 160, o: 0.06)),

          SafeArea(
            child: Column(
              children: [

                // ── Top bar ───────────────────────────────────────────────
                _HistoryTopBar(lang: lang),

                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [

                      // ── Header ─────────────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.t('Driving Sessions',
                                             'Sessions de conduite'),
                                      style: AppText.headline(size: 30),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lang.t('Your recent activity',
                                             'Votre activité récente'),
                                      style: AppText.body(),
                                    ),
                                  ],
                                ),
                              ),
                              // Analytics button → opens dialog
                              GestureDetector(
                                onTap: () => _showAnalytics(context, vm, lang),
                                child: Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withOpacity(0.12),
                                    border: Border.all(
                                        color: AppColors.primary.withOpacity(0.3)),
                                  ),
                                  child: Icon(Icons.analytics_outlined,
                                      color: AppColors.primary, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Summary pills ──────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Row(children: [
                            Expanded(child: _SummaryPill(
                              icon: Icons.directions_car_filled_rounded,
                              iconColor: AppColors.primary,
                              value: '${vm.totalTrips}',
                              label: lang.t('TRIPS', 'TRAJETS'),
                            )),
                            const SizedBox(width: 10),
                            Expanded(child: _SummaryPill(
                              icon: Icons.timer_rounded,
                              iconColor: AppColors.primary,
                              value: vm.totalTimeLabel,
                              label: lang.t('TIME', 'TEMPS'),
                            )),
                            const SizedBox(width: 10),
                            Expanded(child: _SummaryPill(
                              icon: Icons.volume_off_rounded,
                              iconColor: AppColors.tertiary,
                              value: '${vm.totalSilences}',
                              label: lang.t('SILENCES', 'SILENCES'),
                              valueColor: AppColors.tertiary,
                            )),
                          ]),
                        ),
                      ),

                      // ── Filter chips ───────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time filter
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(children: [
                                  _FilterChip(
                                    label: lang.t('All', 'Toutes'),
                                    active: _filterIndex == 0,
                                    onTap: () => setState(() => _filterIndex = 0),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: lang.t('Today', "Aujourd'hui"),
                                    active: _filterIndex == 1,
                                    onTap: () => setState(() => _filterIndex = 1),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: lang.t('This week', 'Cette semaine'),
                                    active: _filterIndex == 2,
                                    onTap: () => setState(() => _filterIndex = 2),
                                  ),
                                ]),
                              ),
                              
                              // App filter (if apps are being tracked)
                              const SizedBox(height: 12),
                              if (_getUniqueDrivingApps(vm.logs).isNotEmpty)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _FilterChip(
                                        label: lang.t('All Apps', 'Toutes Apps'),
                                        active: _selectedApp == null,
                                        onTap: () => setState(() => _selectedApp = null),
                                      ),
                                      const SizedBox(width: 8),
                                      ..._getUniqueDrivingApps(vm.logs).map((app) {
                                        final dlog = vm.logs.firstWhere((l) => l.drivingApp == app);
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: _FilterChip(
                                            label: '${dlog.appEmoji} ${dlog.appName}',
                                            active: _selectedApp == app,
                                            onTap: () => setState(() => _selectedApp = app),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // ── Loading ────────────────────────────────────────
                      if (vm.isLoading)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          ),
                        )

                      // ── Empty ──────────────────────────────────────────
                      else if (filtered.isEmpty)
                        SliverFillRemaining(
                          child: _EmptyState(
                              lang: lang, isFiltered: _filterIndex != 0),
                        )

                      // ── Cards ──────────────────────────────────────────
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) {
                                final delay = i * 0.10;
                                final anim  = CurvedAnimation(
                                  parent: _staggerCtrl,
                                  curve: Interval(
                                    delay.clamp(0.0, 1.0),
                                    (delay + 0.4).clamp(0.0, 1.0),
                                    curve: Curves.easeOut,
                                  ),
                                );
                                return AnimatedBuilder(
                                  animation: anim,
                                  builder: (_, __) => FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.2),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _SessionCard(
                                          log: filtered[i],
                                          lang: lang,
                                          vm: vm,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────
class _HistoryTopBar extends StatelessWidget {
  final LanguageViewModel lang;
  const _HistoryTopBar({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(children: [
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
            child: Text(lang.langLabel,
                style: AppText.label(color: AppColors.primary, size: 11)),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/settings'),
          child: Icon(Icons.settings_outlined,
              color: AppColors.onSurfaceVariant, size: 22),
        ),
      ]),
    );
  }
}

// ── Session card ──────────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final DrivingLog log;
  final LanguageViewModel lang;
  final DrivingViewModel vm;
  const _SessionCard(
      {required this.log, required this.lang, required this.vm});

  @override
  Widget build(BuildContext context) {
    final color     = Color(log.colorValue);
    final isDriving = log.status == DrivingStatus.driving;
    final isMuted   = log.status == DrivingStatus.sessionEnded ||
                      log.status == DrivingStatus.shortTrip;

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 24),
      ),
      onDismissed: (_) => vm.deleteLog(log.id),
      child: Opacity(
        opacity: isMuted ? 0.75 : 1.0,
        child: Container(
          decoration: glassCard(leftBorderColor: color),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Icon box
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconFor(log.status), color: color, size: 20),
                ),
                const SizedBox(width: 12),

                // Title + date
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log.label(lang.isEnglish),
                        style: AppText.bodyBold(
                            color: AppColors.onSurface, size: 15)),
                    const SizedBox(height: 3),
                    Text(log.formattedDate(lang.isEnglish),
                        style: AppText.body(size: 12)),
                    
                    // 🚕 Show which app if available
                    if (log.drivingApp != null && log.drivingApp!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(log.appEmoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            log.appName,
                            style: AppText.body(size: 12, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ],
                )),

                // Badge
                if (isDriving)
                  _PingDotSmall(color: color)
                else if (log.status == DrivingStatus.notDriving)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(lang.t('SAFE', 'SÛR'),
                        style: AppText.label(color: color, size: 9)),
                  ),
              ]),

              const SizedBox(height: 12),

              // ✅ FIX: Progress bar with NO yellow line
              Row(children: [
                Expanded(
                  child: Stack(children: [
                    // Background track
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.bgCardHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Fill
                    FractionallySizedBox(
                      widthFactor: log.progressFill.clamp(0.0, 1.0),
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 12),
                Text('${log.durationMinutes} min',
                    style: AppText.number(color: color, size: 14)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(DrivingStatus s) {
    switch (s) {
      case DrivingStatus.driving:      return Icons.directions_car_filled_rounded;
      case DrivingStatus.notDriving:   return Icons.check_circle_outline_rounded;
      case DrivingStatus.sessionEnded: return Icons.history_rounded;
      case DrivingStatus.shortTrip:    return Icons.electric_car_outlined;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value, label;
  final Color? valueColor;

  const _SummaryPill({
    required this.icon, required this.iconColor,
    required this.value, required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCardHigh.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: AppText.number(
                color: valueColor ?? AppColors.primary, size: 18)),
        const SizedBox(height: 3),
        Text(label, style: AppText.label(size: 9)),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryContainer.withOpacity(0.85)
              : AppColors.bgCardHigh.withOpacity(0.4),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: active
                ? Colors.transparent
                : AppColors.outlineVariant.withOpacity(0.2),
          ),
        ),
        child: Text(label,
            style: AppText.label(
                color: active
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
                size: 11)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final LanguageViewModel lang;
  final bool isFiltered;
  const _EmptyState({required this.lang, this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          isFiltered ? Icons.filter_list_off_rounded : Icons.history_rounded,
          size: 64,
          color: AppColors.onSurfaceVariant.withOpacity(0.15),
        ),
        const SizedBox(height: 20),
        Text(
          isFiltered
              ? lang.t('No sessions in this period',
                        'Aucune session dans cette période')
              : lang.t('No sessions yet', 'Aucune session'),
          style: AppText.bodyBold(color: AppColors.onSurfaceVariant, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          isFiltered
              ? lang.t('Try "All"', 'Essayez "Toutes"')
              : lang.t(
                  'Start monitoring to record\nyour first session',
                  'Démarrez la surveillance pour\nenregistrer votre première session',
                ),
          textAlign: TextAlign.center,
          style: AppText.body(
              color: AppColors.onSurfaceVariant.withOpacity(0.45), size: 13),
        ),
      ]),
    );
  }
}

class _PingDotSmall extends StatefulWidget {
  final Color color;
  const _PingDotSmall({required this.color});
  @override
  State<_PingDotSmall> createState() => _PingDotSmallState();
}

class _PingDotSmallState extends State<_PingDotSmall>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double>   _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
    _a = Tween<double>(begin: 0, end: 1).animate(_c);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 16, height: 16,
      child: Stack(alignment: Alignment.center, children: [
        AnimatedBuilder(animation: _a, builder: (_, __) =>
          Transform.scale(scale: 1 + _a.value,
            child: Container(width: 12, height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.35 * (1 - _a.value)),
              ),
            ),
          ),
        ),
        Container(width: 8, height: 8,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: widget.color)),
      ]),
    );
  }
}

class _AnalyticRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  const _AnalyticRow(
      {required this.icon, required this.color,
       required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: AppText.body(size: 14))),
      Text(value, style: AppText.number(color: color, size: 20)),
    ]);
  }
}

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
