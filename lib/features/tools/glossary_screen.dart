import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../data/data_loader.dart';
import '../../models/secondary.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';

/// Glossaire consultable et recherchable.
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _query = '';
  String? _selectedCategory;
  String? _openTerm;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContentRepository>();
    final entries = repo.glossary.where((e) {
      final okQuery =
          _query.isEmpty ||
          normalizeSearch(
            '${e.term} ${e.definition}',
          ).contains(normalizeSearch(_query));
      final okCat =
          _selectedCategory == null || e.category == _selectedCategory;
      return okQuery && okCat;
    }).toList();

    final categories = <String>[];
    for (final e in repo.glossary) {
      if (!categories.contains(e.category)) categories.add(e.category);
    }
    categories.sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Glossaire')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: const InputDecoration(
                hintText: 'Rechercher un terme…',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _cat('Toutes', _selectedCategory == null, () {
                  setState(() => _selectedCategory = null);
                }),
                for (final c in categories)
                  _cat(c, _selectedCategory == c, () {
                    setState(() => _selectedCategory = c);
                  }),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const EmptyState(
                    icon: Icons.menu_book,
                    title: 'Aucun terme',
                    subtitle: 'Modifiez votre recherche.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    itemCount: entries.length,
                    itemBuilder: (context, i) => _GlossaryTile(
                      entry: entries[i],
                      open: _openTerm == entries[i].term,
                      onTap: () => setState(() {
                        _openTerm = _openTerm == entries[i].term
                            ? null
                            : entries[i].term;
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cat(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }
}

class _GlossaryTile extends StatelessWidget {
  final GlossaryEntry entry;
  final bool open;
  final VoidCallback onTap;
  const _GlossaryTile({
    required this.entry,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.term,
                    style: const TextStyle(
                      fontFamily: 'MonoTech',
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                _catPill(entry.category),
                const SizedBox(width: 6),
                Icon(
                  open ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.inkSoft,
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              child: open
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entry.definition,
                        style: const TextStyle(fontSize: 13.2, height: 1.45),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catPill(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
