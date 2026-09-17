class LevelProgress {
  final int levelId;
  final int stars;
  final bool completed;
  final bool unlocked;
  final double accuracy;
  final int wordsAttempted;
  final int wordsCorrect;

  LevelProgress({
    required this.levelId,
    this.stars = 0,
    this.completed = false,
    this.unlocked = false,
    this.accuracy = 0,
    this.wordsAttempted = 0,
    this.wordsCorrect = 0,
  });

  LevelProgress copyWith({
    int? stars,
    bool? completed,
    bool? unlocked,
    double? accuracy,
    int? wordsAttempted,
    int? wordsCorrect,
  }) {
    return LevelProgress(
      levelId: levelId,
      stars: stars ?? this.stars,
      completed: completed ?? this.completed,
      unlocked: unlocked ?? this.unlocked,
      accuracy: accuracy ?? this.accuracy,
      wordsAttempted: wordsAttempted ?? this.wordsAttempted,
      wordsCorrect: wordsCorrect ?? this.wordsCorrect,
    );
  }

  Map<String, dynamic> toJson() => {
    'levelId': levelId,
    'stars': stars,
    'completed': completed,
    'unlocked': unlocked,
    'accuracy': accuracy,
    'wordsAttempted': wordsAttempted,
    'wordsCorrect': wordsCorrect,
  };

  factory LevelProgress.fromJson(Map<String, dynamic> json) => LevelProgress(
    levelId: json['levelId'] as int,
    stars: json['stars'] as int? ?? 0,
    completed: json['completed'] as bool? ?? false,
    unlocked: json['unlocked'] as bool? ?? false,
    accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
    wordsAttempted: json['wordsAttempted'] as int? ?? 0,
    wordsCorrect: json['wordsCorrect'] as int? ?? 0,
  );
}
