import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spellaroo/models/profile.dart';
import 'package:spellaroo/providers/app_provider.dart';
import 'package:spellaroo/providers/shop_provider.dart';
import 'package:spellaroo/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Starter wardrobe, guarded purchases and equipped items persist',
    () async {
      final directory = await Directory.systemTemp.createTemp('wardrobe-test-');
      Hive.init(directory.path);
      await StorageService.init();
      await StorageService.saveProfile(
        Profile(id: 'test', nickname: 'Roo', gradeLevel: 1, coins: 30),
      );
      final container = ProviderContainer();
      final shop = container.read(shopProvider.notifier);
      expect(StorageService.getInventory().length, 12);
      await shop.equipItem(1001, 'tops');
      await shop.equipItem(1002, 'tops');
      expect(
        StorageService.getInventory().where((e) => e.equipped).single.itemId,
        1002,
      );
      await shop.equipItem(12, 'tops');
      expect(
        StorageService.getInventory().where((e) => e.equipped).single.itemId,
        1002,
      );
      final results = await Future.wait([shop.buyItem(12), shop.buyItem(12)]);
      expect(results, [true, false]);
      expect(container.read(appProvider).profile!.coins, 10);
      expect(await shop.buyItem(7), isFalse);
      expect(container.read(appProvider).profile!.coins, 10);
      await shop.equipItem(12, 'bottoms');
      expect(
        StorageService.getInventory().where((e) => e.equipped).single.itemId,
        1002,
      );
      await shop.equipItem(12, 'tops');
      await shop.equipItem(1007, 'headbands');
      await shop.unequipCategory('tops');
      expect(container.read(appProvider).equippedByCategory.keys, [
        'headbands',
      ]);
      container.dispose();
      await Hive.close();
      Hive.init(directory.path);
      await StorageService.init();
      expect(StorageService.getInventory().length, 13);
      expect(
        StorageService.getInventory().where((e) => e.equipped).single.itemId,
        1007,
      );
      expect(StorageService.getProfile()!.coins, 10);
      await Hive.close();
      await directory.delete(recursive: true);
    },
  );
}
