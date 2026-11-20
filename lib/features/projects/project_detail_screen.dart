import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/secondary.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/code_block.dart';
import '../../widgets/common.dart';
import 'projects_screen.dart';

/// Détail d'un projet : objectifs, étapes pas-à-pas, compétences.
class ProjectDetailScreen extends StatelessWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final done = state.isProjectCompleted(project.id);
    final color = projectDifficultyColor(project.difficulty);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.isFinal ? 'Projet final' : 'Projet'),
        actions: [
          IconButton(
            tooltip: done
                ? 'Marquer comme non réalisé'
                : 'Marquer comme réalisé',
            onPressed: () => state.toggleProjectCompleted(project.id),
            icon: Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? AppColors.green : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AccentIcon(
                      icon: project.icon,
                      accent: done ? 'green' : 'blue',
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        project.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Pill(text: project.difficulty, color: color),
                    Pill(text: project.category, color: color),
                    if (done)
                      const Pill(text: 'REALISÉ', color: AppColors.green),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project.summary,
                  style: const TextStyle(fontSize: 13.5, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(title: 'Objectifs', icon: Icons.flag_outlined),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (final o in project.objectives)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            o,
                            style: const TextStyle(fontSize: 13.2, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(title: 'Étapes', icon: Icons.route_outlined),
          for (var i = 0; i < project.steps.length; i++)
            _step(i + 1, project.steps[i]),
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'Compétences visées',
            icon: Icons.school_outlined,
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in project.skills)
                Chip(
                  label: Text(s),
                  visualDensity: VisualDensity.compact,
                  labelStyle: const TextStyle(fontSize: 11.5),
                ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => state.toggleProjectCompleted(project.id),
            style: FilledButton.styleFrom(
              backgroundColor: done ? AppColors.inkSoft : AppColors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(done ? Icons.undo : Icons.check_circle, size: 18),
            label: Text(
              done ? 'Retirer des projets réalisés' : 'Projet réalisé !',
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(int n, ProjectStep step) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$n',
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (step.body != null) ...[
            const SizedBox(height: 8),
            Text(
              step.body!,
              style: const TextStyle(fontSize: 13.2, height: 1.45),
            ),
          ],
          if (step.code != null) ...[
            const SizedBox(height: 8),
            CodeBlock(code: step.code!, label: 'étape $n'),
          ],
          if (step.output != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10151C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '\$ ${step.output}',
                style: const TextStyle(
                  fontFamily: 'MonoTech',
                  color: AppColors.green,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
