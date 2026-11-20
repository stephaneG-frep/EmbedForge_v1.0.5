import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistance locale (SharedPreferences). Aucun besoin d'Internet.
class StorageService {
  static const _kCompletedCourses = 'ef_completed_courses';
  static const _kCompletedChapters = 'ef_completed_chapters';
  static const _kCompletedProjects = 'ef_completed_projects';
  static const _kRoadmapSkills = 'ef_roadmap_skills';
  static const _kFavorites = 'ef_favorites';
  static const _kQuizResults = 'ef_quiz_results';
  static const _kLastCourse = 'ef_last_course';
  static const _kTheme = 'ef_theme';
  static const _kFontScale = 'ef_font_scale';
  static const _kSeen = 'ef_seen_commands';
  static const _kLabsUsed = 'ef_labs_used';

  static const _kVersion = 'ef_data_version';
  static const _version = 1;

  SharedPreferences? _prefs;

  /// Repli en mémoire si SharedPreferences est indisponible (ou si init()
  /// n'a pas abouti) : l'application reste utilisable, seule la persistance
  /// entre deux lancements est perdue.
  final Map<String, Object> _memory = {};

  /// Vrai si la progression est réellement enregistrée sur l'appareil.
  bool get isPersistent => _prefs != null;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final v = _prefs!.getInt(_kVersion) ?? 0;
    if (v != _version) {
      // Rotation de version : on garde simplement la cohérence interne.
      await _prefs!.setInt(_kVersion, _version);
    }
  }

  // ---- accès bas niveau (persistant ou mémoire) ----
  String? _getString(String key) {
    final p = _prefs;
    if (p == null) return _memory[key] as String?;
    return p.getString(key);
  }

  List<String>? _getList(String key) {
    final p = _prefs;
    if (p == null) return _memory[key] as List<String>?;
    return p.getStringList(key);
  }

  double? _getDouble(String key) {
    final p = _prefs;
    if (p == null) return _memory[key] as double?;
    return p.getDouble(key);
  }

  void _set(String key, Object value) {
    final p = _prefs;
    if (p == null) {
      _memory[key] = value;
      return;
    }
    if (value is List<String>) {
      p.setStringList(key, value);
    } else if (value is String) {
      p.setString(key, value);
    } else if (value is double) {
      p.setDouble(key, value);
    } else if (value is int) {
      p.setInt(key, value);
    } else if (value is bool) {
      p.setBool(key, value);
    }
  }

  void _remove(String key) {
    _memory.remove(key);
    _prefs?.remove(key);
  }

  // ---- helpers ----
  List<String> getList(String key) => _getList(key) ?? [];

  void _saveList(String key, List<String> value) => _set(key, value);

  // ---- user data ----
  Set<String> get completedCourses => (getList(_kCompletedCourses)).toSet();

  bool isCourseCompleted(String id) => completedCourses.contains(id);

  void setCourseCompleted(String id, bool value) {
    final set = Set<String>.from(getList(_kCompletedCourses));
    if (value) {
      set.add(id);
    } else {
      set.remove(id);
    }
    _saveList(_kCompletedCourses, set.toList());
  }

  Set<String> get completedChapters => (getList(_kCompletedChapters)).toSet();

  bool isChapterCompleted(String globalId) =>
      completedChapters.contains(globalId);

  void setChapterCompleted(String globalId, bool value) {
    final set = Set<String>.from(getList(_kCompletedChapters));
    if (value) {
      set.add(globalId);
    } else {
      set.remove(globalId);
    }
    _saveList(_kCompletedChapters, set.toList());
  }

  Set<String> get completedProjects => (getList(_kCompletedProjects)).toSet();

  bool isProjectCompleted(String id) => completedProjects.contains(id);

  void setProjectCompleted(String id, bool value) {
    final set = Set<String>.from(getList(_kCompletedProjects));
    if (value) {
      set.add(id);
    } else {
      set.remove(id);
    }
    _saveList(_kCompletedProjects, set.toList());
  }

  Set<String> get roadmapSkills => (getList(_kRoadmapSkills)).toSet();

  void toggleRoadmapSkill(String id) {
    final set = Set<String>.from(getList(_kRoadmapSkills));
    if (!set.add(id)) {
      set.remove(id);
    }
    _saveList(_kRoadmapSkills, set.toList());
  }

  Set<String> get labsUsed => (getList(_kLabsUsed)).toSet();

  void markLabUsed(String id) {
    final set = Set<String>.from(getList(_kLabsUsed));
    if (set.add(id)) {
      _saveList(_kLabsUsed, set.toList());
    }
  }

  Set<String> get favorites => (getList(_kFavorites)).toSet();

  bool isFavorite(String type, String id) => favorites.contains('$type:$id');

  void toggleFavorite(String type, String id) {
    final key = '$type:$id';
    final set = Set<String>.from(getList(_kFavorites));
    if (!set.add(key)) {
      set.remove(key);
    }
    _saveList(_kFavorites, set.toList());
  }

  // ---- quiz ----
  Map<String, QuizScore> get quizResults {
    final raw = _getString(_kQuizResults);
    final map = <String, QuizScore>{};
    if (raw == null || raw.isEmpty) return map;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded.forEach((k, v) {
        final m = v as Map<String, dynamic>;
        map[k] = QuizScore(
          correct: (m['correct'] as num).toInt(),
          total: (m['total'] as num).toInt(),
        );
      });
    } catch (_) {}
    return map;
  }

  void saveQuizScore(String id, int correct, int total) {
    final map = quizResults;
    map[id] = QuizScore(correct: correct, total: total);
    _set(
      _kQuizResults,
      jsonEncode(
        map.map(
          (k, v) => MapEntry(k, {'correct': v.correct, 'total': v.total}),
        ),
      ),
    );
  }

  String? get lastCourse => _getString(_kLastCourse);

  void setLastCourse(String id) => _set(_kLastCourse, id);

  // ---- settings ----
  String get themeMode => _getString(_kTheme) ?? 'system';

  void setThemeMode(String mode) => _set(_kTheme, mode);

  double get fontScale => _getDouble(_kFontScale) ?? 1.0;

  void setFontScale(double value) => _set(_kFontScale, value);

  // ---- export / import ----
  static const exportPrefix = 'EMBEDFORGE1:';

  static const _exportLists = [
    _kCompletedCourses,
    _kCompletedChapters,
    _kCompletedProjects,
    _kRoadmapSkills,
    _kFavorites,
    _kSeen,
    _kLabsUsed,
  ];

  /// Code texte de sauvegarde (préfixe + JSON en base64) : se copie/colle,
  /// survit à une désinstallation ou à un changement d'appareil.
  String exportCode() {
    final data = <String, Object?>{
      'v': 1,
      for (final k in _exportLists) k: getList(k),
      _kQuizResults: _getString(_kQuizResults),
      _kLastCourse: _getString(_kLastCourse),
      _kTheme: _getString(_kTheme),
      _kFontScale: _getDouble(_kFontScale),
    };
    return exportPrefix + base64Encode(utf8.encode(jsonEncode(data)));
  }

  /// Remplace la progression par celle du code. Lève [FormatException] si le
  /// code est invalide — rien n'est alors modifié.
  void importCode(String code) {
    final trimmed = code.trim();
    if (!trimmed.startsWith(exportPrefix)) {
      throw const FormatException('Ce n’est pas un code EmbedForge.');
    }
    final Map<String, dynamic> data;
    try {
      data =
          jsonDecode(
                utf8.decode(
                  base64Decode(trimmed.substring(exportPrefix.length)),
                ),
              )
              as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Code incomplet ou abîmé.');
    }
    if (data['v'] != 1) {
      throw const FormatException('Version de code non prise en charge.');
    }
    // Validation complète AVANT toute écriture.
    final lists = <String, List<String>>{};
    for (final k in _exportLists) {
      final v = data[k];
      if (v != null && v is! List) {
        throw const FormatException('Code invalide.');
      }
      lists[k] = [for (final e in (v as List? ?? const [])) e.toString()];
    }
    final quiz = data[_kQuizResults];
    if (quiz != null) {
      try {
        jsonDecode(quiz as String) as Map<String, dynamic>;
      } catch (_) {
        throw const FormatException('Scores de quiz invalides.');
      }
    }
    final last = data[_kLastCourse];
    final theme = data[_kTheme];
    final font = data[_kFontScale];

    resetAll();
    lists.forEach(_saveList);
    if (quiz is String) _set(_kQuizResults, quiz);
    if (last is String) _set(_kLastCourse, last);
    if (theme is String) _set(_kTheme, theme);
    if (font is num) _set(_kFontScale, font.toDouble().clamp(0.85, 1.3));
  }

  void resetAll() {
    for (final k in [
      _kCompletedCourses,
      _kCompletedChapters,
      _kCompletedProjects,
      _kRoadmapSkills,
      _kFavorites,
      _kQuizResults,
      _kLastCourse,
      _kSeen,
      _kLabsUsed,
    ]) {
      _remove(k);
    }
  }
}

class QuizScore {
  final int correct;
  final int total;

  QuizScore({required this.correct, required this.total});

  double get ratio => total == 0 ? 0 : correct / total;
}
