import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/course.dart';
import '../../state/app_state.dart';
import '../../widgets/section_flow.dart';

/// Écran d'un chapitre : parcours des sections pédagogiques.
class ChapterScreen extends StatefulWidget {
  final Course course;
  final Chapter chapter;

  const ChapterScreen({super.key, required this.course, required this.chapter});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  bool _completed = false;
  bool _doneInit = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final id = '${widget.course.id}/${widget.chapter.id}';
    if (!_doneInit) {
      _completed = state.isChapterCompleted(id);
      _doneInit = true;
    }
    final color = Theme.of(context).colorScheme.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapter.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Favori',
            onPressed: () => state.toggleFavorite('chapter', id),
            icon: Builder(
              builder: (context) {
                final fav = state.isFavorite('chapter', id);
                return Icon(
                  fav ? Icons.star : Icons.star_border,
                  color: fav ? AppColors.yellow : null,
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: color.withValues(alpha: dark ? 0.16 : 0.09),
            child: Row(
              children: [
                Icon(Icons.menu_book_outlined, size: 17, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.course.title} · ${widget.chapter.sections.length} sections',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    final target = !_completed;
                    setState(() => _completed = target);
                    state.setChapterCompleted(id, target);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          target
                              ? 'Chapitre terminé ✓'
                              : 'Chapitre marqué comme non terminé',
                        ),
                        duration: const Duration(milliseconds: 1100),
                      ),
                    );
                    // Marque automatiquement le cours si tout est terminé.
                    final courseDone = widget.course.chapters.every(
                      (ch) => state.isChapterCompleted(
                        '${widget.course.id}/${ch.id}',
                      ),
                    );
                    if (courseDone &&
                        !state.isCourseCompleted(widget.course.id)) {
                      state.setCourseCompleted(widget.course.id, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Module complet : félicitations !'),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.green),
                  icon: Icon(
                    _completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                  ),
                  label: Text(
                    _completed ? 'Terminé' : 'Terminer',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
              children: [SectionFlow(sections: widget.chapter.sections)],
            ),
          ),
        ],
      ),
    );
  }
}
