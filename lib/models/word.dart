class Word {
  final int id;
  final String word;
  final String category;
  final String difficulty;
  final String? definition;
  final String? exampleSentence;
  final String? topic;

  Word({
    required this.id,
    required this.word,
    required this.category,
    required this.difficulty,
    this.definition,
    this.exampleSentence,
    this.topic,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word,
    'category': category,
    'difficulty': difficulty,
    'definition': definition,
    'exampleSentence': exampleSentence,
    'topic': topic,
  };

  factory Word.fromJson(Map<String, dynamic> json) => Word(
    id: json['id'] as int,
    word: json['word'] as String,
    category: json['category'] as String,
    difficulty: json['difficulty'] as String,
    definition: json['definition'] as String?,
    exampleSentence: json['exampleSentence'] as String?,
    topic: json['topic'] as String?,
  );
}
