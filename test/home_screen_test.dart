import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:spellaroo/services/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spellaroo/config/theme.dart';
import 'package:spellaroo/models/profile.dart';
import 'package:spellaroo/providers/app_provider.dart';
import 'package:spellaroo/screens/home_screen.dart';
import 'package:spellaroo/widgets/bottom_nav.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spellaroo/services/storage_service.dart';
import 'package:spellaroo/providers/shop_provider.dart';
import 'package:spellaroo/widgets/character_portrait.dart';
import 'package:spellaroo/widgets/outfit_layers.dart';

class HomeTestNotifier extends AppNotifier {
  @override
  Future<void> init() async {
    state = AppState(
      loading: false,
      profile: Profile(
        id: 'preview',
        nickname: 'bee',
        coins: 42,
        characterKey: 'kangaroo',
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storageDirectory;
  setUpAll(() async {
    storageDirectory = await Directory.systemTemp.createTemp('home-wardrobe-');
    Hive.init(storageDirectory.path);
    await StorageService.init();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.ryanheise.just_audio.methods'),
          (_) async => <String, dynamic>{},
        );
    AudioService.configure(soundOn: false, musicOn: false, effectsOn: false);
    for (final font in {
      'Nunito': 'assets/fonts/Nunito-800.ttf',
      'MaterialIcons':
          'C:/mobilesdk/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(font.key);
      loader.addFont(
        File(
          font.value,
        ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      );
      await loader.load();
    }
  });
  tearDownAll(() async {
    await Hive.close();
    await storageDirectory.delete(recursive: true);
  });
  testWidgets(
    'Home follows saved character and outfit changes for every buddy',
    (tester) async {
      tester.view.physicalSize = const Size(421, 933);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final notifier = HomeTestNotifier();
      await tester.runAsync(
        () => StorageService.saveProfile(notifier.state.profile!),
      );
      final container = ProviderContainer(
        overrides: [appProvider.overrideWith((_) => notifier)],
      );
      addTearDown(container.dispose);
      final capture = GlobalKey();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: RepaintBoundary(key: capture, child: const HomeScreen()),
          ),
        ),
      );
      final shop = container.read(shopProvider.notifier);
      final portraitFinder = find.byKey(const ValueKey('home-character'));
      for (final character in CharacterPortrait.assets.keys) {
        await tester.runAsync(() async {
          await notifier.selectCharacter(character);
          await shop.equipItem(1002, 'tops');
          await shop.equipItem(1005, 'bottoms');
          await shop.equipItem(1007, 'headbands');
        });
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(portraitFinder);
          await precacheImage(
            const AssetImage('assets/images/home_scenery.png'),
            context,
          );
          await precacheImage(
            AssetImage(CharacterPortrait.assets[character]!),
            context,
          );
        });
        await tester.pumpAndSettle();
        final portrait = tester.widget<CharacterPortrait>(portraitFinder);
        expect(portrait.characterKey, character);
        expect(portrait.equippedByCategory['tops']!.colorName, 'purple');
        expect(portrait.equippedByCategory['bottoms']!.colorName, 'green');
        expect(portrait.equippedByCategory['headbands']!.name, 'Star Headband');
        final painters = tester.widgetList<CustomPaint>(
          find.descendant(
            of: portraitFinder,
            matching: find.byType(CustomPaint),
          ),
        );
        final outfitPainter = painters
            .map((widget) => widget.painter)
            .whereType<OutfitAccessoriesPainter>()
            .single;
        expect(outfitPainter.characterKey, character);
        expect(outfitPainter.equipment['headbands']!.name, 'Star Headband');
        expect(
          find.descendant(
            of: portraitFinder,
            matching: find.byType(ColorFiltered),
          ),
          findsNWidgets(character == 'kangaroo' ? 1 : 2),
        );
        expect(StorageService.getProfile()!.characterKey, character);
        expect(tester.takeException(), isNull);
        if (character == 'cat' || character == 'kangaroo') {
          await tester.runAsync(() async {
            final boundary =
                capture.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory('.artifacts/home').create(recursive: true);
            await File(
              '.artifacts/home/home-$character-outfit.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.runAsync(() async {
          await shop.unequipCategory('tops');
          await shop.unequipCategory('bottoms');
          await shop.unequipCategory('headbands');
        });
        await tester.pumpAndSettle();
        expect(
          tester.widget<CharacterPortrait>(portraitFinder).equippedByCategory,
          isEmpty,
        );
        expect(
          find.descendant(
            of: portraitFinder,
            matching: find.byType(ColorFiltered),
          ),
          findsNothing,
        );
      }
    },
  );
  for (final size in [
    const Size(421, 933),
    const Size(320, 568),
    const Size(844, 390),
  ]) {
    testWidgets('Home fits and all actions navigate at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            builder: (context, state, child) => Scaffold(
              extendBody: true,
              body: child,
              bottomNavigationBar: const Padding(
                padding: EdgeInsets.fromLTRB(7, 0, 7, 12),
                child: BottomNav(),
              ),
            ),
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          for (final path in [
            '/play',
            '/shop',
            '/character/customize',
            '/progress',
            '/parent',
            '/settings',
          ])
            GoRoute(
              path: path,
              builder: (_, _) => Scaffold(body: Text('Destination $path')),
            ),
        ],
      );
      addTearDown(router.dispose);
      final capture = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appProvider.overrideWith((_) => HomeTestNotifier())],
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
      await tester.runAsync(() async {
        await precacheImage(
          const AssetImage('assets/images/home_scenery.png'),
          tester.element(find.byType(HomeScreen)),
        );
        await precacheImage(
          const AssetImage('assets/images/Spellaroo.png'),
          tester.element(find.byType(HomeScreen)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('42'), findsOneWidget);
      if (size.width == 421) {
        await tester.runAsync(() async {
          final boundary =
              capture.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('.artifacts/home').create(recursive: true);
          await File(
            '.artifacts/home/home-preview.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      for (final action in {
        'Let’s play': '/play',
        'Shop': '/shop',
        'Character': '/character/customize',
        'Progress': '/progress',
        'Parent': '/parent',
      }.entries) {
        final button = find.text(action.key).first;
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text('Destination ${action.value}'), findsOneWidget);
        router.go('/home');
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }
}
