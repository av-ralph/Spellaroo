class ShopItem {
  final int id;
  final String name;
  final String category;
  final int price;
  final String colorName;
  final String? description;
  final String rarity;
  final String? icon;
  final bool isStarter;

  ShopItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.colorName,
    this.description,
    this.rarity = 'common',
    this.icon,
    this.isStarter = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'colorName': colorName,
    'description': description,
    'rarity': rarity,
    'icon': icon,
    'isStarter': isStarter,
  };

  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
    id: json['id'] as int,
    name: json['name'] as String,
    category: json['category'] as String,
    price: json['price'] as int,
    colorName: json['colorName'] as String,
    description: json['description'] as String?,
    rarity: json['rarity'] as String? ?? 'common',
    icon: json['icon'] as String?,
    isStarter: json['isStarter'] as bool? ?? false,
  );
}
