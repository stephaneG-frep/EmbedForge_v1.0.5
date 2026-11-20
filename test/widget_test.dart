import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:embedforge/core/formatters.dart';
import 'package:embedforge/data/data_loader.dart';
import 'package:embedforge/models/course.dart';
import 'package:embedforge/models/secondary.dart';
import 'package:embedforge/services/storage_service.dart';
import 'package:embedforge/state/app_state.dart';

Course _course(String id, {int level = 1}) => Course(
  id: id,
  title: id,
  level: level,
  category: 'fundamentals',
  accent: 'blue',
  icon: 'memory',
  durationMinutes: 10,
  summary: '',
  objectives: const [],
  chapters: const [],
);

ContentRepository _repo({
  List<Course> courses = const [],
  List<BadgeDef> badges = const [],
}) {
  final repo = ContentRepository();
  repo.courses = List.of(courses);
  repo.badges = List.of(badges);
  return repo;
}

Future<StorageService> _storage() async {
  SharedPreferences.setMockInitialValues({});
  final s = StorageService();
  await s.init();
  return s;
}

void main() {
  group('NumberTools', () {
    test('binaire sur 8 bits', () {
      expect(NumberTools.toBinary(5), '00000101');
      expect(NumberTools.toBinary(0), '00000000');
      expect(NumberTools.toBinary(255), '11111111');
    });

    test('hexadécimal', () {
      expect(NumberTools.toHex(255), '0xFF');
      expect(NumberTools.toHex(0x1F, digits: 2), '0x1F');
    });

    test('fromBinary', () {
      expect(NumberTools.fromBinary('1010'), 10);
      expect(NumberTools.fromBinary('zzz'), 0);
    });

    test('masque MSB', () {
      expect(NumberTools.msbMask(8), 128);
      expect(NumberTools.msbMask(16), 32768);
    });

    test('puissance de deux suivante', () {
      expect(NumberTools.nextPowerOfTwo(5), 8);
      expect(NumberTools.nextPowerOfTwo(8), 8);
    });
  });

  group('normalizeSearch', () {
    test('insensible aux accents', () {
      expect(normalizeSearch('Café').contains(normalizeSearch('cafe')), isTrue);
      expect(normalizeSearch('café'), normalizeSearch('café'));
      expect(normalizeSearch('Étude des bus').contains('etude'), isTrue);
    });

    test('minuscules', () {
      expect(normalizeSearch('Salut'), 'salut');
    });
  });

  group('slugify', () {
    test('slug français', () {
      expect(slugify('Bonjour ! Le monde'), 'bonjour_le_monde');
      expect(slugify('C  \\ C++'), 'c_c');
    });
  });

  group('clamp / easing', () {
    test('clamp01 borne', () {
      expect(clamp01(-1), 0);
      expect(clamp01(2), 1);
      expect(clamp01(0.5), 0.5);
    });

    test('easeOutCubic monotone', () {
      expect(easeOutCubic(0), 0);
      expect(easeOutCubic(1), 1);
      expect(easeOutCubic(0.5) > 0.5, isTrue);
    });
  });

  group('Course.fromJson', () {
    test('parse complet avec chapitres', () {
      final course = Course.fromJson({
        'id': 'linux_commands',
        'title': 'Les commandes Linux',
        'level': 1,
        'accent': 'green',
        'icon': 'terminal',
        'duration': 30,
        'summary': 'Résumé',
        'objectives': ['Savoir naviguer'],
        'chapters': [
          {
            'id': 'navigation',
            'title': 'Naviguer',
            'duration': 15,
            'sections': [
              {'type': 'text', 'body': 'Contenu'},
              {'type': 'code', 'code': 'ls -la', 'lang': 'bash'},
            ],
          },
        ],
      });

      expect(course.id, 'linux_commands');
      expect(course.level, 1);
      expect(course.chapters, hasLength(1));
      expect(course.totalMinutes, 15);
      expect(course.chapters.first.sections, hasLength(2));
      expect(course.chapters.first.sections[1].type, SectionType.code);
    });
  });

  group('StorageService', () {
    test('cycles cours / chapitres / projets', () async {
      final s = await _storage();

      expect(s.isCourseCompleted('a'), isFalse);
      s.setCourseCompleted('a', true);
      expect(s.isCourseCompleted('a'), isTrue);
      expect(s.isProjectCompleted('p1'), isFalse);
      s.setProjectCompleted('p1', true);
      expect(s.isProjectCompleted('p1'), isTrue);

      s.setChapterCompleted('a/ch1', true);
      expect(s.isChapterCompleted('a/ch1'), isTrue);
    });

    test('favoris', () async {
      final s = await _storage();
      s.toggleFavorite('command', 'ls');
      expect(s.isFavorite('command', 'ls'), isTrue);
      s.toggleFavorite('command', 'ls');
      expect(s.isFavorite('command', 'ls'), isFalse);
    });

    test('quiz avec score', () async {
      final s = await _storage();
      s.saveQuizScore('q1', 8, 10);
      expect(s.quizResults['q1']!.correct, 8);
      expect(s.quizResults['q1']!.ratio, closeTo(0.8, 0.001));
    });

    test('lastCourse', () async {
      final s = await _storage();
      s.setLastCourse('intro');
      expect(s.lastCourse, 'intro');
    });
  });

  group('AppState', () {
    test('progression et titres', () async {
      final storage = await _storage();
      final repo = _repo(courses: [_course('a'), _course('b'), _course('c')]);
      final state = AppState(storage: storage, repo: repo);

      expect(state.progress, 0);
      expect(state.rankLabel, 'Novice');
      state.setCourseCompleted('b', true);
      expect(state.progress, closeTo(1 / 3, 0.001));
      expect(state.completedMinutes, 0);
    });

    test('badges quiz_master', () async {
      final storage = await _storage();
      final repo = _repo(
        badges: [
          BadgeDef(
            id: 'quiz_master',
            name: 'As du quiz',
            icon: 'star',
            description: '',
            how: '',
          ),
        ],
      );
      final state = AppState(storage: storage, repo: repo);

      expect(state.earnedBadges, isEmpty);
      state.saveQuizScore('q1', 1, 10);
      expect(
        state.earnedBadges.map((b) => b.id),
        isNot(contains('quiz_master')),
      );
      state.saveQuizScore('q2', 9, 10);
      expect(state.earnedBadges.map((b) => b.id), contains('quiz_master'));
    });

    test('badge hello_linux', () async {
      final storage = await _storage();
      final repo = _repo(
        badges: [
          BadgeDef(
            id: 'hello_linux',
            name: 'Hello Linux',
            icon: 'star',
            description: '',
            how: '',
          ),
        ],
      );
      final state = AppState(storage: storage, repo: repo);

      expect(state.earnedBadges, isEmpty);
      state.setCourseCompleted('intro_linux', true);
      expect(state.earnedBadges.map((b) => b.id), contains('hello_linux'));
    });

    test('roadmap', () async {
      final storage = await _storage();
      final state = AppState(storage: storage, repo: _repo());
      expect(state.hasRoadmapSkill('x'), isFalse);
      state.toggleRoadmapSkill('x');
      expect(state.hasRoadmapSkill('x'), isTrue);
      state.toggleRoadmapSkill('x');
      expect(state.hasRoadmapSkill('x'), isFalse);
    });

    test('resetProgression', () async {
      final storage = await _storage();
      final state = AppState(storage: storage, repo: _repo());
      state.setCourseCompleted('a', true);
      state.toggleFavorite('command', 'ls');
      state.resetProgress();
      expect(state.completedCoursesCount, 0);
      expect(state.favorites, isEmpty);
    });
  });
}
