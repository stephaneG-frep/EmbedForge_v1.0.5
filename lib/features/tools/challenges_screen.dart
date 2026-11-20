import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/challenge_answer.dart';
import '../../core/constants.dart';
import '../../data/data_loader.dart';
import '../../models/course.dart';
import '../../widgets/app_card.dart';
import '../../widgets/code_block.dart';
import '../../widgets/common.dart';

/// Défis : devine la commande qui répond à une question.
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int _index = 0;
  final _ctrl = TextEditingController();
  bool? _ok;
  String? _lastAnswer; // réponse attendue de la question qui vient d'être jouée
  int _streak = 0;
  int _done = 0;
  List<CommandInfo>? _pool;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Pool mélangé UNE seule fois : seuls les défis dont la réponse se tape.
  List<CommandInfo> _buildPool(BuildContext context) {
    final commands = context.read<ContentRepository>().commands;
    final names = commands.map((c) => c.name);
    return commands
        .where(
          (c) =>
              c.challenge != null &&
              c.challengeAnswer != null &&
              ChallengeAnswer.isTypable(c.challengeAnswer!, names),
        )
        .toList()
      ..shuffle();
  }

  void _check(CommandInfo cmd) {
    if (_ctrl.text.trim().isEmpty) return;
    final ok = ChallengeAnswer.matches(_ctrl.text, cmd.challengeAnswer!);
    setState(() {
      _ok = ok;
      _lastAnswer = cmd.challengeAnswer;
      _streak = ok ? _streak + 1 : 0;
      _done++;
      _index++;
    });
    _ctrl.clear();
  }

  void _skip(CommandInfo cmd) {
    setState(() {
      _ok = false;
      _lastAnswer = cmd.challengeAnswer;
      _index++;
      _streak = 0;
    });
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final pool = _pool ??= _buildPool(context);
    if (pool.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Défis')),
        body: const EmptyState(
          icon: Icons.flag,
          title: 'Aucun défi disponible',
        ),
      );
    }
    final cmd = pool[_index % pool.length];
    return Scaffold(
      appBar: AppBar(title: const Text('Défis & quiz express')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _stat('Défis relevés', '$_done', AppColors.blue)),
              const SizedBox(width: 10),
              Expanded(
                child: _stat('Série en cours', '$_streak', AppColors.orange),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      color: AppColors.orange,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'CHALLENGE',
                      style: TextStyle(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  cmd.challenge!,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ctrl,
                  style: const TextStyle(fontFamily: 'MonoTech', fontSize: 14),
                  onSubmitted: (_) => _check(cmd),
                  decoration: InputDecoration(
                    hintText: 'taper la commande…',
                    prefixIcon: const Icon(Icons.terminal),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _skip(cmd),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.inkSoft,
                        ),
                        child: const Text('Passer'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _check(cmd),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.green,
                        ),
                        child: const Text(
                          'Valider',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_ok != null) ...[
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _ok!
                  ? const Callout(
                      title: 'Correct',
                      text:
                          'Bien vu ! La commande répond exactement au besoin.',
                      color: AppColors.green,
                      icon: Icons.check_circle,
                    )
                  : Callout(
                      title: 'Incorrect',
                      text: 'La bonne réponse était : $_lastAnswer',
                      color: AppColors.orange,
                      icon: Icons.refresh,
                    ),
            ),
          ],
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'Réviser la commande',
            icon: Icons.menu_book,
          ),
          CodeBlock(
            label: cmd.name,
            code: cmd.syntax ?? cmd.example ?? cmd.name,
          ),
          const SizedBox(height: 6),
          Text(
            cmd.definition,
            style: const TextStyle(fontSize: 13.2, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
