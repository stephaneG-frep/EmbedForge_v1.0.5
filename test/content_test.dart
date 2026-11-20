import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:embedforge/data/data_loader.dart';
import 'package:embedforge/models/course.dart';
import 'package:embedforge/models/secondary.dart';

List<Map<String, dynamic>> _file(String rel) {
  final f = File('assets/data/$rel');
  expect(f.existsSync(), isTrue, reason: 'asset manquant : assets/data/$rel');
  final decoded = jsonDecode(f.readAsStringSync());
  if (decoded is List) return decoded.cast<Map<String, dynamic>>();
  if (decoded is Map<String, dynamic>) return [decoded];
  return [];
}

void main() {
  late ContentRepository repo;

  setUpAll(() {
    repo = ContentRepository();
    final manifest = _file('courses/manifest.json');
    repo.courses = [
      for (final m in manifest)
        for (final row in _file('courses/${m['file']}')) Course.fromJson(row),
    ];
    repo.commands = [
      for (final row in _file('commands/commands.json'))
        CommandInfo.fromJson(row),
    ];
    repo.quizzes = [
      for (final row in _file('quizzes/quizzes.json')) Quiz.fromJson(row),
    ];
    repo.projects = [
      for (final row in _file('projects/projects.json')) Project.fromJson(row),
    ];
    repo.glossary = [
      for (final row in _file('glossary/glossary.json'))
        GlossaryEntry.fromJson(row),
    ];
    repo.cheatSheets = [
      for (final row in _file('cheat_sheets/cheat_sheets.json'))
        CheatSheet.fromJson(row),
    ];
    repo.roadmap = [
      for (final row in _file('roadmap/roadmap.json'))
        RoadmapStep.fromJson(row),
    ];
    repo.badges = [
      for (final row in _file('badges/badges.json')) BadgeDef.fromJson(row),
    ];
  });

  test('tous les jeux de données sont complets', () {
    expect(repo.courses, hasLength(31));
    expect(repo.commands.length, greaterThanOrEqualTo(48));
    expect(repo.quizzes, hasLength(4));
    expect(repo.projects, hasLength(11));
    expect(repo.glossary.length, greaterThanOrEqualTo(28));
    expect(repo.cheatSheets, hasLength(12));
    expect(repo.roadmap, hasLength(30));
    expect(repo.badges, hasLength(16));
    expect(repo.loaded, isTrue);
  });

  test('les modules référencés par les badges existent', () {
    const required = [
      'intro_linux',
      'linux_commands',
      'bash_intro',
      'bash_advanced',
      'c_basics',
      'c_advanced',
      'gpio',
      'uart',
      'i2c',
      'cpu_architectures',
      'kernel_linux',
      'linux_drivers',
      'buildroot',
      'yocto',
    ];
    final ids = repo.courses.map((c) => c.id).toSet();
    for (final id in required) {
      expect(ids, contains(id), reason: 'module manquant : $id');
    }
  });

  test('toutes les étapes roadmap pointent vers un module existant', () {
    final ids = repo.courses.map((c) => c.id).toSet();
    for (final step in repo.roadmap) {
      if (step.course != null) {
        expect(ids, contains(step.course), reason: 'étape ${step.id}');
      }
    }
  });

  test('chapitres et sections valides', () {
    var chapters = 0;
    var sections = 0;
    for (final c in repo.courses) {
      expect(c.chapters, isNotEmpty, reason: c.id);
      chapters += c.chapters.length;
      for (final ch in c.chapters) {
        expect(ch.sections, isNotEmpty, reason: '${c.id}/${ch.id}');
        sections += ch.sections.length;
      }
    }
    expect(chapters, greaterThanOrEqualTo(90));
    expect(sections, greaterThanOrEqualTo(400));
  });

  test('chaque quiz a des réponses cohérentes', () {
    for (final q in repo.quizzes) {
      expect(q.questions, hasLength(8));
      for (final qu in q.questions) {
        expect(qu.options, hasLength(4));
        expect(qu.answer, inInclusiveRange(0, qu.options.length - 1));
      }
    }
  });

  test('badges require defs', () {
    for (final b in repo.badges) {
      expect(b.name, isNotEmpty);
      expect(b.how, isNotEmpty);
    }
  });

  test('projets : 10 mini-projets + 1 final', () {
    expect(repo.projects.where((p) => p.isFinal), hasLength(1));
    expect(repo.projects.where((p) => !p.isFinal), hasLength(10));
  });
}
