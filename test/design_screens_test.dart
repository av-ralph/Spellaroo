import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spellaroo/app.dart';
import 'package:spellaroo/config/theme.dart';
import 'package:spellaroo/models/profile.dart';
import 'package:spellaroo/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storage;
  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.ryanheise.just_audio.methods'),
          (_) async => <String, dynamic>{},
        );
    storage = await Directory.systemTemp.createTemp('spellaroo-design-');
    Hive.init(storage.path);
    await StorageService.init();
    await StorageService.saveProfile(
      Profile(
        id: 'design',
        nickname: 'Bee',
        gradeLevel: 5,
        coins: 120,
        characterKey: 'cat',
        tutorialCompleted: true,
        soundOn: false,
        musicOn: false,
        effectsOn: false,
      ),
    );
    for (final entry in {
      'Nunito': [
        'assets/fonts/Nunito-400.ttf',
        'assets/fonts/Nunito-700.ttf',
        'assets/fonts/Nunito-800.ttf',
      ],
      'Baloo2': ['assets/fonts/Baloo2-400.ttf', 'assets/fonts/Baloo2-800.ttf'],
      'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
    }.entries) {
      final font = FontLoader(entry.key);
      for (final path in entry.value) {
        font.addFont(rootBundle.load(path));
      }
      await font.load();
    }
  });
  tearDownAll(() async {
    await Hive.close();
    await storage.delete(recursive: true);
  });
  for (final size in [
    const Size(390, 844),
    const Size(320, 568),
    const Size(844, 390),
  ]) {
    testWidgets('Adventure screens remain readable and fit at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(goRouterProvider);
      router.go('/shop');
      final capture = GlobalKey();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: capture,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        ),
      );
      for (final entry in {
        'shop': '/shop',
        'wardrobe': '/character/customize',
        'progress': '/progress',
        'settings': '/settings',
        'parent': '/parent',
        'parent-overview': '/parent',
        'categories': '/play',
        'levels': '/play/easy',
        'profile': '/profile/create',
        'characters': '/character/select',
        'tutorial': '/tutorial',
        'game-intro': '/play/easy/1',
        'gameplay': '/play/easy/1',
      }.entries) {
        router.go(entry.value);
        await tester.pumpAndSettle();
        if (entry.key == 'parent-overview') {
          await tester.ensureVisible(find.text('Unlock'));
          await tester.tap(find.text('Unlock'));
          await tester.pumpAndSettle();
          expect(find.text('Growing one word at a time'), findsOneWidget);
        }
        if (entry.key == 'gameplay') {
          await tester.ensureVisible(find.text('Start'));
          await tester.tap(find.text('Start'));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('spelling-answer')), findsOneWidget);
        }
        expect(tester.takeException(), isNull, reason: entry.key);
        if (size.width == 390) {
          await tester.runAsync(() async {
            final context = tester.element(find.byType(Scaffold).last);
            for (final path in [
              'assets/images/Homescreen_BG.png',
              'assets/images/Character 2.png',
              'assets/images/Character 3.png',
              'assets/images/Character 4.png',
              'assets/images/Character 5.png',
              'assets/images/Character 6.png',
              'assets/images/Spellaroo.png',
            ]) {
              await precacheImage(AssetImage(path), context);
            }
          });
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final image =
                await (capture.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 1.5);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory('.artifacts/design').create(recursive: true);
            await File(
              '.artifacts/design/${entry.key}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    });
  }
}
