import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../data/data_loader.dart';
import '../../models/secondary.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';

/// Liste des fiches pratiques.
class CheatSheetsScreen extends StatelessWidget {
  const CheatSheetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContentRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cheat sheets')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          if (repo.cheatSheets.isEmpty)
            const EmptyState(icon: Icons.note_alt, title: 'Fiches à venir'),
          for (final sheet in repo.cheatSheets)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CheatSheetDetailScreen(sheet: sheet),
                  ),
                ),
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    AccentIcon(
                      icon: sheet.icon,
                      accent: sheet.accent,
                      size: 19,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sheet.title,
                            style: const TextStyle(
                              fontSize: 13.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${sheet.sections.length} sections',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.inkSoft),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Détail d'une cheat sheet avec bouton copier par ligne.
class CheatSheetDetailScreen extends StatelessWidget {
  final CheatSheet sheet;
  const CheatSheetDetailScreen({super.key, required this.sheet});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final fav = state.isFavorite('cheat', sheet.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(sheet.title),
        actions: [
          IconButton(
            onPressed: () => state.toggleFavorite('cheat', sheet.id),
            icon: Icon(
              fav ? Icons.star : Icons.star_border,
              color: fav ? AppColors.yellow : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          if (sheet.intro.isNotEmpty)
            Text(
              sheet.intro,
              style: const TextStyle(fontSize: 13.3, height: 1.45),
            ),
          if (sheet.intro.isNotEmpty) const SizedBox(height: 12),
          for (final section in sheet.sections) ...[
            SectionHeader(title: section.title),
            AppCard(
              padding: const EdgeInsets.all(4),
              flat: true,
              child: Column(
                children: [
                  for (var i = 0; i < section.entries.length; i++)
                    _row(context, section.entries[i], i),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, List<String> entry, int i) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A3646).withValues(alpha: 0.5)
                : const Color(0xFFEDF1F6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: GestureDetector(
              onLongPress: () => copyEntry(context, entry[0]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10151C),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry[0],
                  style: const TextStyle(
                    color: AppColors.green,
                    fontFamily: 'MonoTech',
                    fontSize: 11.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.length > 1 ? entry[1] : '',
              style: const TextStyle(fontSize: 12.8, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void copyEntry(BuildContext context, String text) {
    // Copie via le presse-papier (importé ci-dessous).
    CheatSheetDetailScreen.copy(context, text);
  }

  static void copy(BuildContext context, String text) {
    importClipboard(context, text);
  }
}

void importClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Copié dans le presse-papier ✓'),
        duration: Duration(milliseconds: 1200),
      ),
    );
  }
}
