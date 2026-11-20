import 'package:flutter/material.dart';

import '../data/data_loader.dart';
import '../models/course.dart';
import '../models/secondary.dart';
import '../services/storage_service.dart';

/// État global de l'application : progression, favoris, réglages, badges.
class AppState extends ChangeNotifier {
  final StorageService storage;

  ContentRepository repo;

  ThemeMode theme = ThemeMode.system;
  double fontScale = 1.0;

  AppState({required this.storage, required this.repo}) {
    _restore();
  }

  void _restore() {
    theme = _fromString(storage.themeMode);
    fontScale = storage.fontScale;
  }

  static ThemeMode _fromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // ---------------- settings ----------------
  void setTheme(ThemeMode mode) {
    theme = mode;
    storage.setThemeMode(mode.name);
    notifyListeners();
  }

  void setFontScale(double value) {
    fontScale = value;
    storage.setFontScale(value);
    notifyListeners();
  }

  // ---------------- courses ----------------
  bool isCourseCompleted(String id) => storage.isCourseCompleted(id);

  bool setCourseCompleted(String id, bool value) {
    if (storage.isCourseCompleted(id) == value) return false;
    storage.setCourseCompleted(id, value);
    storage.setLastCourse(id);
    notifyListeners();
    return true;
  }

  bool isChapterCompleted(String globalId) =>
      storage.isChapterCompleted(globalId);

  void setChapterCompleted(String globalId, bool value) {
    if (storage.isChapterCompleted(globalId) == value) return;
    storage.setChapterCompleted(globalId, value);
    notifyListeners();
  }

  int get completedCoursesCount => storage.completedCourses.length;

  int completedInLevel(int level) {
    return repo.courses
        .where((c) => c.level == level && storage.isCourseCompleted(c.id))
        .length;
  }

  int get totalCourses => repo.courses.length;

  int totalInLevel(int level) =>
      repo.courses.where((c) => c.level == level).length;

  double get progress =>
      totalCourses == 0 ? 0 : completedCoursesCount / totalCourses;

  Course? get lastCourse =>
      storage.lastCourse != null ? repo.course(storage.lastCourse!) : null;

  // ---------------- projects ----------------
  bool isProjectCompleted(String id) => storage.isProjectCompleted(id);

  void toggleProjectCompleted(String id) {
    final on = !storage.isProjectCompleted(id);
    storage.setProjectCompleted(id, on);
    notifyListeners();
  }

  int get completedProjectsCount => storage.completedProjects.length;

  // ---------------- roadmap ----------------
  bool hasRoadmapSkill(String id) => storage.roadmapSkills.contains(id);

  void toggleRoadmapSkill(String id) {
    storage.toggleRoadmapSkill(id);
    notifyListeners();
  }

  // ---------------- labs ----------------
  bool isLabUsed(String id) => storage.labsUsed.contains(id);

  void markLabUsed(String id) {
    if (storage.labsUsed.contains(id)) return;
    storage.markLabUsed(id);
    notifyListeners();
  }

  int get labsUsedCount => storage.labsUsed.length;

  // ---------------- quizzes ----------------
  Map<String, QuizScore> get quizResults => storage.quizResults;

  /// Meilleur score aux quiz de niveau (les quiz de module, plus courts,
  /// ne comptent pas pour le badge « Maître du quiz »).
  double get bestQuizRatio {
    double maxRatio = 0;
    quizResults.forEach((id, s) {
      if (id.startsWith(Quiz.modulePrefix)) return;
      if (s.ratio > maxRatio) maxRatio = s.ratio;
    });
    return maxRatio;
  }

  void saveQuizScore(String id, int correct, int total) {
    storage.saveQuizScore(id, correct, total);
    notifyListeners();
  }

  // ---------------- favorites ----------------
  bool isFavorite(String type, String id) => storage.isFavorite(type, id);

  void toggleFavorite(String type, String id) {
    storage.toggleFavorite(type, id);
    notifyListeners();
  }

  Set<String> get favorites => storage.favorites;

  // ---------------- badges ----------------
  List<BadgeDef> get earnedBadges {
    final result = <BadgeDef>[];
    for (final b in repo.badges) {
      if (_isBadgeEarned(b)) result.add(b);
    }
    return result;
  }

  bool _isBadgeEarned(BadgeDef b) {
    switch (b.id) {
      case 'hello_linux':
        return storage.isCourseCompleted('intro_linux');
      case 'terminal_rookie':
        return storage.isCourseCompleted('linux_commands');
      case 'bash_apprentice':
        return storage.isCourseCompleted('bash_intro') ||
            storage.isCourseCompleted('bash_advanced');
      case 'c_apprentice':
        return storage.isCourseCompleted('c_basics') ||
            storage.isCourseCompleted('c_advanced');
      case 'pointer_master':
        return storage.isCourseCompleted('c_advanced');
      case 'gpio_explorer':
        return storage.isCourseCompleted('gpio');
      case 'serial_hacker':
        return storage.isCourseCompleted('uart');
      case 'i2c_explorer':
        return storage.isCourseCompleted('i2c');
      case 'arm_explorer':
        return storage.isCourseCompleted('cpu_architectures');
      case 'kernel_explorer':
        return storage.isCourseCompleted('kernel_linux');
      case 'driver_apprentice':
        return storage.isCourseCompleted('linux_drivers');
      case 'buildroot_builder':
        return storage.isCourseCompleted('buildroot');
      case 'yocto_apprentice':
        return storage.isCourseCompleted('yocto');
      case 'quiz_master':
        return bestQuizRatio >= 0.8;
      case 'project_builder':
        return completedProjectsCount >= 3;
      case 'embedded_developer':
        return completedCoursesCount >= 12 && completedProjectsCount >= 3;
      default:
        return false;
    }
  }

  // ---------------- level / stats ----------------
  String get rankLabel {
    final total = completedCoursesCount;
    if (total >= 26) return 'Expert embarqué';
    if (total >= 20) return 'Avancé';
    if (total >= 12) return 'Intermédiaire';
    if (total >= 5) return 'Débutant';
    return 'Novice';
  }

  int get rankLevel {
    final total = completedCoursesCount;
    if (total >= 26) return 5;
    if (total >= 20) return 4;
    if (total >= 12) return 3;
    if (total >= 5) return 2;
    return 1;
  }

  int get completedMinutes {
    var minutes = 0;
    for (final c in repo.courses) {
      if (storage.isCourseCompleted(c.id)) minutes += c.totalMinutes;
    }
    return minutes;
  }

  int get totalMinutes {
    var minutes = 0;
    for (final c in repo.courses) {
      minutes += c.totalMinutes;
    }
    return minutes;
  }

  // ---------------- export / import ----------------
  String exportProgress() => storage.exportCode();

  /// Lève [FormatException] si le code est invalide (rien n'est modifié).
  void importProgress(String code) {
    storage.importCode(code);
    _restore();
    notifyListeners();
  }

  // ---------------- reset ----------------
  void resetProgress() {
    storage.resetAll();
    notifyListeners();
  }
}
