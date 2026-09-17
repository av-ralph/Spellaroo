class Profile {
  final String id;
  final String nickname;
  final int? gradeLevel;
  final int coins;
  final String? characterKey;
  final bool tutorialCompleted;
  final bool soundOn;
  final bool musicOn;
  final bool effectsOn;
  final String? parentPinHash;

  Profile({
    required this.id,
    required this.nickname,
    this.gradeLevel,
    this.coins = 0,
    this.characterKey,
    this.tutorialCompleted = false,
    this.soundOn = true,
    this.musicOn = true,
    this.effectsOn = true,
    this.parentPinHash,
  });

  Profile copyWith({
    String? nickname,
    int? gradeLevel,
    int? coins,
    String? characterKey,
    bool? tutorialCompleted,
    bool? soundOn,
    bool? musicOn,
    bool? effectsOn,
    String? parentPinHash,
  }) {
    return Profile(
      id: id,
      nickname: nickname ?? this.nickname,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      coins: coins ?? this.coins,
      characterKey: characterKey ?? this.characterKey,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      soundOn: soundOn ?? this.soundOn,
      musicOn: musicOn ?? this.musicOn,
      effectsOn: effectsOn ?? this.effectsOn,
      parentPinHash: parentPinHash ?? this.parentPinHash,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'gradeLevel': gradeLevel,
    'coins': coins,
    'characterKey': characterKey,
    'tutorialCompleted': tutorialCompleted,
    'soundOn': soundOn,
    'musicOn': musicOn,
    'effectsOn': effectsOn,
    'parentPinHash': parentPinHash,
  };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    nickname: json['nickname'] as String,
    gradeLevel: json['gradeLevel'] as int?,
    coins: json['coins'] as int? ?? 0,
    characterKey: json['characterKey'] as String?,
    tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
    soundOn: json['soundOn'] as bool? ?? true,
    musicOn: json['musicOn'] as bool? ?? true,
    effectsOn: json['effectsOn'] as bool? ?? true,
    parentPinHash: json['parentPinHash'] as String?,
  );
}
