import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/course.dart';
import 'app_card.dart';
import 'code_block.dart';
import 'common.dart';

/// Rend la liste des sections d'un chapitre.
class SectionFlow extends StatelessWidget {
  final List<ContentSection> sections;

  const SectionFlow({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (var i = 0; i < sections.length; i++) _wrap(sections[i])],
    );
  }

  Widget _wrap(ContentSection s) => _SectionWidgets.ofType(s);
}

/// Le rendu d'une section selon son type.
class _SectionWidgets {
  static Widget ofType(ContentSection s) {
    switch (s.type) {
      case SectionType.text:
        return TextSection(body: s.body ?? '');
      case SectionType.code:
        return CodeBlock(
          code: s.code ?? '',
          label: s.title ?? s.lang ?? 'Code',
        );
      case SectionType.tip:
        return Callout(
          text: s.body ?? '',
          color: AppColors.blue,
          icon: Icons.lightbulb_outline,
          title: s.title ?? 'À retenir',
        );
      case SectionType.warning:
        return Callout(
          text: s.body ?? '',
          color: AppColors.orange,
          icon: Icons.warning_amber_rounded,
          title: s.title ?? 'Attention',
        );
      case SectionType.exercise:
        return ExerciseWidget(question: s.question ?? '', answer: s.answer);
      case SectionType.definition:
        return DefinitionWidget(term: s.term ?? '', body: s.body ?? '');
      case SectionType.list:
        return ListSection(items: s.items ?? const []);
      case SectionType.table:
        return TableSection(table: s.table ?? const [], title: s.title);
      case SectionType.quote:
        return TerminalQuote(body: s.body ?? '');
    }
  }
}

class TextSection extends StatelessWidget {
  final String body;
  const TextSection({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(body, style: const TextStyle(fontSize: 14.5, height: 1.5)),
    );
  }
}

class ListSection extends StatelessWidget {
  final List<String> items;
  const ListSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1B232F)
            : const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.circle,
                      size: 7,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(fontSize: 13.5, height: 1.4),
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

class DefinitionWidget extends StatelessWidget {
  final String term;
  final String body;
  const DefinitionWidget({super.key, required this.term, required this.body});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AppCard(
      padding: const EdgeInsets.all(14),
      color: color.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.06,
      ),
      borderColor: color.withValues(alpha: 0.4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.book_outlined, color: AppColors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  term,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(fontSize: 13.4, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseWidget extends StatefulWidget {
  final String question;
  final String? answer;
  const ExerciseWidget({super.key, required this.question, this.answer});

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.green.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.07,
      ),
      borderColor: AppColors.green.withValues(alpha: 0.5),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fitness_center, color: AppColors.green, size: 18),
              SizedBox(width: 8),
              Text(
                'Exercice',
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.question,
            style: const TextStyle(fontSize: 13.8, height: 1.45),
          ),
          if (widget.answer != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _show = !_show),
                style: TextButton.styleFrom(foregroundColor: AppColors.green),
                icon: Icon(
                  _show ? Icons.visibility_off : Icons.visibility,
                  size: 16,
                ),
                label: Text(
                  _show ? 'Masquer la correction' : 'Voir la correction',
                ),
              ),
            ),
            if (_show) CodeBlock(code: widget.answer!, label: 'Correction'),
          ],
        ],
      ),
    );
  }
}

class TableSection extends StatelessWidget {
  final List<List<String>> table;
  final String? title;
  const TableSection({super.key, required this.table, this.title});

  @override
  Widget build(BuildContext context) {
    if (table.isEmpty) return const SizedBox.shrink();
    final columns = table.first.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          const SizedBox(height: 4),
          Text(
            title!,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A3646), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var r = 0; r < table.length; r++)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var c = 0; c < columns; c++)
                      Expanded(
                        flex: c == 0 ? 1 : 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 7,
                          ),
                          color: r == 0
                              ? Theme.of(context).brightness == Brightness.dark
                                    ? const Color(
                                        0xFF2A3646,
                                      ).withValues(alpha: 0.7)
                                    : const Color(0xFFE9EFF7)
                              : (r.isOdd
                                    ? Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF1B232F)
                                          : const Color(0xFFF6F9FC)
                                    : Colors.transparent),
                          child: Text(
                            table[r][c],
                            style: TextStyle(
                              fontFamily: c == 0 ? 'MonoTech' : null,
                              fontSize: 12.5,
                              fontWeight: r == 0
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              height: 1.35,
                              color: c == 0 ? AppColors.green : null,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class TerminalQuote extends StatelessWidget {
  final String body;
  const TerminalQuote({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10151C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        body,
        style: const TextStyle(
          fontFamily: 'MonoTech',
          fontSize: 13,
          height: 1.5,
          color: AppColors.green,
        ),
      ),
    );
  }
}
