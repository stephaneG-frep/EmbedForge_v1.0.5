import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/progress_chart.dart';
import '../courses/course_detail_screen.dart';
import '../courses/courses_screen.dart'
    show pushPage; // pushPage partagé entre écrans
import '../labs/labs_screen.dart';
import '../roadmap/roadmap_screen.dart';
import '../terminal/terminal_screen.dart';
import '../tools/search_screen.dart';

/// Tableau de bord : progression générale et accès express.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EmbedForge'),
        actions: [
          IconButton(
            tooltip: 'Recherche',
            onPressed: () => pushPage(context, const SearchScreen()),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
        children: [
          _hero(state),
          const SizedBox(height: 14),
          _quickActions(context),
          const SizedBox(height: 14),
          if (state.lastCourse != null) _continueCard(context, state),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Progression générale',
            icon: Icons.insights,
          ),
          _overallProgress(state),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Statistiques', icon: Icons.bar_chart),
          _statsRow(state),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.storage, size: 16, color: AppColors.inkSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Contenu hors-ligne chargé : '
                    '${state.repo.courses.length} cours · '
                    '${state.repo.commands.length} commandes · '
                    '${state.repo.quizzes.length} quiz · '
                    '${state.repo.projects.length} projets',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Récemment débloqué',
            icon: Icons.emoji_events,
          ),
          _badgeStrip(context, state),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _hero(AppState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10151C), Color(0xFF1E3A52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Apprends le Linux\nembarqué pas à pas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.5,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.rankLabel} · ${state.completedCoursesCount} module(s)',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ProgressRing(
            value: state.progress,
            size: 84,
            stroke: 8,
            color: AppColors.green,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(state.progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const Text(
                  'terminé',
                  style: TextStyle(color: Colors.white60, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 6) return 'Bonne nuit, apprenti embarqué';
    if (h < 12) return 'Bonjour, apprenti embarqué';
    if (h < 18) return 'Bon après-midi, apprenti embarqué';
    return 'Bonsoir, apprenti embarqué';
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      (
        Icons.science_outlined,
        'Lab',
        AppColors.blue,
        () => pushPage(context, const LabsScreen()),
      ),
      (
        Icons.terminal,
        'Terminal',
        AppColors.green,
        () => pushPage(context, const TerminalScreen()),
      ),
      (
        Icons.route_outlined,
        'Roadmap',
        AppColors.orange,
        () => pushPage(context, const RoadmapScreen()),
      ),
      (
        Icons.search,
        'Recherche',
        AppColors.purple,
        () => pushPage(context, const SearchScreen()),
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AppCard(
              onTap: actions[i].$4,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Icon(actions[i].$1, color: actions[i].$3, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    actions[i].$2,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _continueCard(BuildContext context, AppState state) {
    final course = state.lastCourse!;
    final color = Accents.colorOf(course.accent);
    final nextChapter = course.chapters
        .where((ch) => !state.isChapterCompleted('${course.id}/${ch.id}'))
        .firstOrNull;
    final title =
        nextChapter?.title ??
        (course.chapters.isEmpty ? null : course.chapters.first.title);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REPRENDRE L’APPRENTISSAGE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              AccentIcon(icon: course.icon, accent: course.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (title != null)
                      Text(
                        'Prochain : $title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.8,
                          color: AppColors.inkSoft,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    pushPage(context, CourseDetailScreen(course: course)),
                icon: Icon(Icons.play_circle_fill, color: color, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overallProgress(AppState state) {
    final total = state.totalCourses;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MiniBar(value: state.progress, color: AppColors.blue),
              ),
              const SizedBox(width: 12),
              Text(
                '${state.completedCoursesCount} / $total',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var l = 1; l <= 5; l++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: l == 1 ? 0 : 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MiniBar(
                          value: state.totalInLevel(l) == 0
                              ? 0
                              : state.completedInLevel(l) /
                                    state.totalInLevel(l),
                          color: levelColor(l),
                          height: 5,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Niv $l\n${state.completedInLevel(l)}/${state.totalInLevel(l)}',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: AppColors.inkSoft,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsRow(AppState state) {
    return Row(
      children: [
        _statCard(
          'Quiz',
          '${(state.bestQuizRatio * 100).round()} %',
          Icons.quiz,
          AppColors.purple,
        ),
        const SizedBox(width: 10),
        _statCard(
          'Projets',
          '${state.completedProjectsCount}/${state.repo.projects.length}',
          Icons.rocket_launch,
          AppColors.green,
        ),
        const SizedBox(width: 10),
        _statCard(
          'Badges',
          '${state.earnedBadges.length}',
          Icons.emoji_events,
          AppColors.yellow,
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeStrip(BuildContext context, AppState state) {
    final earned = state.earnedBadges;
    if (earned.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: AppColors.inkSoft),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Termine ton premier module pour décrocher ton premier badge.',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final badge in earned)
            Container(
              width: 94,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.14
                      : 0.08,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.blue.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: AppColors.blue,
                    size: 20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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
