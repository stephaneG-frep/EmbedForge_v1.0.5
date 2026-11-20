import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course.dart';
import '../models/secondary.dart';
import '../services/crash_reporter.dart';

/// Charge tous les contenus JSON depuis les assets (fonctionne hors-ligne).
///
/// Robustesse : un fichier illisible ou une entrée mal formée est ignoré(e)
/// et consigné(e) dans le journal, sans jamais vider le reste du contenu.
/// (Les erreurs de cast `as String` sont des `TypeError`, pas des
/// `Exception` : on attrape donc tout.)
class DataLoader {
  static Future<String> _loadString(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      CrashReporter.log('DATA_MISSING $path : $e');
      return '';
    }
  }

  static Future<List<Map<String, dynamic>>> _loadMaps(String path) async {
    final raw = await _loadString(path);
    if (raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      return decoded is List
          ? decoded.whereType<Map<String, dynamic>>().toList()
          : decoded is Map<String, dynamic>
          ? [decoded]
          : <Map<String, dynamic>>[];
    } catch (e) {
      CrashReporter.log('DATA_INVALID_JSON $path : $e');
      return [];
    }
  }

  /// Convertit chaque entrée indépendamment ; les invalides sont écartées.
  static List<T> parseAll<T>(
    List<Map<String, dynamic>> maps,
    T Function(Map<String, dynamic>) fromJson,
    String source,
  ) {
    final out = <T>[];
    for (var i = 0; i < maps.length; i++) {
      try {
        out.add(fromJson(maps[i]));
      } catch (e) {
        CrashReporter.log(
          'DATA_BAD_ENTRY $source #$i id=${maps[i]['id'] ?? '?'} : $e',
        );
      }
    }
    return out;
  }

  static Future<List<Course>> loadCourses() async {
    final manifest = await _loadMaps('assets/data/courses/manifest.json');
    final files = manifest
        .map((m) => m['file'] as String? ?? '')
        .where((f) => f.isNotEmpty)
        .toList();
    final loaded = await Future.wait(
      files.map((f) => _loadMaps('assets/data/courses/$f')),
    );
    final courses = <Course>[];
    for (var i = 0; i < loaded.length; i++) {
      courses.addAll(parseAll(loaded[i], Course.fromJson, files[i]));
    }
    return courses;
  }

  static Future<List<CommandInfo>> loadCommands() async {
    final maps = await _loadMaps('assets/data/commands/commands.json');
    return parseAll(maps, CommandInfo.fromJson, 'commands/commands.json');
  }

  static Future<List<Quiz>> loadQuizzes() async {
    final maps = await _loadMaps('assets/data/quizzes/quizzes.json');
    return parseAll(maps, Quiz.fromJson, 'quizzes/quizzes.json');
  }

  static Future<List<Quiz>> loadModuleQuizzes() async {
    final maps = await _loadMaps('assets/data/quizzes/module_quizzes.json');
    return parseAll(maps, Quiz.fromJson, 'quizzes/module_quizzes.json');
  }

  static Future<List<Project>> loadProjects() async {
    final maps = await _loadMaps('assets/data/projects/projects.json');
    return parseAll(maps, Project.fromJson, 'projects/projects.json');
  }

  static Future<List<GlossaryEntry>> loadGlossary() async {
    final maps = await _loadMaps('assets/data/glossary/glossary.json');
    return parseAll(maps, GlossaryEntry.fromJson, 'glossary/glossary.json');
  }

  static Future<List<CheatSheet>> loadCheatSheets() async {
    final maps = await _loadMaps('assets/data/cheat_sheets/cheat_sheets.json');
    return parseAll(
      maps,
      CheatSheet.fromJson,
      'cheat_sheets/cheat_sheets.json',
    );
  }

  static Future<List<RoadmapStep>> loadRoadmap() async {
    final maps = await _loadMaps('assets/data/roadmap/roadmap.json');
    return parseAll(maps, RoadmapStep.fromJson, 'roadmap/roadmap.json');
  }

  static Future<List<BadgeDef>> loadBadges() async {
    final maps = await _loadMaps('assets/data/badges/badges.json');
    return parseAll(maps, BadgeDef.fromJson, 'badges/badges.json');
  }
}

/// Dépôt qui garde en mémoire tous les contenus chargés une fois.
class ContentRepository {
  List<Course> courses = [];
  List<CommandInfo> commands = [];
  List<Quiz> quizzes = [];

  /// Un quiz court par module, proposé sur la page du module.
  List<Quiz> moduleQuizzes = [];
  List<Project> projects = [];
  List<GlossaryEntry> glossary = [];
  List<CheatSheet> cheatSheets = [];
  List<RoadmapStep> roadmap = [];
  List<BadgeDef> badges = [];

  bool get loaded => badges.isNotEmpty;

  Future<void> load() async {
    final results = await Future.wait([
      DataLoader.loadCourses(),
      DataLoader.loadCommands(),
      DataLoader.loadQuizzes(),
      DataLoader.loadProjects(),
      DataLoader.loadGlossary(),
      DataLoader.loadCheatSheets(),
      DataLoader.loadRoadmap(),
      DataLoader.loadBadges(),
      DataLoader.loadModuleQuizzes(),
    ]);
    courses = results[0] as List<Course>;
    commands = results[1] as List<CommandInfo>;
    quizzes = results[2] as List<Quiz>;
    projects = results[3] as List<Project>;
    glossary = results[4] as List<GlossaryEntry>;
    cheatSheets = results[5] as List<CheatSheet>;
    roadmap = results[6] as List<RoadmapStep>;
    badges = results[7] as List<BadgeDef>;
    moduleQuizzes = results[8] as List<Quiz>;
  }

  Quiz? moduleQuiz(String courseId) {
    for (final q in moduleQuizzes) {
      if (q.course == courseId) return q;
    }
    return null;
  }

  /// Titre d'un quiz (de niveau ou de module) à partir de son identifiant.
  String quizTitle(String id) {
    for (final q in [...quizzes, ...moduleQuizzes]) {
      if (q.id == id) return q.title;
    }
    return id;
  }

  Course? course(String id) {
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  CommandInfo? command(String name) {
    for (final c in commands) {
      if (c.name == name) return c;
    }
    return null;
  }

  String courseTitle(String id) => course(id)?.title ?? id;

  /// Texte de recherche unifié pour la recherche globale.
  String courseSearchText(Course c) {
    final buf = StringBuffer('${c.title} ${c.summary} ');
    for (final o in c.objectives) {
      buf.write('$o ');
    }
    for (final ch in c.chapters) {
      buf.write('${ch.title} ');
      for (final s in ch.sections) {
        buf.write('${s.title ?? ''} ${s.body ?? ''} ${s.term ?? ''} ');
      }
    }
    return buf.toString();
  }
}
