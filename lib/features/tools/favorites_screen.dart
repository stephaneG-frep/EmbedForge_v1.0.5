import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../data/data_loader.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';
import '../courses/command_detail_screen.dart';
import '../courses/course_detail_screen.dart';
import '../projects/project_detail_screen.dart';
import 'cheat_sheets_screen.dart';

/// Éléments mis en favoris par l'utilisateur.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final repo = context.watch<ContentRepository>();
    final favs = state.favorites.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Favoris')),
      body: favs.isEmpty
          ? const EmptyState(
              icon: Icons.star_outline,
              title: 'Aucun favori',
              subtitle:
                  'Touche l’étoile d’un cours, d’une commande, d’un projet '
                  'ou d’une fiche pour le retrouver ici.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                for (final fav in favs)
                  _FavTile(fav: fav, state: state, repo: repo),
              ],
            ),
    );
  }
}

class _FavTile extends StatelessWidget {
  final String fav;
  final AppState state;
  final ContentRepository repo;

  const _FavTile({required this.fav, required this.state, required this.repo});

  @override
  Widget build(BuildContext context) {
    final parts = fav.split(':');
    if (parts.length < 2) return const SizedBox.shrink();
    final type = parts[0];
    final id = parts.sublist(1).join(':');

    final (label, icon, color) = switch (type) {
      'course' => (
        repo.course(id)?.title ?? id,
        Icons.menu_book,
        AppColors.blue,
      ),
      'chapter' => (
        _chapterLabel(context, id),
        Icons.library_books,
        AppColors.blue,
      ),
      'command' => (
        repo.command(id)?.name ?? id,
        Icons.terminal,
        AppColors.green,
      ),
      'project' => (
        repo.projects.where((p) => p.id == id).firstOrNull?.title ?? id,
        Icons.rocket_launch,
        AppColors.green,
      ),
      'cheat' => (
        repo.cheatSheets.where((c) => c.id == id).firstOrNull?.title ?? id,
        Icons.note_alt,
        AppColors.pink,
      ),
      'quiz' => (
        repo.quizzes.where((q) => q.id == id).firstOrNull?.title ?? id,
        Icons.quiz,
        AppColors.purple,
      ),
      _ => (id, Icons.star_border, AppColors.yellow),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () => _open(context, type, id),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: () => state.toggleFavorite(type, id),
              icon: const Icon(
                Icons.delete_outline,
                size: 19,
                color: AppColors.red,
              ),
              tooltip: 'Retirer',
            ),
          ],
        ),
      ),
    );
  }

  String _chapterLabel(BuildContext context, String globalId) {
    final parts = globalId.split('/');
    if (parts.length != 2) return globalId;
    final course = repo.course(parts[0]);
    if (course == null) return globalId;
    for (final ch in course.chapters) {
      if (ch.id == parts[1]) return ch.title;
    }
    return globalId;
  }

  void _open(BuildContext context, String type, String id) {
    switch (type) {
      case 'course':
        final c = repo.course(id);
        if (c != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c)),
          );
        }
        break;
      case 'chapter':
        final parts = id.split('/');
        final c = repo.course(parts[0]);
        if (c != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c)),
          );
        }
        break;
      case 'command':
        final cmd = repo.command(id);
        if (cmd != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CommandDetailScreen(cmd: cmd)),
          );
        }
        break;
      case 'project':
        final p = repo.projects.where((x) => x.id == id).firstOrNull;
        if (p != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: p)),
          );
        }
        break;
      case 'cheat':
        final sheet = repo.cheatSheets.where((x) => x.id == id).firstOrNull;
        if (sheet != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CheatSheetDetailScreen(sheet: sheet),
            ),
          );
        }
        break;
    }
  }
}
