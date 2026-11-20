import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/challenge_answer.dart';
import '../../core/constants.dart';
import '../../data/data_loader.dart';
import '../../models/course.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/code_block.dart';
import '../../widgets/common.dart';

/// Fiche d'une commande Linux : définition, syntaxe, exemples, exercice, défi.
class CommandDetailScreen extends StatefulWidget {
  final CommandInfo cmd;
  const CommandDetailScreen({super.key, required this.cmd});

  @override
  State<CommandDetailScreen> createState() => _CommandDetailScreenState();
}

class _CommandDetailScreenState extends State<CommandDetailScreen> {
  final TextEditingController _answerCtrl = TextEditingController();
  bool? _challengeResult;
  bool _revealed = false;

  CommandInfo get cmd => widget.cmd;

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  String get _expected => cmd.challengeAnswer ?? cmd.name;

  /// Réponse saisissable (commande) ou explication (auto-évaluation) ?
  bool _typable(BuildContext context) => ChallengeAnswer.isTypable(
    _expected,
    context.read<ContentRepository>().commands.map((c) => c.name),
  );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final fav = state.isFavorite('command', cmd.id);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10151C),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                cmd.name,
                style: const TextStyle(
                  color: AppColors.green,
                  fontFamily: 'MonoTech',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => state.toggleFavorite('command', cmd.id),
            icon: Icon(
              fav ? Icons.star : Icons.star_border,
              color: fav ? AppColors.yellow : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          Text(
            cmd.definition,
            style: const TextStyle(fontSize: 14.5, height: 1.5),
          ),
          const SizedBox(height: 14),
          if (cmd.syntax != null) ...[
            const SectionHeader(title: 'Syntaxe', icon: Icons.functions),
            CodeBlock(code: cmd.syntax!, label: 'syntaxe'),
          ],
          if (cmd.example != null) ...[
            const SizedBox(height: 8),
            const SectionHeader(title: 'Exemple', icon: Icons.play_arrow),
            CodeBlock(code: cmd.example!, label: 'exemple'),
            if (cmd.exampleOutput != null)
              CodeBlock(code: cmd.exampleOutput!, label: 'sortie'),
          ],
          if (cmd.options.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SectionHeader(title: 'Options utiles', icon: Icons.tune),
            ..._optionsRows(),
          ],
          if (cmd.exerciseAnswer != null) ...[
            const SizedBox(height: 12),
            ExerciseCard(
              question: cmd.exercise ?? 'Trouve la commande correspondante.',
              answer: cmd.exerciseAnswer!,
            ),
          ],
          if (cmd.commonError != null) ...[
            const SizedBox(height: 12),
            Callout(
              text: cmd.commonError!,
              color: AppColors.orange,
              icon: Icons.warning_amber_rounded,
              title: 'Erreur fréquente',
            ),
          ],
          const SizedBox(height: 16),
          AppCard(child: _buildChallenge(state)),
        ],
      ),
    );
  }

  Widget _buildChallenge(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.flag_outlined, color: AppColors.blue, size: 18),
            SizedBox(width: 8),
            Text(
              'Défi',
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          cmd.challenge ?? 'Quelle est cette commande ?',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        const SizedBox(height: 10),
        if (!_typable(context)) ...[
          OutlinedButton.icon(
            onPressed: () => setState(() => _revealed = !_revealed),
            icon: Icon(
              _revealed ? Icons.visibility_off : Icons.visibility,
              size: 18,
            ),
            label: Text(
              _revealed
                  ? 'Masquer la réponse'
                  : 'Réfléchis, puis vois la réponse',
            ),
          ),
          if (_revealed) ...[
            const SizedBox(height: 8),
            Callout(
              text: _expected,
              color: AppColors.blue,
              icon: Icons.lightbulb_outline,
              title: 'Réponse',
            ),
          ],
        ] else ...[
          TextField(
            controller: _answerCtrl,
            autofocus: false,
            style: const TextStyle(fontFamily: 'MonoTech', fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Réponse…',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, size: 18),
                onPressed: _check,
              ),
            ),
            onSubmitted: (_) => _check(),
          ),
          const SizedBox(height: 10),
          if (_challengeResult != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _challengeResult!
                  ? const Callout(
                      text: 'Bon, c’est exactement la bonne réponse.',
                      color: AppColors.green,
                      icon: Icons.check_circle,
                      title: 'Réponse correcte',
                    )
                  : const Callout(
                      text: 'Ce n’est pas tout à fait ça. Réessaie.',
                      color: AppColors.orange,
                      icon: Icons.refresh,
                      title: 'Incorrect',
                    ),
            ),
          if (cmd.challengeAnswer != null && _challengeResult == true) ...[
            const SizedBox(height: 6),
            CodeBlock(code: cmd.challengeAnswer!, label: 'réponse'),
          ],
        ],
      ],
    );
  }

  void _check() {
    if (_answerCtrl.text.trim().isEmpty) return;
    setState(
      () => _challengeResult = ChallengeAnswer.matches(
        _answerCtrl.text,
        _expected,
      ),
    );
  }

  List<Widget> _optionsRows() {
    return [
      AppCard(
        padding: const EdgeInsets.all(4),
        flat: true,
        child: Column(
          children: [
            for (final opt in cmd.options)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2A3646).withValues(alpha: 0.5)
                          : const Color(0xFFEDF1F6),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10151C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        opt[0],
                        style: const TextStyle(
                          color: AppColors.green,
                          fontFamily: 'MonoTech',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        opt.length > 1 ? opt[1] : '',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];
  }
}

class ExerciseCard extends StatefulWidget {
  final String question;
  final String answer;
  const ExerciseCard({super.key, required this.question, required this.answer});

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
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
              Icon(Icons.fitness_center, color: AppColors.green, size: 17),
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
            style: const TextStyle(fontSize: 13.6, height: 1.45),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _show = !_show),
              style: TextButton.styleFrom(foregroundColor: AppColors.green),
              icon: Icon(
                _show ? Icons.visibility_off : Icons.visibility,
                size: 16,
              ),
              label: Text(_show ? 'Cacher la solution' : 'Voir la solution'),
            ),
          ),
          if (_show) CodeBlock(code: widget.answer, label: 'solution'),
        ],
      ),
    );
  }
}
