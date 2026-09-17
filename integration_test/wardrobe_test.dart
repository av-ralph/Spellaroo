import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spellaroo/app.dart';
import 'package:spellaroo/models/profile.dart';
import 'package:spellaroo/providers/app_provider.dart';
import 'package:spellaroo/providers/shop_provider.dart';
import 'package:spellaroo/services/storage_service.dart';
import 'package:spellaroo/widgets/character_portrait.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Wardrobe equips, replaces, removes and persists outfits on six characters',
    (tester) async {
      final directory = await Directory.systemTemp.createTemp(
        'spellaroo-wardrobe-',
      );
      Hive.init(directory.path);
      await StorageService.init();
      await StorageService.saveProfile(
        Profile(
          id: 'wardrobe-test',
          nickname: 'Roo',
          gradeLevel: 1,
          characterKey: 'kangaroo',
          tutorialCompleted: true,
        ),
      );
      expect(
        StorageService.getInventory().where((e) => e.itemId >= 1001).length,
        12,
      );
      await tester.pumpWidget(const ProviderScope(child: SpellarooApp()));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SpellarooApp)),
      );
      final router = container.read(goRouterProvider);
      router.go('/character/customize');
      await tester.pumpAndSettle();
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
      Future<void> tapKey(String key) async {
        final finder = find.byKey(ValueKey(key));
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tapKey('wear-1001');
      expect(
        container.read(appProvider).equippedByCategory['tops']!.name,
        'Ocean Hoodie',
      );
      await tapKey('wear-1002');
      expect(StorageService.getInventory().where((e) => e.equipped).length, 1);
      await tapKey('wardrobe-tab-bottoms');
      await tapKey('wear-1005');
      await tapKey('wardrobe-tab-headbands');
      await tapKey('wear-1008');
      await tapKey('wardrobe-tab-accessories');
      await tapKey('wear-1010');
      final preview = tester.widget<CharacterPortrait>(
        find.byKey(const ValueKey('wardrobe-preview')),
      );
      expect(preview.equippedByCategory.length, 4);
      for (final character in CharacterPortrait.assets.keys) {
        await tester.runAsync(
          () => precacheImage(
            AssetImage(CharacterPortrait.assets[character]!),
            tester.element(find.byType(SpellarooApp)),
          ),
        );
        await container.read(appProvider.notifier).selectCharacter(character);
      router.go('/home');
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await tester.pump();
      await binding.takeScreenshot('wardrobe-$character');
        expect(tester.takeException(), isNull);
      }
      router.go('/character/customize');
      await tester.pumpAndSettle();
      await binding.takeScreenshot('wardrobe-screen');
      await tapKey('wardrobe-tab-tops');
      await tapKey('wear-tops');
      expect(
        container.read(appProvider).equippedByCategory.containsKey('tops'),
        isFalse,
      );
      await tapKey('wear-1001');
      // A locked item cannot silently replace an owned outfit.
      await container.read(shopProvider.notifier).equipItem(12, 'tops');
      expect(
        container.read(appProvider).equippedByCategory['tops']!.name,
        'Ocean Hoodie',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await Hive.close();
      Hive.init(directory.path);
      await StorageService.init();
      expect(StorageService.getInventory().where((e) => e.equipped).length, 4);
      expect(
        StorageService.getInventory().where((e) => e.itemId >= 1001).length,
        12,
      );
      await Hive.close();
    },
  );
}
