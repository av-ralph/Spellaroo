class InventoryEntry {
  final int itemId;
  final bool equipped;

  InventoryEntry({required this.itemId, this.equipped = false});

  InventoryEntry copyWith({bool? equipped}) {
    return InventoryEntry(itemId: itemId, equipped: equipped ?? this.equipped);
  }

  Map<String, dynamic> toJson() => {'itemId': itemId, 'equipped': equipped};

  factory InventoryEntry.fromJson(Map<String, dynamic> json) => InventoryEntry(
    itemId: json['itemId'] as int,
    equipped: json['equipped'] as bool? ?? false,
  );
}
