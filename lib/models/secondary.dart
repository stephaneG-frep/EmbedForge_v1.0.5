/// Modèles secondaires : projets, glossaire, cheat-sheets, roadmap, badges.
library;

class Project {
  final String id;
  final String title;
  final String difficulty; // Debutant / Intermediaire / Avance
  final String category;
  final String icon;
  final String summary;
  final List<String> objectives;
  final List<ProjectStep> steps;
  final List<String> skills;
  final bool isFinal;

  Project({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.category,
    required this.icon,
    required this.summary,
    required this.objectives,
    required this.steps,
    required this.skills,
    this.isFinal = false,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      difficulty: json['difficulty'] as String? ?? 'Intermédiaire',
      category: json['category'] as String? ?? 'GPIO',
      icon: json['icon'] as String? ?? 'bolt',
      summary: json['summary'] as String? ?? '',
      objectives: (json['objectives'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      steps: (json['steps'] as List? ?? [])
          .map((e) => ProjectStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List? ?? []).map((e) => e.toString()).toList(),
      isFinal: json['final'] as bool? ?? false,
    );
  }
}

class ProjectStep {
  final String title;
  final String? body;
  final String? code;
  final String? output;

  ProjectStep({required this.title, this.body, this.code, this.output});

  factory ProjectStep.fromJson(Map<String, dynamic> json) {
    return ProjectStep(
      title: json['title'] as String,
      body: json['body'] as String?,
      code: json['code'] as String?,
      output: json['output'] as String?,
    );
  }
}

class GlossaryEntry {
  final String term;
  final String category;
  final String definition;

  GlossaryEntry({
    required this.term,
    required this.category,
    required this.definition,
  });

  factory GlossaryEntry.fromJson(Map<String, dynamic> json) {
    return GlossaryEntry(
      term: json['term'] as String,
      category: json['category'] as String? ?? 'Général',
      definition: json['definition'] as String? ?? '',
    );
  }
}

class CheatSection {
  final String title;
  final List<List<String>> entries; // [cmd, desc]

  CheatSection({required this.title, required this.entries});

  factory CheatSection.fromJson(Map<String, dynamic> json) {
    return CheatSection(
      title: json['title'] as String,
      entries: (json['entries'] as List? ?? [])
          .map((e) => (e as List).map((x) => x.toString()).toList())
          .toList(),
    );
  }
}

class CheatSheet {
  final String id;
  final String title;
  final String icon;
  final String accent;
  final String intro;
  final List<CheatSection> sections;

  CheatSheet({
    required this.id,
    required this.title,
    required this.icon,
    required this.accent,
    required this.intro,
    required this.sections,
  });

  factory CheatSheet.fromJson(Map<String, dynamic> json) {
    return CheatSheet(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? 'code',
      accent: json['accent'] as String? ?? 'blue',
      intro: json['intro'] as String? ?? '',
      sections: (json['sections'] as List? ?? [])
          .map((e) => CheatSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RoadmapStep {
  final String id;
  final String title;
  final int level;
  final String description;
  final String? course;
  final List<String> skills;

  RoadmapStep({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
    this.course,
    this.skills = const [],
  });

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      id: json['id'] as String,
      title: json['title'] as String,
      level: (json['level'] as num?)?.toInt() ?? 1,
      description: json['description'] as String? ?? '',
      course: json['course'] as String?,
      skills: (json['skills'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class BadgeDef {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String how;

  BadgeDef({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.how,
  });

  factory BadgeDef.fromJson(Map<String, dynamic> json) {
    return BadgeDef(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? 'star',
      description: json['description'] as String? ?? '',
      how: json['how'] as String? ?? '',
    );
  }
}
