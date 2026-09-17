class Level {
  final int id;
  final String name;
  final String category;
  final String difficulty;
  final int wordCount;
  final int? requiredCorrect;

  Level({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    this.wordCount = 10,
    this.requiredCorrect,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'difficulty': difficulty,
    'wordCount': wordCount,
    'requiredCorrect': requiredCorrect,
  };

  factory Level.fromJson(Map<String, dynamic> json) => Level(
    id: json['id'] as int,
    name: json['name'] as String,
    category: json['category'] as String,
    difficulty: json['difficulty'] as String,
    wordCount: json['wordCount'] as int? ?? 10,
    requiredCorrect: json['requiredCorrect'] as int?,
  );
}
