import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../data/data_loader.dart';
import '../../models/secondary.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/progress_chart.dart';
import '../courses/course_detail_screen.dart';

/// Roadmap métier : coche les compétences maîtrisées.
class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContentRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Devenir développeur embarqué')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _header(),
          const SizedBox(height: 12),
          for (var i = 0; i < repo.roadmap.length; i++)
            _RoadmapTile(index: i, step: repo.roadmap[i]),
        ],
      ),
    );
  }

  Widget _header() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final repo = context.watch<ContentRepository>();
        final total = repo.roadmap.length;
        final done = repo.roadmap
            .where((s) => state.hasRoadmapSkill(s.id))
            .length;
        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProgressRing(
                    value: total == 0 ? 0 : done / total,
                    size: 64,
                    color: AppColors.blue,
                    child: Text(
                      '$done/$total',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Par où commencer ?',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Coche chaque compétence lorsque tu la maîtrises. '
                          'La barre suit ta progression.',
                          style: TextStyle(
                            fontSize: 12.3,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              MiniBar(
                value: total == 0 ? 0 : done / total,
                color: AppColors.blue,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoadmapTile extends StatelessWidget {
  final int index;
  final RoadmapStep step;
  const _RoadmapTile({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final done = state.hasRoadmapSkill(step.id);
    final color = step.level <= 1
        ? AppColors.green
        : step.level <= 3
        ? AppColors.blue
        : AppColors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        children: [
          InkWell(
            onTap: () => state.toggleRoadmapSkill(step.id),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: done
                    ? AppColors.green.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.16
                            : 0.1,
                      )
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: done
                      ? AppColors.green.withValues(alpha: 0.7)
                      : const Color(0xFF2A3646).withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: done
                        ? Container(
                            key: const ValueKey('on'),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 15,
                            ),
                          )
                        : Container(
                            key: const ValueKey('off'),
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.8,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: Colors.white38,
                            color: done ? AppColors.inkSoft : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.8,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.inkSoft, size: 20),
                ],
              ),
            ),
          ),
          if (index < state.repo.roadmap.length - 1)
            Container(
              width: 2,
              height: 12,
              margin: const EdgeInsets.only(left: 16),
              color: done
                  ? AppColors.green.withValues(alpha: 0.4)
                  : color.withValues(alpha: 0.35),
            ),
        ],
      ),
    );
  }
}

/// Ouvre la roadmap depuis le tableau de bord.
Future<void> pushCourseByCourseId(BuildContext context, String? id) async {
  final repo = context.read<ContentRepository>();
  final course = id == null ? null : repo.course(id);
  if (course != null) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
    );
  }
}

class RoadmapTileConnect {
  static void open(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RoadmapScreen()));
  }
}
