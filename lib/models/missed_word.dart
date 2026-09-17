class MissedWord {
  final int wordId;
  final int missCount;

  MissedWord({required this.wordId, this.missCount = 1});

  MissedWord copyWith({int? missCount}) {
    return MissedWord(wordId: wordId, missCount: missCount ?? this.missCount);
  }

  Map<String, dynamic> toJson() => {'wordId': wordId, 'missCount': missCount};

  factory MissedWord.fromJson(Map<String, dynamic> json) => MissedWord(
    wordId: json['wordId'] as int,
    missCount: json['missCount'] as int? ?? 1,
  );
}
