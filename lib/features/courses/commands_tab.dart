import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../data/data_loader.dart';
import '../../models/course.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';
import 'command_detail_screen.dart';
import 'courses_screen.dart' show pushPage;

/// Onglet bibliothèque de commandes.
class CommandsTab extends StatefulWidget {
  final bool embeddedSearch;
  const CommandsTab({super.key, this.embeddedSearch = false});

  @override
  State<CommandsTab> createState() => _CommandsTabState();
}

class _CommandsTabState extends State<CommandsTab> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContentRepository>();
    final commands = repo.commands.where((c) {
      final q = normalizeSearch('${c.name} ${c.definition}');
      final okQuery = _query.isEmpty || q.contains(normalizeSearch(_query));
      final okCat = _category == null || c.category == _category;
      return okQuery && okCat;
    }).toList();

    final categories = <String>[];
    for (final c in repo.commands) {
      if (!categories.contains(c.category)) categories.add(c.category);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: const InputDecoration(
              hintText: 'Chercher une commande…',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _catChip('Toutes', _category == null, () {
                setState(() => _category = null);
              }),
              for (final cat in categories)
                _catChip(cat.toUpperCase(), _category == cat, () {
                  setState(() => _category = cat);
                }),
            ],
          ),
        ),
        Expanded(
          child: commands.isEmpty
              ? const EmptyState(
                  icon: Icons.terminal,
                  title: 'Aucune commande',
                  subtitle: 'Modifiez vos filtres.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                  itemCount: commands.length,
                  itemBuilder: (context, i) => _CommandTile(cmd: commands[i]),
                ),
        ),
      ],
    );
  }

  Widget _catChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  final CommandInfo cmd;
  const _CommandTile({required this.cmd});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final favorite = state.isFavorite('command', cmd.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () => pushPage(context, CommandDetailScreen(cmd: cmd)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10151C),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                cmd.name,
                style: const TextStyle(
                  fontFamily: 'MonoTech',
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cmd.definition,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.3),
                  ),
                  const SizedBox(height: 3),
                  _catBadge(cmd.category),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => state.toggleFavorite('command', cmd.id),
              icon: Icon(
                favorite ? Icons.star : Icons.star_border,
                color: favorite ? AppColors.yellow : null,
                size: 19,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catBadge(String cat) {
    const map = {
      'files': 'FICHIERS',
      'users': 'UTILISATEURS',
      'process': 'PROCESSUS',
      'system': 'SYSTÈME',
      'network': 'RÉSEAU',
      'kernel': 'NOYAU',
      'ssh': 'SSH',
      'packages': 'PAQUETS',
      'git': 'GIT',
      'hardware': 'MATÉRIEL',
    };
    final label = map[cat] ?? cat.toUpperCase();
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.inkSoft,
      ),
    );
  }
}
