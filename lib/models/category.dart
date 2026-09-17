class GameCategory {
  final int id;
  final String name;
  final String icon;

  GameCategory({required this.id, required this.name, required this.icon});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'icon': icon};

  factory GameCategory.fromJson(Map<String, dynamic> json) => GameCategory(
    id: json['id'] as int,
    name: json['name'] as String,
    icon: json['icon'] as String,
  );
}
