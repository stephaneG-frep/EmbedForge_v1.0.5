import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../data/data_loader.dart';
import '../../models/course.dart';
import '../../models/secondary.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';
import '../courses/course_detail_screen.dart';
import '../courses/command_detail_screen.dart';
import '../projects/project_detail_screen.dart';
import '../quizzes/quiz_session_screen.dart';
import 'cheat_sheets_screen.dart';
import 'glossary_screen.dart';

class _Hit {
  final String
  type; // course | command | glossary | cheat | project | quiz | chapter
  final String id;
  final String title;
  final String excerpt;
  final IconData icon;
  final Color color;
  final String accented;

  _Hit({
    required this.type,
    required this.id,
    required this.title,
    required this.excerpt,
    required this.icon,
    required this.color,
    required this.accented,
  });
}

/// Recherche globale sur tout le contenu.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<_Hit> _search(ContentRepository repo) {
    final q = normalizeSearch(_query);
    if (q.isEmpty) return [];
    final hits = <_Hit>[];

    for (final c in repo.courses) {
      if (normalizeSearch(c.title).contains(q) ||
          normalizeSearch(c.summary).contains(q)) {
        hits.add(
          _Hit(
            type: 'course',
            id: c.id,
            title: c.title,
            excerpt: c.summary,
            icon: Icons.menu_book,
            color: Accents.colorOf(c.accent),
            accented: c.level.toString(),
          ),
        );
      }
      for (final ch in c.chapters) {
        if (normalizeSearch(ch.title).contains(q) ||
            ch.sections.any(
              (s) => normalizeSearch(
                '${s.body ?? ''} ${s.term ?? ''}',
              ).contains(q),
            )) {
          hits.add(
            _Hit(
              type: 'chapter',
              id: '${c.id}/${ch.id}',
              title: ch.title,
              excerpt: 'Chapitre de « ${c.title} »',
              icon: Icons.library_books_outlined,
              color: Accents.colorOf(c.accent),
              accented: c.level.toString(),
            ),
          );
        }
      }
    }
    for (final cmd in repo.commands) {
      if (normalizeSearch('${cmd.name} ${cmd.definition}').contains(q)) {
        hits.add(
          _Hit(
            type: 'command',
            id: cmd.id,
            title: cmd.name,
            excerpt: cmd.definition,
            icon: Icons.terminal,
            color: AppColors.green,
            accented: cmd.category,
          ),
        );
      }
    }
    for (final g in repo.glossary) {
      if (normalizeSearch('${g.term} ${g.definition}').contains(q)) {
        hits.add(
          _Hit(
            type: 'glossary',
            id: g.term,
            title: g.term,
            excerpt: g.definition,
            icon: Icons.book_outlined,
            color: AppColors.teal,
            accented: g.category,
          ),
        );
      }
    }
    for (final s in repo.cheatSheets) {
      if (normalizeSearch(s.title).contains(q)) {
        hits.add(
          _Hit(
            type: 'cheat',
            id: s.id,
            title: s.title,
            excerpt: '${s.sections.length} sections pratiques',
            icon: Icons.note_alt_outlined,
            color: Accents.colorOf(s.accent),
            accented: 'fiche',
          ),
        );
      }
    }
    for (final p in repo.projects) {
      if (normalizeSearch('${p.title} ${p.summary}').contains(q)) {
        hits.add(
          _Hit(
            type: 'project',
            id: p.id,
            title: p.title,
            excerpt: p.summary,
            icon: Icons.rocket_launch_outlined,
            color: AppColors.green,
            accented: p.difficulty,
          ),
        );
      }
    }
    for (final quiz in repo.quizzes) {
      if (normalizeSearch(quiz.title).contains(q)) {
        hits.add(
          _Hit(
            type: 'quiz',
            id: quiz.id,
            title: quiz.title,
            excerpt: '${quiz.questions.length} questions',
            icon: Icons.quiz_outlined,
            color: AppColors.purple,
            accented: quizLevelLabel(quiz.level),
          ),
        );
      }
    }
    return hits.take(60).toList();
  }

  void _open(BuildContext context, _Hit hit, ContentRepository repo) {
    switch (hit.type) {
      case 'course':
      case 'chapter':
        final parts = hit.type == 'chapter' ? hit.id.split('/') : [hit.id, ''];
        final course = repo.course(parts[0]);
        if (course != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(course: course),
            ),
          );
        }
        break;
      case 'command':
        final cmd = repo.command(hit.id);
        if (cmd != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CommandDetailScreen(cmd: cmd)),
          );
        }
        break;
      case 'glossary':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const GlossaryScreen()));
        break;
      case 'cheat':
        final sheet = _findSheet(repo, hit.id);
        if (sheet != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CheatSheetDetailScreen(sheet: sheet),
            ),
          );
        }
        break;
      case 'project':
        final project = _findProject(repo, hit.id);
        if (project != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(project: project),
            ),
          );
        }
        break;
      case 'quiz':
        final quiz = repo.quizzes.where((x) => x.id == hit.id).firstOrNull;
        if (quiz != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => QuizSessionScreen(quiz: quiz)),
          );
        }
        break;
    }
  }

  CheatSheet? _findSheet(ContentRepository repo, String id) {
    for (final s in repo.cheatSheets) {
      if (s.id == id) return s;
    }
    return null;
  }

  Project? _findProject(ContentRepository repo, String id) {
    for (final p in repo.projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContentRepository>();
    final hits = _search(repo);
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: const InputDecoration(
                hintText: 'Cours, commandes, définitions…',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.shortcut),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: hits.isEmpty
                ? EmptyState(
                    icon: Icons.manage_search,
                    title: _query.isEmpty
                        ? 'Recherche globale'
                        : 'Aucun résultat',
                    subtitle: _query.isEmpty
                        ? 'Cherche un module, une commande, un terme, un projet ou une fiche.'
                        : 'Essaie avec d’autres mots-clés.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    itemCount: hits.length,
                    itemBuilder: (context, i) => _HitTile(
                      hit: hits[i],
                      onTap: () => _open(context, hits[i], repo),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HitTile extends StatelessWidget {
  final _Hit hit;
  final VoidCallback onTap;
  const _HitTile({required this.hit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hit.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(hit.icon, color: hit.color, size: 18),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.8,
                    ),
                  ),
                  Text(
                    hit.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkSoft,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Pill(text: hit.accented, color: hit.color),
          ],
        ),
      ),
    );
  }
}

extension SearchFirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

Future<void> pushSearch(BuildContext context) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
}
