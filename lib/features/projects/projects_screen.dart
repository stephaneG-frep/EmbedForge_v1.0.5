import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../data/data_loader.dart';
import '../../models/secondary.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';
import '../../widgets/progress_chart.dart';
import 'project_detail_screen.dart';

Color projectDifficultyColor(String d) {
  switch (d.toLowerCase()) {
    case 'débutant':
    case 'debutant':
      return AppColors.green;
    case 'facile':
      return AppColors.green;
    case 'intermédiaire':
    case 'intermediaire':
      return AppColors.blue;
    case 'avancé':
    case 'avance':
      return AppColors.orange;
    default:
      return AppColors.blue;
  }
}

/// Espace « Projets » : 10 mini-projets + 1 projet final.
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContentRepository>();
    final state = context.watch<AppState>();
    final projects = repo.projects;
    final minis = projects.where((p) => !p.isFinal).toList();
    final finals = projects.where((p) => p.isFinal).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Projets pratiques')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10151C), Color(0xFF1D3A3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(kRadius),
            ),
            child: const Text(
              'La pratique fait le développeur embarqué. Enchaîne les 10 '
              'mini-projets puis tente le projet final.',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 14),
          CountLabel(
            current: state.completedProjectsCount,
            total: projects.length,
          ),
          const SizedBox(height: 6),
          MiniBar(
            value: projects.isEmpty
                ? 0
                : state.completedProjectsCount / projects.length,
            color: AppColors.green,
          ),
          const SizedBox(height: 14),
          const SectionHeader(title: 'Mini-projets', icon: Icons.build),
          for (final p in minis) ProjectTile(project: p),
          if (finals.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SectionHeader(
              title: 'Projet final',
              icon: Icons.rocket_launch,
            ),
            for (final p in finals) ProjectTile(project: p, big: true),
          ],
          if (projects.isEmpty)
            const EmptyState(icon: Icons.build, title: 'Projets à venir'),
        ],
      ),
    );
  }
}

class ProjectTile extends StatelessWidget {
  final Project project;
  final bool big;
  const ProjectTile({super.key, required this.project, this.big = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final done = state.isProjectCompleted(project.id);
    final color = projectDifficultyColor(project.difficulty);
    if (big) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          onTap: () => pushProject(context, project),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Accents.iconOf(project.icon),
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.3,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              if (done)
                const Icon(Icons.check_circle, color: AppColors.green)
              else
                const Icon(Icons.chevron_right, color: AppColors.inkSoft),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () => pushProject(context, project),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            AccentIcon(
              icon: project.icon,
              accent: done ? 'green' : 'blue',
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 13.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Pill(text: project.difficulty, color: color),
                ],
              ),
            ),
            if (done)
              const Icon(Icons.check_circle, color: AppColors.green, size: 20),
          ],
        ),
      ),
    );
  }
}

Future<void> pushProject(BuildContext context, Project project) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
  );
}
