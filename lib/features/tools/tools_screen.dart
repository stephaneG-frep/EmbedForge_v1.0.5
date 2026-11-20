import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../quizzes/quizzes_screen.dart';
import '../roadmap/roadmap_screen.dart';
import '../terminal/terminal_screen.dart';
import 'challenges_screen.dart';
import 'cheat_sheets_screen.dart';
import 'favorites_screen.dart';
import 'glossary_screen.dart';
import 'progress_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class _ToolEntry {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget Function() builder;

  const _ToolEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });
}

/// Espace « Outils » : accès aux utilitaires et ressources.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static final _entries = <_ToolEntry>[
    _ToolEntry(
      title: 'Terminal Linux',
      subtitle: 'Environnement simulé',
      icon: Icons.terminal,
      color: AppColors.green,
      builder: () => const TerminalScreen(),
    ),
    _ToolEntry(
      title: 'Quiz',
      subtitle: '4 niveaux + corrections',
      icon: Icons.quiz_outlined,
      color: AppColors.purple,
      builder: () => const QuizzesScreen(),
    ),
    _ToolEntry(
      title: 'Défis',
      subtitle: 'Trouve la bonne commande',
      icon: Icons.flag_outlined,
      color: AppColors.orange,
      builder: () => const ChallengesScreen(),
    ),
    _ToolEntry(
      title: 'Roadmap métier',
      subtitle: 'Du débutant au pro',
      icon: Icons.route_outlined,
      color: AppColors.blue,
      builder: () => const RoadmapScreen(),
    ),
    _ToolEntry(
      title: 'Glossaire',
      subtitle: 'Les termes clés expliqués',
      icon: Icons.menu_book_outlined,
      color: AppColors.teal,
      builder: () => const GlossaryScreen(),
    ),
    _ToolEntry(
      title: 'Cheat sheets',
      subtitle: 'Fiches pratiques',
      icon: Icons.note_alt_outlined,
      color: AppColors.pink,
      builder: () => const CheatSheetsScreen(),
    ),
    _ToolEntry(
      title: 'Recherche',
      subtitle: 'Tout le contenu',
      icon: Icons.search,
      color: AppColors.blue,
      builder: () => const SearchScreen(),
    ),
    _ToolEntry(
      title: 'Favoris',
      subtitle: 'Tes éléments sauvegardés',
      icon: Icons.star_outline,
      color: AppColors.yellow,
      builder: () => const FavoritesScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Outils & ressources')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          _statRow(state),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              for (final e in _entries) _tile(context, e),
              _authTile(
                context,
                'Profil & progression',
                Icons.emoji_events,
                AppColors.green,
                () => const ProgressScreen(),
              ),
              _settingsTile(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statRow(AppState state) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _stat(state.completedCoursesCount, 'cours', Icons.menu_book),
          _divider(),
          _stat(state.completedProjectsCount, 'projets', Icons.rocket_launch),
          _divider(),
          _stat(state.labsUsedCount, 'labs', Icons.science_outlined),
          _divider(),
          _stat(state.earnedBadges.length, 'badges', Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _stat(int value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.blue),
              const SizedBox(width: 4),
              Text(
                '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 28, color: const Color(0xFF2A3646));

  Widget _tile(BuildContext context, _ToolEntry e) {
    return _ToolTile(
      title: e.title,
      subtitle: e.subtitle,
      icon: e.icon,
      color: e.color,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => e.builder())),
    );
  }

  Widget _authTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget Function() builder,
  ) {
    return _ToolTile(
      title: title,
      subtitle: '',
      icon: icon,
      color: color,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => builder())),
    );
  }

  Widget _settingsTile(BuildContext context) {
    return _ToolTile(
      title: 'Paramètres',
      subtitle: 'Thème, texte, reset',
      icon: Icons.settings_outlined,
      color: AppColors.inkSoft,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}
