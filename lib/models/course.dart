/// Modèles de contenu pédagogique (cours, chapitres, sections).
library;

/// Type d'une section de chapitre.
enum SectionType {
  text,
  code,
  tip,
  warning,
  exercise,
  definition,
  list,
  table,
  quote;

  static SectionType parse(String? raw) {
    switch (raw) {
      case 'code':
        return SectionType.code;
      case 'tip':
        return SectionType.tip;
      case 'warning':
        return SectionType.warning;
      case 'exercise':
        return SectionType.exercise;
      case 'definition':
        return SectionType.definition;
      case 'list':
        return SectionType.list;
      case 'table':
        return SectionType.table;
      case 'quote':
        return SectionType.quote;
      case 'text':
      default:
        return SectionType.text;
    }
  }
}

class ContentSection {
  final SectionType type;
  final String? title;
  final String? body;
  final String? code;
  final String? lang;
  final String? term;
  final String? question;
  final String? answer;
  final List<String>? items;

  /// Table : liste de paires [étiquette, valeur].
  final List<List<String>>? table;

  ContentSection({
    required this.type,
    this.title,
    this.body,
    this.code,
    this.lang,
    this.term,
    this.question,
    this.answer,
    this.items,
    this.table,
  });

  factory ContentSection.fromJson(Map<String, dynamic> json) {
    final type = SectionType.parse(json['type'] as String?);
    List<List<String>>? table;
    if (json['table'] is List) {
      table = (json['table'] as List)
          .map((row) => (row as List).map((e) => e.toString()).toList())
          .toList();
    }
    return ContentSection(
      type: type,
      title: json['title'] as String?,
      body: json['body'] as String?,
      code: json['code'] as String?,
      lang: json['lang'] as String?,
      term: json['term'] as String?,
      question: json['question'] as String?,
      answer: json['answer'] as String?,
      items: json['items'] == null
          ? null
          : (json['items'] as List).map((e) => e.toString()).toList(),
      table: table,
    );
  }
}

class Chapter {
  final String id;
  final String title;
  final int durationMinutes;
  final List<ContentSection> sections;

  Chapter({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.sections,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 15,
      sections: (json['sections'] as List? ?? [])
          .map((e) => ContentSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Course {
  final String id;
  final String title;
  final int level;
  final String category;
  final String accent;
  final String icon;
  final int durationMinutes;
  final String summary;
  final List<String> objectives;
  final List<Chapter> chapters;

  Course({
    required this.id,
    required this.title,
    required this.level,
    required this.category,
    required this.accent,
    required this.icon,
    required this.durationMinutes,
    required this.summary,
    required this.objectives,
    required this.chapters,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      level: (json['level'] as num?)?.toInt() ?? 1,
      category: json['category'] as String? ?? 'fundamentals',
      accent: json['accent'] as String? ?? 'blue',
      icon: json['icon'] as String? ?? 'memory',
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 20,
      summary: json['summary'] as String? ?? '',
      objectives: (json['objectives'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      chapters: (json['chapters'] as List? ?? [])
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get chaptersCount => chapters.length;

  int get totalMinutes => chapters.fold(0, (sum, c) => sum + c.durationMinutes);
}

class CommandInfo {
  final String id;
  final String name;
  final String category;
  final String definition;
  final String? syntax;
  final String? example;
  final String? exampleOutput;
  final List<List<String>> options; // [flag, desc]
  final String? exercise;
  final String? exerciseAnswer;
  final String? challenge;
  final String? challengeAnswer;
  final String? commonError;

  CommandInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.definition,
    this.syntax,
    this.example,
    this.exampleOutput,
    this.options = const [],
    this.exercise,
    this.exerciseAnswer,
    this.challenge,
    this.challengeAnswer,
    this.commonError,
  });

  factory CommandInfo.fromJson(Map<String, dynamic> json) {
    return CommandInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'misc',
      definition: json['definition'] as String? ?? '',
      syntax: json['syntax'] as String?,
      example: json['example'] as String?,
      exampleOutput: json['exampleOutput'] as String?,
      options: (json['options'] as List? ?? [])
          .map((o) => (o as List).map((e) => e.toString()).toList())
          .toList(),
      exercise: json['exercise'] as String?,
      exerciseAnswer: json['exerciseAnswer'] as String?,
      challenge: json['challenge'] as String?,
      challengeAnswer: json['challengeAnswer'] as String?,
      commonError: json['commonError'] as String?,
    );
  }
}

enum QuizLevel { beginner, intermediate, advanced, expert }

QuizLevel parseQuizLevel(String raw) {
  switch (raw) {
    case 'intermediate':
      return QuizLevel.intermediate;
    case 'advanced':
      return QuizLevel.advanced;
    case 'expert':
      return QuizLevel.expert;
    default:
      return QuizLevel.beginner;
  }
}

String quizLevelLabel(QuizLevel l) {
  switch (l) {
    case QuizLevel.beginner:
      return 'Débutant';
    case QuizLevel.intermediate:
      return 'Intermédiaire';
    case QuizLevel.advanced:
      return 'Avancé';
    case QuizLevel.expert:
      return 'Expert';
  }
}

class QuizQuestion {
  final String q;
  final List<String> options;
  final int answer;
  final String explanation;

  QuizQuestion({
    required this.q,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      q: json['q'] as String,
      options: (json['options'] as List).map((e) => e.toString()).toList(),
      answer: (json['answer'] as num).toInt(),
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final QuizLevel level;
  final List<QuizQuestion> questions;

  /// Module associé (quiz de module) ; null pour un quiz de niveau.
  final String? course;

  Quiz({
    required this.id,
    required this.title,
    required this.level,
    required this.questions,
    this.course,
  });

  /// Les quiz de module ont un identifiant préfixé, pour les distinguer des
  /// quiz de niveau (seuls ceux-ci comptent pour le badge « Maître du quiz »).
  static const modulePrefix = 'mq_';
  bool get isModuleQuiz => id.startsWith(modulePrefix);

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      level: parseQuizLevel(json['level'] as String),
      questions: (json['questions'] as List? ?? [])
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      course: json['course'] as String?,
    );
  }
}
