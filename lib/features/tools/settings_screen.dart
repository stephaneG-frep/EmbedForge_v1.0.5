import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../services/crash_reporter.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import 'about_screen.dart';

/// Paramètres : thème, taille du texte, reset, à propos.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          const SectionHeader(title: 'Apparence', icon: Icons.palette_outlined),
          AppCard(
            padding: const EdgeInsets.all(8),
            flat: true,
            child: Column(
              children: [
                _option(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Thème clair',
                  selected: state.theme == ThemeMode.light,
                  onTap: () => state.setTheme(ThemeMode.light),
                ),
                _option(
                  icon: Icons.dark_mode_outlined,
                  title: 'Thème sombre',
                  selected: state.theme == ThemeMode.dark,
                  onTap: () => state.setTheme(ThemeMode.dark),
                ),
                _option(
                  icon: Icons.brightness_auto_outlined,
                  title: 'Thème système',
                  selected: state.theme == ThemeMode.system,
                  onTap: () => state.setTheme(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'Taille du texte',
            icon: Icons.format_size,
          ),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('A', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Slider(
                        value: state.fontScale,
                        min: 0.85,
                        max: 1.3,
                        divisions: 9,
                        label: '${(state.fontScale * 100).round()} %',
                        onChanged: (v) => state.setFontScale(v),
                      ),
                    ),
                    const Text('A', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const Text(
                  'S’applique à toute l’application, en plus du réglage '
                  'd’accessibilité d’Android.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(title: 'Données', icon: Icons.storage_outlined),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ta progression, tes favoris et tes réglages sont stockés '
                  'localement sur cet appareil. Aucune donnée ne quitte le téléphone.',
                  style: TextStyle(fontSize: 12.8, height: 1.4),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => _confirmReset(context),
                    style: TextButton.styleFrom(foregroundColor: AppColors.red),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Réinitialiser toute ma progression'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(title: 'À propos', icon: Icons.info_outline),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.developer_board,
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EmbedForge Academy',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      // Version lue dans le paquet Android (source : pubspec).
                      FutureBuilder<String>(
                        future: CrashReporter.version(),
                        builder: (context, snap) => Text(
                          'v${snap.data ?? '…'} · hors-ligne · Material 3',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                  child: const Text('Détails'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _option({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.blue : AppColors.inkSoft,
              size: 19,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.blue : AppColors.inkSoft,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réinitialiser ?'),
        content: const Text(
          'Tout sera effacé : cours terminés, quiz, projets, favoris, roadmap. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () {
              context.read<AppState>().resetProgress();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Progression réinitialisée. Bonne remise à zéro !',
                  ),
                ),
              );
            },
            child: const Text('Effacer tout'),
          ),
        ],
      ),
    );
  }
}
