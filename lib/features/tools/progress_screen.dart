import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/secondary.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/progress_chart.dart';
import 'settings_screen.dart';

/// Espace « Profil / Progression » : statistiques, badges, niveau.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final total = state.totalCourses;
    final done = state.completedCoursesCount;
    final ratio = total == 0 ? 0.0 : done / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & progression'),
        actions: [
          IconButton(
            tooltip: 'Paramètres',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          _identity(state, done, total, ratio),
          const SizedBox(height: 14),
          const SectionHeader(title: 'Statistiques', icon: Icons.insights),
          _statsGrid(state),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Progression par niveau',
            icon: Icons.bar_chart,
          ),
          for (var l = 1; l <= 5; l++) _levelBar(state, l),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Quiz', icon: Icons.quiz_outlined),
          _quizBlock(state),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Compétences acquises',
            icon: Icons.school_outlined,
          ),
          _skillsBlock(state),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Badges', icon: Icons.emoji_events),
          _badges(state),
        ],
      ),
    );
  }

  Widget _identity(AppState state, int done, int total, double ratio) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          ProgressRing(
            value: ratio,
            size: 88,
            stroke: 9,
            color: AppColors.green,
            child: Text(
              '${(ratio * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.rankLabel,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Niveau ${state.rankLevel} · $done / $total modules',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniStat(
                      '${state.earnedBadges.length}',
                      'badges',
                      Icons.emoji_events,
                    ),
                    _miniStat('${state.labsUsedCount}', 'labs', Icons.science),
                    _miniStat(
                      '${state.favorites.length}',
                      'favoris',
                      Icons.star,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: AppColors.blue),
              const SizedBox(width: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(AppState state) {
    final items = [
      (
        Icons.menu_book,
        'Cours terminés',
        '${state.completedCoursesCount} / ${state.totalCourses}',
        AppColors.blue,
      ),
      (
        Icons.quiz,
        'Meilleur quiz',
        '${(state.bestQuizRatio * 100).round()} %',
        AppColors.purple,
      ),
      (
        Icons.rocket_launch,
        'Projets',
        '${state.completedProjectsCount} / ${state.repo.projects.length}',
        AppColors.green,
      ),
      (
        Icons.schedule,
        'Temps appris',
        '${state.completedMinutes ~/ 60}h${(state.completedMinutes % 60).toString().padLeft(2, '0')}',
        AppColors.orange,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.1,
      children: [
        for (final item in items)
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.$1, size: 16, color: item.$4),
                const Spacer(),
                Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkSoft,
                  ),
                ),
                Text(
                  item.$3,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _levelBar(AppState state, int level) {
    final done = state.completedInLevel(level);
    final total = state.totalInLevel(level);
    final color = levelColor(level);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Text(
              AppLevels.label(level, false),
              style: const TextStyle(
                fontSize: 12.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: MiniBar(value: total == 0 ? 0 : done / total, color: color),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$done/$total',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizBlock(AppState state) {
    if (state.quizResults.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.quiz_outlined, color: AppColors.inkSoft),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aucun quiz passé. Va t’entraîner dans l’onglet Outils.',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
          ],
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (final entry in state.quizResults.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.repo.quizzes
                              .where((q) => q.id == entry.key)
                              .firstOrNull
                              ?.title ??
                          entry.key,
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 110,
                    child: MiniBar(
                      value: entry.value.ratio,
                      color: AppColors.purple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value.correct}/${entry.value.total}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _skillsBlock(AppState state) {
    final skills = state.repo.roadmap
        .where((s) => state.hasRoadmapSkill(s.id))
        .toList();
    if (skills.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.school_outlined, color: AppColors.inkSoft),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aucune compétence cochée. Ouvre la roadmap métier pour t’auto-évaluer.',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
          ],
        ),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in skills)
          Chip(
            label: Text(s.title),
            avatar: const Icon(Icons.check, size: 14, color: AppColors.green),
            visualDensity: VisualDensity.compact,
            labelStyle: const TextStyle(fontSize: 11),
          ),
      ],
    );
  }

  Widget _badges(AppState state) {
    final earned = state.earnedBadges;
    final all = state.repo.badges;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${earned.length} / ${all.length} débloqués',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
        if (all.isEmpty)
          const AppCard(
            padding: EdgeInsets.all(14),
            child: Text(
              'Les badges seront calculés automatiquement.',
              style: TextStyle(fontSize: 12.5),
            ),
          ),
        for (var i = 0; i < all.length; i += 2)
          Row(
            children: [
              Expanded(
                child: _BadgeCard(
                  def: all[i],
                  earned: earned.any((e) => e.id == all[i].id),
                ),
              ),
              if (i + 1 < all.length) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _BadgeCard(
                    def: all[i + 1],
                    earned: earned.any((e) => e.id == all[i + 1].id),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeDef def;
  final bool earned;
  const _BadgeCard({required this.def, required this.earned});

  @override
  Widget build(BuildContext context) {
    final color = earned ? AppColors.blue : AppColors.inkSoft;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        color: earned
            ? AppColors.blue.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.14
                    : 0.08,
              )
            : null,
        borderColor: earned ? AppColors.blue.withValues(alpha: 0.6) : null,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: (earned ? AppColors.blue : AppColors.inkSoft).withValues(
                  alpha: earned ? 0.2 : 0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                color: color.withValues(alpha: earned ? 1 : 0.7),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              def.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.8,
                fontWeight: FontWeight.w800,
                color: earned ? AppColors.blue : AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              earned ? def.how : 'Non débloqué',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
