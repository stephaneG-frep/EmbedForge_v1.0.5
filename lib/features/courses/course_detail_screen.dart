import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/course.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';
import '../../widgets/progress_chart.dart';
import 'chapter_screen.dart';
import 'courses_screen.dart' show pushPage;

/// Écran de détail d'un cours : objectifs + liste des chapitres.
class CourseDetailScreen extends StatelessWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final color = Accents.colorOf(course.accent);
    final favorite = state.isFavorite('course', course.id);
    final doneChapters = course.chapters
        .where((ch) => state.isChapterCompleted('${course.id}/${ch.id}'))
        .length;
    final isComplete = state.isCourseCompleted(course.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Module'),
        actions: [
          IconButton(
            tooltip: favorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
            onPressed: () => state.toggleFavorite('course', course.id),
            icon: Icon(
              favorite ? Icons.star : Icons.star_border,
              color: favorite ? AppColors.yellow : null,
            ),
          ),
          IconButton(
            tooltip: isComplete
                ? 'Marquer comme non terminé'
                : 'Marquer comme terminé',
            onPressed: () {
              state.setCourseCompleted(course.id, !isComplete);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isComplete
                        ? 'Module retiré de vos cours terminés'
                        : 'Module terminé ! Bravo.',
                  ),
                ),
              );
            },
            icon: Icon(
              isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isComplete ? AppColors.green : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AccentIcon(
                      icon: course.icon,
                      accent: course.accent,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              LevelChip(level: course.level),
                              Pill(
                                text: Fmt.duration(course.totalMinutes),
                                color: color,
                              ),
                              Pill(
                                text: '${course.chaptersCount} chapitres',
                                color: color,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  course.summary,
                  style: const TextStyle(fontSize: 13.8, height: 1.45),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MiniBar(
                        value: course.chaptersCount == 0
                            ? 0
                            : doneChapters / course.chaptersCount,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$doneChapters / ${course.chaptersCount} chapitres',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Objectifs du module',
            icon: Icons.flag_outlined,
          ),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final o in course.objectives)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            o,
                            style: const TextStyle(fontSize: 13.4, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Chapitres',
            icon: Icons.menu_book_outlined,
          ),
          for (var i = 0; i < course.chapters.length; i++)
            ChapterTile(
              course: course,
              chapter: course.chapters[i],
              index: i + 1,
            ),
        ],
      ),
    );
  }
}

class ChapterTile extends StatelessWidget {
  final Course course;
  final Chapter chapter;
  final int index;

  const ChapterTile({
    super.key,
    required this.course,
    required this.chapter,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final id = '${course.id}/${chapter.id}';
    final done = state.isChapterCompleted(id);
    final color = levelColor(course.level);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () =>
            pushPage(context, ChapterScreen(course: course, chapter: chapter)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.green.withValues(alpha: 0.18)
                    : color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, color: AppColors.green, size: 18)
                  : Text(
                      '$index',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: const TextStyle(
                      fontSize: 13.8,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppColors.inkSoft.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Fmt.duration(chapter.durationMinutes),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.inkSoft.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${chapter.sections.length} sections',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.inkSoft.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}
