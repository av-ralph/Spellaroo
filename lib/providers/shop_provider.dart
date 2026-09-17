import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'app_provider.dart';

class ShopNotifier extends StateNotifier<void> {
  final Ref ref;

  ShopNotifier(this.ref) : super(null);
  bool _busy = false;

  Future<bool> buyItem(int itemId) async {
    if (_busy) return false;
    _busy = true;
    try {
      final appState = ref.read(appProvider);
      final profile = appState.profile;
      if (profile == null) return false;

      final item = StorageService.getShopItem(itemId);
      if (item == null) return false;

      if (profile.coins < item.price) return false;

      final existing = appState.inventory.where((e) => e.itemId == itemId);
      if (existing.isNotEmpty) return false;

      await StorageService.purchaseItem(itemId);
      await ref.read(appProvider.notifier).spendCoins(item.price);
      await ref.read(appProvider.notifier).refreshProfile();
      return true;
    } finally {
      _busy = false;
    }
  }

  Future<void> equipItem(int itemId, String category) async {
    await StorageService.equipItem(itemId, category);
    await ref.read(appProvider.notifier).refreshProfile();
  }

  Future<void> unequipCategory(String category) async {
    await StorageService.unequipCategory(category);
    await ref.read(appProvider.notifier).refreshProfile();
  }

  bool isOwned(int itemId) {
    final inventory = ref.read(appProvider).inventory;
    return inventory.any((e) => e.itemId == itemId);
  }

  bool isEquipped(int itemId) {
    final inventory = ref.read(appProvider).inventory;
    final entry = inventory.where((e) => e.itemId == itemId);
    return entry.isNotEmpty && entry.first.equipped;
  }
}

final shopProvider = StateNotifierProvider<ShopNotifier, void>((ref) {
  return ShopNotifier(ref);
});
