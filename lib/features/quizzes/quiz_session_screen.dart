import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/course.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/progress_chart.dart';
import 'quizzes_screen.dart';

enum _Phase { question, review }

/// Déroulé d'un quiz : une question après l'autre, puis révision.
class QuizSessionScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizSessionScreen({super.key, required this.quiz});

  /// Nombre de questions posées par partie quand le quiz en contient plus :
  /// chaque partie tire un nouveau sous-ensemble, pour pouvoir rejouer.
  static const questionsParPartie = 10;

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  int _index = 0;
  final List<int?> _answers = [];
  _Phase _phase = _Phase.question;
  int _correct = 0;

  /// Ordre d'affichage des options, par question (indices d'origine) : la
  /// bonne réponse ne tombe pas toujours au même endroit.
  List<List<int>> _order = [];
  final _rng = math.Random();

  /// Questions de la partie en cours (tirage dans la banque du quiz).
  List<QuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _nouvellePartie();
  }

  void _nouvellePartie() {
    final banque = widget.quiz.questions;
    _questions = banque.length > QuizSessionScreen.questionsParPartie
        ? ([
            ...banque,
          ]..shuffle(_rng)).take(QuizSessionScreen.questionsParPartie).toList()
        : [...banque];
    _answers
      ..clear()
      ..addAll(List<int?>.filled(_questions.length, null));
    _index = 0;
    _correct = 0;
    _shuffleOptions();
  }

  void _shuffleOptions() {
    _order = [
      for (final q in _questions)
        List<int>.generate(q.options.length, (i) => i)..shuffle(_rng),
    ];
  }

  Quiz get quiz => widget.quiz;

  void _select(int i) {
    setState(() => _answers[_index] = i);
  }

  void _next() {
    // Chaque question n'est comptée qu'une seule fois.
    if (_answers[_index] == _questions[_index].answer) _correct++;
    if (_index + 1 < _questions.length) {
      setState(() => _index++);
    } else {
      final state = context.read<AppState>();
      state.saveQuizScore(quiz.id, _correct, _questions.length);
      setState(() => _phase = _Phase.review);
    }
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = quizColor(quiz.level);
    final questions = _questions;

    if (_phase == _Phase.review) {
      final ratio = _correct / questions.length;
      return _ReviewView(
        score: _correct,
        total: questions.length,
        ratio: ratio,
        color: color,
        questions: questions,
        answers: _answers,
        onDone: _close,
        onRetry: () => setState(() {
          _nouvellePartie(); // nouveau tirage de questions
          _phase = _Phase.question;
        }),
      );
    }

    final q = questions[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _close),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: MiniBar(
                    value: (_index + 1) / questions.length,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_index + 1} / ${questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 4),
                Text(
                  'Question ${_index + 1}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  q.q,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                for (var pos = 0; pos < q.options.length; pos++)
                  Builder(
                    builder: (_) {
                      final i = _order[_index][pos]; // indice d'origine
                      return _OptionTile(
                        letter: String.fromCharCode(65 + pos),
                        text: q.options[i],
                        selected: _answers[_index] == i,
                        onTap: _answers[_index] == null
                            ? () => _select(i)
                            : null,
                        color: color,
                      );
                    },
                  ),
                const SizedBox(height: 6),
                if (_answers[_index] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: FilledButton.icon(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(
                        _index + 1 < questions.length
                            ? Icons.arrow_forward
                            : Icons.check,
                        size: 18,
                      ),
                      label: Text(
                        _index + 1 < questions.length
                            ? 'Question suivante'
                            : 'Voir le résultat',
                      ),
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

class _OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final Color color;

  const _OptionTile({
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        color: selected
            ? color.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.24
                    : 0.14,
              )
            : null,
        borderColor: selected ? color : null,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? color : const Color(0xFF262F3D),
                shape: BoxShape.circle,
              ),
              child: Text(
                letter,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 13.8, height: 1.35),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 18, color: AppColors.green),
          ],
        ),
      ),
    );
  }
}

class _ReviewView extends StatelessWidget {
  final int score;
  final int total;
  final double ratio;
  final Color color;
  final List<QuizQuestion> questions;
  final List<int?> answers;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  const _ReviewView({
    required this.score,
    required this.total,
    required this.ratio,
    required this.color,
    required this.questions,
    required this.answers,
    required this.onDone,
    required this.onRetry,
  });

  String get _message {
    if (ratio >= 0.9) return 'Excellent ! Niveau maîtrisé.';
    if (ratio >= 0.7) return 'Très bien, tu progresses vite.';
    if (ratio >= 0.5) return 'Pas mal. Un peu de révision et ce sera parfait.';
    return 'Courage : relis les cours du niveau puis retente.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Résultat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                ProgressRing(
                  value: ratio,
                  size: 110,
                  stroke: 10,
                  color: color,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score/$total',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${(ratio * 100).round()} %',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.replay, size: 17),
                        label: const Text('Rejouer'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onDone,
                        style: FilledButton.styleFrom(backgroundColor: color),
                        icon: const Icon(Icons.check, size: 17),
                        label: const Text('Terminer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Correction',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < questions.length; i++)
            _CorrectionTile(
              index: i,
              question: questions[i],
              userAnswer: answers[i],
            ),
        ],
      ),
    );
  }
}

class _CorrectionTile extends StatelessWidget {
  final int index;
  final QuizQuestion question;
  final int? userAnswer;

  const _CorrectionTile({
    required this.index,
    required this.question,
    required this.userAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final ok = userAnswer == question.answer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(13),
        color: ok
            ? AppColors.green.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.12
                    : 0.07,
              )
            : null,
        borderColor: ok ? AppColors.green.withValues(alpha: 0.6) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ok ? Icons.check_circle : Icons.cancel,
                  size: 18,
                  color: ok ? AppColors.green : AppColors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Q${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (userAnswer == null)
                  const Text(
                    'sans réponse',
                    style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              question.q,
              style: const TextStyle(fontSize: 13.4, height: 1.4),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF11161C)
                    : const Color(0xFFF2F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Réponse : ${question.options[question.answer]}',
                style: const TextStyle(
                  fontSize: 12.8,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            if (userAnswer != null && !ok) ...[
              const SizedBox(height: 6),
              Text(
                'Ton choix : ${question.options[userAnswer!]}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.red,
                  height: 1.4,
                ),
              ),
            ],
            if (question.explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Explication : ${question.explanation}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.inkSoft,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
