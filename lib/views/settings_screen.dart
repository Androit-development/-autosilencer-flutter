import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../viewmodels/language_viewmodel.dart';
import '../viewmodels/driving_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _motionThreshold = 1.5;
  double _noiseThreshold  = 60.0;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>();
    final vm   = context.watch<DrivingViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(top: 100, right: -60,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 200)]))),

          SafeArea(
            child: Column(
              children: [
                // ── App bar ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: AppColors.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(lang.t('Settings', 'Réglages'),
                          style: AppText.headline(size: 20)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryContainer]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('PRO', style: AppText.label(color: Colors.white, size: 10)),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [

                      // ── Language ────────────────────────────────────────
                      _SectionLabel(lang.t('LANGUAGE', 'LANGUE')),
                      const SizedBox(height: 10),
                      Container(
                        decoration: glassCard(),
                        child: Column(children: [
                          _LangTile(flag: '🇬🇧', label: 'English',
                              selected: lang.isEnglish, onTap: lang.setEnglish),
                          Divider(color: Colors.white.withOpacity(0.05), height: 1),
                          _LangTile(flag: '🇫🇷', label: 'Français',
                              selected: !lang.isEnglish, onTap: lang.setFrench),
                        ]),
                      ),

                      const SizedBox(height: 24),

                      // ── Detection thresholds ─────────────────────────────
                      _SectionLabel(lang.t('DETECTION SENSITIVITY', 'SENSIBILITÉ DE DÉTECTION')),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: glassCard(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Motion threshold
                            Row(children: [
                              Icon(Icons.bolt_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                lang.t('Motion threshold', 'Seuil de mouvement'),
                                style: AppText.bodyBold(size: 14),
                              ),
                              const Spacer(),
                              Text(
                                '${_motionThreshold.toStringAsFixed(1)} m/s²',
                                style: AppText.number(color: AppColors.primary, size: 14),
                              ),
                            ]),
                            Slider(
                              value: _motionThreshold,
                              min: 0.5, max: 4.0,
                              divisions: 14,
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.outlineVariant,
                              onChanged: (v) => setState(() => _motionThreshold = v),
                            ),
                            Text(
                              lang.t('Higher = less sensitive to motion',
                                     'Plus haut = moins sensible au mouvement'),
                              style: AppText.body(size: 11),
                            ),

                            const SizedBox(height: 16),
                            Divider(color: Colors.white.withOpacity(0.06)),
                            const SizedBox(height: 12),

                            // Noise threshold
                            Row(children: [
                              Icon(Icons.graphic_eq_rounded, color: AppColors.tertiary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                lang.t('Noise threshold', 'Seuil de bruit'),
                                style: AppText.bodyBold(size: 14),
                              ),
                              const Spacer(),
                              Text(
                                '${_noiseThreshold.toStringAsFixed(0)} dB',
                                style: AppText.number(color: AppColors.tertiary, size: 14),
                              ),
                            ]),
                            Slider(
                              value: _noiseThreshold,
                              min: 40.0, max: 80.0,
                              divisions: 20,
                              activeColor: AppColors.tertiary,
                              inactiveColor: AppColors.outlineVariant,
                              onChanged: (v) => setState(() => _noiseThreshold = v),
                            ),
                            Text(
                              lang.t('Car engine is typically 65–75 dB',
                                     'Un moteur de voiture fait 65–75 dB'),
                              style: AppText.body(size: 11),
                            ),

                            const SizedBox(height: 16),
                            // Apply button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary.withOpacity(0.15),
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  vm.updateThresholds(
                                    motion: _motionThreshold,
                                    noise: _noiseThreshold,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(lang.t('Settings saved!', 'Paramètres sauvegardés!')),
                                      backgroundColor: AppColors.tertiary.withOpacity(0.8),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Text(lang.t('Apply', 'Appliquer')),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── About ─────────────────────────────────────────────
                      _SectionLabel(lang.t('ABOUT', 'À PROPOS')),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: glassCard(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // App name + version
                            Row(children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.primaryContainer],
                                  ),
                                ),
                                child: const Icon(Icons.shield_rounded,
                                    color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('AutoSilencer', style: AppText.bodyBold(size: 18)),
                                Text('v1.0.0 · Flutter/Dart',
                                    style: AppText.body(size: 12)),
                              ]),
                            ]),

                            const SizedBox(height: 16),
                            Divider(color: Colors.white.withOpacity(0.06)),
                            const SizedBox(height: 14),

                            _AboutRow(
                              icon: Icons.school_outlined,
                              label: lang.t('Course', 'Cours'),
                              value: 'SE 3242 — Android App Development',
                            ),
                            
                            const SizedBox(height: 10),
                            _AboutRow(
                              icon: Icons.location_on_outlined,
                              label: lang.t('Institution', 'Institution'),
                              value: 'ICT University, Yaoundé 🇨🇲',
                            ),
                            const SizedBox(height: 10),
                            _AboutRow(
                              icon: Icons.code_rounded,
                              label: lang.t('Developer', 'Développeur'),
                              value: 'Erwan (KFJerwan), Nicole (glorymaya)'
                            ),
                            const SizedBox(height: 10),
                            _AboutRow(
                              icon: Icons.business_outlined,
                              label: lang.t('Organisation', 'Organisation'),
                              value: 'Androit Development',
                            ),

                            const SizedBox(height: 16),
                            Divider(color: Colors.white.withOpacity(0.06)),
                            const SizedBox(height: 12),

                            // GitHub link row
                            Row(children: [
                              Icon(Icons.open_in_new_rounded,
                                  color: AppColors.primary, size: 16),
                              const SizedBox(width: 8),
                              Text('github.com/androit-development',
                                style: AppText.body(color: AppColors.primary, size: 13)),
                            ]),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppText.label(size: 11));
}

class _LangTile extends StatelessWidget {
  final String flag, label;
  final bool selected;
  final VoidCallback onTap;
  const _LangTile({required this.flag, required this.label,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(child: Text(label,
            style: AppText.bodyBold(
              color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
              size: 15,
            ),
          )),
          AnimatedOpacity(
            opacity: selected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _AboutRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppColors.onSurfaceVariant, size: 16),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.label(size: 10)),
        const SizedBox(height: 2),
        Text(value, style: AppText.body(color: AppColors.onSurface, size: 13)),
      ])),
    ]);
  }
}