import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spellaroo/config/theme.dart';
import 'package:spellaroo/providers/app_provider.dart';
import 'package:spellaroo/screens/splash_screen.dart';

class SplashPreviewNotifier extends AppNotifier {
  @override
  Future<void> init() async {
    state = AppState(loading: false);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'Nunito': [
        'assets/fonts/Nunito-400.ttf',
        'assets/fonts/Nunito-700.ttf',
        'assets/fonts/Nunito-800.ttf',
      ],
      'Baloo2': ['assets/fonts/Baloo2-400.ttf', 'assets/fonts/Baloo2-800.ttf'],
      'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final path in entry.value) {
        loader.addFont(rootBundle.load(path));
      }
      await loader.load();
    }
  });
  for (final size in [
    const Size(390, 844),
    const Size(320, 568),
    const Size(844, 390),
    const Size(768, 1024),
  ]) {
    testWidgets('Splash stays readable and starts on $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
          GoRoute(
            path: '/profile/create',
            builder: (_, _) => const Scaffold(body: Text('Create profile')),
          ),
        ],
      );
      addTearDown(router.dispose);
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appProvider.overrideWith((_) => SplashPreviewNotifier())],
          child: RepaintBoundary(
            key: key,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final context = tester.element(find.byType(SplashScreen));
        await precacheImage(
          const AssetImage('assets/images/splash_adventure.png'),
          context,
        );
        await precacheImage(
          const AssetImage('assets/images/Spellaroo.png'),
          context,
        );
      });
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));
      expect(tester.takeException(), isNull);
      expect(find.text('START'), findsOneWidget);
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1.5);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('.artifacts/splash').create(recursive: true);
        await File(
          '.artifacts/splash/splash-${size.width.toInt()}x${size.height.toInt()}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.ensureVisible(find.text('START'));
      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();
      expect(find.text('Create profile'), findsOneWidget);
    });
  }
}
