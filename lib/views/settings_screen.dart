// ═══════════════════════════════════════════════════════════════════════════
// Module 4: views/settings_screen.dart
// Language switcher + app info
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../viewmodels/language_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bgLowest,
      appBar: AppBar(
        backgroundColor: AppColors.bgLowest,
        foregroundColor: AppColors.onSurface,
        title: Text(lang.t('Settings', 'Réglages'),
            style: AppText.headline(size: 18)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('LANGUAGE', 'LANGUE'), style: AppText.label()),
            const SizedBox(height: 12),
            Container(
              decoration: glassCard(),
              child: Column(
                children: [
                  _LangTile(flag:'🇬🇧', label:'English',
                      selected: lang.isEnglish,
                      onTap: lang.setEnglish),
                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  _LangTile(flag:'🇫🇷', label:'Français',
                      selected: !lang.isEnglish,
                      onTap: lang.setFrench),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(lang.t('ABOUT', 'À PROPOS'), style: AppText.label()),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: glassCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AutoSilencer',
                      style: AppText.bodyBold(size: 16)),
                  const SizedBox(height: 6),
                  Text(
                    lang.t(
                      'SE 3242 — Android Application Development\nICT University, Yaoundé, Cameroon',
                      'SE 3242 — Développement Android\nICT University, Yaoundé, Cameroun',
                    ),
                    style: AppText.body(size: 13),
                  ),
                  const SizedBox(height: 6),
                  Text('v1.0.0 · Flutter/Dart',
                      style: AppText.body(size: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                style: AppText.bodyBold(
                  color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  size: 15,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 22, height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    size: 13, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}