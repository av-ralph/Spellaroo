import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spellaroo/config/wardrobe_categories.dart';
import 'package:spellaroo/models/profile.dart';
import 'package:spellaroo/providers/app_provider.dart';
import 'package:spellaroo/providers/shop_provider.dart';
import 'package:spellaroo/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Purchases in every category survive restart and character changes',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'spellaroo-shop-',
      );
      Hive.init(directory.path);
      await StorageService.init();
      await StorageService.saveProfile(
        Profile(
          id: 'test',
          nickname: 'Bee',
          coins: 10000,
          characterKey: 'kangaroo',
          soundOn: false,
          musicOn: false,
          effectsOn: false,
        ),
      );
      var container = ProviderContainer();
      try {
        container.read(appProvider);
        await Future<void>.delayed(Duration.zero);
        final catalog = StorageService.allShopItems;
        expect(catalog.map((e) => e.id).toSet().length, catalog.length);
        expect(
          catalog.every((e) => wardrobeCategories.containsKey(e.category)),
          isTrue,
        );
        final bought = <int>[];
        var balance = 10000;
        for (final category in wardrobeCategories.keys) {
          final item = catalog.firstWhere(
            (e) => e.category == category && !e.isStarter,
          );
          expect(
            await container.read(shopProvider.notifier).buyItem(item.id),
            isTrue,
          );
          balance -= item.price;
          bought.add(item.id);
          expect(
            container.read(appProvider).equippedByCategory[category]?.name,
            item.name,
          );
          expect(
            await container.read(shopProvider.notifier).buyItem(item.id),
            isFalse,
          );
          expect(container.read(appProvider).profile!.coins, balance);
        }
        await container.read(appProvider.notifier).selectCharacter('cat');
        container.dispose();
        await Hive.close();
        await StorageService.init();
        container = ProviderContainer();
        container.read(appProvider);
        await Future<void>.delayed(Duration.zero);
        final state = container.read(appProvider);
        expect(state.profile!.characterKey, 'cat');
        expect(state.profile!.coins, balance);
        expect(state.inventory.map((e) => e.itemId), containsAll(bought));
        expect(
          state.equippedByCategory.keys,
          containsAll(wardrobeCategories.keys),
        );
        await container.read(shopProvider.notifier).unequipCategory('shoes');
        expect(
          container.read(appProvider).equippedByCategory.containsKey('shoes'),
          isFalse,
        );
        expect(
          container.read(appProvider).inventory.map((e) => e.itemId),
          containsAll(bought),
        );
      } finally {
        container.dispose();
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
