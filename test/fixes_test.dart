import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:embedforge/app/app.dart';
import 'package:embedforge/core/challenge_answer.dart';
import 'package:embedforge/data/data_loader.dart';
import 'package:embedforge/features/labs/spi_lab.dart';
import 'package:embedforge/features/quizzes/quiz_session_screen.dart';
import 'package:embedforge/main.dart';
import 'package:embedforge/models/course.dart';
import 'package:embedforge/services/storage_service.dart';
import 'package:embedforge/state/app_state.dart';

/// Tests de non-régression des bugs fonctionnels corrigés.
void main() {
  group('ChallengeAnswer.matches', () {
    test('réponse exacte, casse et espaces ignorés', () {
      expect(ChallengeAnswer.matches('LS   -lh /etc', 'ls -lh /etc'), isTrue);
    });

    test('refuse une commande précédée de n’importe quoi', () {
      expect(
        ChallengeAnswer.matches('toto ls -lh /etc', 'ls -lh /etc'),
        isFalse,
      );
    });

    test('refuse une réponse partielle ou vide', () {
      expect(ChallengeAnswer.matches('ls', 'ls -lh /etc'), isFalse);
      expect(ChallengeAnswer.matches('   ', 'ls -lh /etc'), isFalse);
    });

    test('remarque finale entre parenthèses ignorée', () {
      expect(
        ChallengeAnswer.matches(
          'ping 192.168.1.1',
          'ping 192.168.1.1 (arrêter avec Ctrl+C)',
        ),
        isTrue,
      );
      expect(ChallengeAnswer.matches('w', 'w (write)'), isTrue);
    });

    test('sudo initial et guillemets typographiques tolérés', () {
      expect(
        ChallengeAnswer.matches(
          'apt install build-essential',
          'sudo apt install build-essential',
        ),
        isTrue,
      );
      expect(
        ChallengeAnswer.matches('grep -v “debug” f', 'grep -v "debug" f'),
        isTrue,
      );
    });
  });

  group('ChallengeAnswer.isTypable', () {
    const names = ['ls', 'rmmod', 'file', 'ping'];
    test('commandes et touches : saisissables', () {
      expect(ChallengeAnswer.isTypable('ls -lh /etc', names), isTrue);
      expect(ChallengeAnswer.isTypable('q', names), isTrue);
      expect(ChallengeAnswer.isTypable('rmmod mon_driver', names), isTrue);
    });
    test('phrases explicatives : non saisissables', () {
      expect(
        ChallengeAnswer.isTypable(
          'Le module est utilisé par un autre module ou un processus.',
          names,
        ),
        isFalse,
      );
      expect(
        ChallengeAnswer.isTypable('Taper /error puis Entrée dans less.', names),
        isFalse,
      );
    });

    test('contenu réel : chaque défi saisissable a une réponse acceptée', () {
      final cmds =
          (jsonDecode(
                    File(
                      'assets/data/commands/commands.json',
                    ).readAsStringSync(),
                  )
                  as List)
              .cast<Map<String, dynamic>>();
      final allNames = cmds.map((c) => c['name'] as String);
      var typable = 0;
      for (final c in cmds) {
        final a = c['challengeAnswer'] as String?;
        if (a == null || !ChallengeAnswer.isTypable(a, allNames)) continue;
        typable++;
        expect(
          ChallengeAnswer.matches(ChallengeAnswer.canonical(a), a),
          isTrue,
          reason: c['name'] as String,
        );
      }
      expect(typable, greaterThan(50));
    });
  });

  group('SPI', () {
    test('8 coups d’horloge échangent les octets master et slave', () {
      var (m, s) = (0x35, 0x7A);
      for (var i = 0; i < 8; i++) {
        (m, s) = spiClock(m, s);
      }
      expect(m, 0x7A);
      expect(s, 0x35);
    });

    test('un coup d’horloge décale d’un bit (MSB first)', () {
      // master 1000_0000, slave 0000_0001 → MOSI=1, MISO=0
      expect(spiClock(0x80, 0x01), (0x00, 0x03));
    });
  });

  group('DataLoader.parseAll', () {
    test('une entrée invalide n’écarte pas les autres', () {
      final out = DataLoader.parseAll<Chapter>(
        [
          {'id': 'a', 'title': 'A'},
          {'id': 'b'}, // title manquant → TypeError
          {'id': 'c', 'title': 'C'},
        ],
        Chapter.fromJson,
        'test',
      );
      expect(out.map((c) => c.id), ['a', 'c']);
    });
  });

  group('StorageService sans init()', () {
    test('fonctionne en mémoire au lieu de lever une erreur', () {
      final s = StorageService();
      expect(s.isPersistent, isFalse);
      s.setCourseCompleted('intro_linux', true);
      s.toggleFavorite('command', 'ls');
      s.saveQuizScore('q1', 3, 4);
      s.setFontScale(1.2);
      expect(s.isCourseCompleted('intro_linux'), isTrue);
      expect(s.isFavorite('command', 'ls'), isTrue);
      expect(s.quizResults['q1']!.correct, 3);
      expect(s.fontScale, 1.2);
      s.resetAll();
      expect(s.completedCourses, isEmpty);
    });
  });

  group('Export / import de la progression', () {
    test('aller-retour complet vers un autre appareil', () async {
      SharedPreferences.setMockInitialValues({});
      final a = StorageService();
      await a.init();
      a.setCourseCompleted('gpio', true);
      a.setChapterCompleted('gpio/ch1', true);
      a.toggleFavorite('command', 'ls');
      a.saveQuizScore('quiz_debutant', 8, 8);
      a.setThemeMode('dark');
      a.setFontScale(1.15);
      final code = a.exportCode();
      expect(code, startsWith(StorageService.exportPrefix));

      final b = StorageService(); // autre appareil (repli mémoire)
      b.setCourseCompleted('autre', true);
      b.importCode(code);
      expect(b.completedCourses, {'gpio'});
      expect(b.isChapterCompleted('gpio/ch1'), isTrue);
      expect(b.isFavorite('command', 'ls'), isTrue);
      expect(b.quizResults['quiz_debutant']!.correct, 8);
      expect(b.themeMode, 'dark');
      expect(b.fontScale, 1.15);
    });

    test('code invalide : erreur claire et rien n’est modifié', () {
      final s = StorageService()..setCourseCompleted('gpio', true);
      for (final bad in [
        'n’importe quoi',
        '${StorageService.exportPrefix}%%%',
        StorageService.exportPrefix + base64Encode(utf8.encode('{"v":99}')),
      ]) {
        expect(() => s.importCode(bad), throwsFormatException);
      }
      expect(s.completedCourses, {'gpio'});
    });
  });

  group('Quiz', () {
    testWidgets('la dernière question n’est comptée qu’une fois', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();
      final state = AppState(storage: storage, repo: ContentRepository());
      final quiz = Quiz(
        id: 'q',
        title: 'Quiz test',
        level: QuizLevel.beginner,
        questions: [
          QuizQuestion(
            q: 'Bonne réponse ?',
            options: const ['Non', 'Oui', 'Peut-être'],
            answer: 1,
            explanation: '',
          ),
        ],
      );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: state,
          child: MaterialApp(home: QuizSessionScreen(quiz: quiz)),
        ),
      );
      await tester.tap(find.text('Oui'));
      await tester.pump();
      await tester.tap(find.text('Voir le résultat'));
      await tester.pumpAndSettle();
      expect(state.quizResults['q']!.correct, 1);
      expect(find.text('1/1'), findsOneWidget);
    });
  });

  group('Taille du texte', () {
    testWidgets('le réglage fontScale est appliqué à toute l’app', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'ef_font_scale': 1.3});
      final storage = StorageService();
      await storage.init();
      await tester.pumpWidget(
        EmbedForgeApp(storage: storage, repo: ContentRepository()),
      );
      await tester.pump();
      final ctx = tester.element(find.byType(AppShell));
      expect(MediaQuery.textScalerOf(ctx).scale(10), closeTo(13, 0.001));
    });
  });
}
