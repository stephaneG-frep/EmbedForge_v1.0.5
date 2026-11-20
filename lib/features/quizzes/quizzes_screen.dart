import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../data/data_loader.dart';
import '../../models/course.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';
import 'quiz_session_screen.dart';

const _quizColors = {
  QuizLevel.beginner: AppColors.green,
  QuizLevel.intermediate: AppColors.blue,
  QuizLevel.advanced: AppColors.purple,
  QuizLevel.expert: AppColors.orange,
};

Color quizColor(QuizLevel l) => _quizColors[l]!;

/// Espace Quiz : choix du niveau puis passage du quiz.
class QuizzesScreen extends StatelessWidget {
  const QuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContentRepository>();
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz & défis')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10151C), Color(0xFF2A1B3B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(kRadius),
            ),
            child: const Text(
              'Teste tes connaissances après chaque niveau. Les explications sont '
              'fournies question par question — lire la correction fait partie '
              'de l’apprentissage.',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 14),
          for (final quiz in repo.quizzes) _QuizCard(quiz: quiz, state: state),
          if (repo.quizzes.isEmpty)
            const EmptyState(
              icon: Icons.quiz,
              title: 'Quiz bientôt disponibles',
            ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final Quiz quiz;
  final AppState state;
  const _QuizCard({required this.quiz, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = quizColor(quiz.level);
    final result = state.quizResults[quiz.id];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => pushQuiz(context, quiz),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.quiz_outlined, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Pill(text: quizLevelLabel(quiz.level), color: color),
                      Pill(
                        text: '${quiz.questions.length} questions',
                        color: color,
                      ),
                      if (result != null)
                        Pill(
                          text: '${(result.ratio * 100).round()} %',
                          color: AppColors.green,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}

Future<void> pushQuiz(BuildContext context, Quiz quiz) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => QuizSessionScreen(quiz: quiz)));
}
