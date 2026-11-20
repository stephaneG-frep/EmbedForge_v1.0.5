import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../data/data_loader.dart';
import '../../models/course.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';
import '../../widgets/progress_chart.dart';
import 'course_detail_screen.dart';
import 'commands_tab.dart';

/// Espace « Cours » : liste des modules + bibliothèque de commandes.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cours'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Modules'),
              Tab(text: 'Commandes'),
            ],
          ),
          actions: [
            Consumer<AppState>(
              builder: (context, state, _) => IconButton(
                tooltip: 'Recherche',
                onPressed: () => pushCommandsSearch(context),
                icon: const Icon(Icons.search),
              ),
            ),
          ],
        ),
        body: const TabBarView(children: [CourseListTab(), CommandsTab()]),
      ),
    );
  }
}

void pushCommandsSearch(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Rechercher une commande')),
        body: const CommandsTab(embeddedSearch: true),
      ),
    ),
  );
}

class CourseListTab extends StatefulWidget {
  const CourseListTab({super.key});

  @override
  State<CourseListTab> createState() => _CourseListTabState();
}

class _CourseListTabState extends State<CourseListTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContentRepository>();
    final state = context.watch<AppState>();
    final courses = repo.courses
        .where(
          (c) =>
              _query.isEmpty ||
              normalizeSearch(c.title).contains(normalizeSearch(_query)),
        )
        .toList();
    if (courses.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'Aucun module trouvé',
        subtitle: 'Essayez un autre mot-clé.',
      );
    }
    final levels = <int>[];
    for (final c in courses) {
      if (!levels.contains(c.level)) levels.add(c.level);
    }
    levels.sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: const InputDecoration(
              hintText: 'Chercher un module…',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        for (final level in levels) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLevels.label(level, true),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                CountLabel(
                  current: state.completedInLevel(level),
                  total: state.totalInLevel(level),
                ),
              ],
            ),
          ),
          if (state.totalInLevel(level) > 0)
            MiniBar(
              value: state.totalInLevel(level) == 0
                  ? 0
                  : state.completedInLevel(level) / state.totalInLevel(level),
              color: levelColor(level),
            ),
          const SizedBox(height: 8),
          for (final course in courses.where((c) => c.level == level))
            CourseCard(course: course),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final completed = state.isCourseCompleted(course.id);
    final doneChapters = state.repo.courses
        .where((c) => c.id == course.id)
        .expand((c) => c.chapters)
        .where((ch) => state.isChapterCompleted('${course.id}/${ch.id}'))
        .length;
    final totalChapters = course.chaptersCount;
    final color = Accents.colorOf(course.accent);
    final favorite = state.isFavorite('course', course.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => pushPage(context, CourseDetailScreen(course: course)),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccentIcon(icon: course.icon, accent: course.accent, size: 21),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Pill(
                            text: 'Niv. ${course.level}',
                            color: levelColor(course.level),
                          ),
                          Pill(
                            text: '${course.chaptersCount} chap.',
                            color: color,
                          ),
                          Pill(
                            text: Fmt.duration(course.totalMinutes),
                            color: color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: favorite
                      ? 'Retirer des favoris'
                      : 'Ajouter aux favoris',
                  onPressed: () => state.toggleFavorite('course', course.id),
                  icon: Icon(
                    favorite ? Icons.star : Icons.star_border,
                    color: favorite ? AppColors.yellow : null,
                    size: 21,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MiniBar(
                    value: totalChapters == 0
                        ? 0
                        : doneChapters / totalChapters,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 78,
                  child: Text(
                    completed
                        ? 'Terminé ✓'
                        : '$doneChapters / $totalChapters chapitres',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> pushPage(BuildContext context, Widget page) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => page));
}
