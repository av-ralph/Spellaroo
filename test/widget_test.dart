import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spellaroo/models/profile.dart';
import 'package:spellaroo/providers/app_provider.dart';
import 'package:spellaroo/screens/splash_screen.dart';
import 'package:spellaroo/screens/character_select_screen.dart';
import 'package:spellaroo/widgets/character_portrait.dart';

class TestAppNotifier extends AppNotifier {
  @override
  Future<void> init() async {}

  void load(AppState value) => state = value;

  @override
  Future<void> selectCharacter(String key) async {
    state = state.copyWith(profile: state.profile!.copyWith(characterKey: key));
  }
}

void main() {
  testWidgets(
    'First launch waits for loading and keeps START visible until tapped',
    (tester) async {
      final notifier = TestAppNotifier();
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
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appProvider.overrideWith((_) => notifier)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expect(find.text('START'), findsNothing);
      notifier.load(AppState(loading: false));
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));
      expect(find.text('START'), findsOneWidget);
      expect(find.text('Create profile'), findsNothing);
      expect(find.byType(Image), findsOneWidget);
      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();
      expect(find.text('Create profile'), findsOneWidget);
    },
  );

  testWidgets('Returning player continues after splash delay', (tester) async {
    final notifier = TestAppNotifier()
      ..load(
        AppState(
          loading: false,
          profile: Profile(
            id: 'test',
            nickname: 'Test',
            characterKey: 'cat',
            tutorialCompleted: true,
          ),
        ),
      );
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Home destination')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appProvider.overrideWith((_) => notifier)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    expect(find.text('Home destination'), findsOneWidget);
  });

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('Selection uses supplied art and scrolls at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final notifier = TestAppNotifier()
        ..load(
          AppState(
            loading: false,
            profile: Profile(id: 'test', nickname: 'Test'),
          ),
        );
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const CharacterSelectScreen()),
          GoRoute(
            path: '/tutorial',
            builder: (_, _) => const Scaffold(body: Text('Saved choice')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appProvider.overrideWith((_) => notifier)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.scrollUntilVisible(
        find.text('Whiskers'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await Scrollable.ensureVisible(
        tester.element(find.text('Whiskers')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Whiskers'));
      await tester.pumpAndSettle();
      expect(find.text('Choose Whiskers'), findsOneWidget);
      expect(CharacterPortrait.assets['cat'], 'assets/images/Character 2.png');
      await tester.scrollUntilVisible(
        find.text('Foxy'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Foxy'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Choose Whiskers'));
      await tester.pumpAndSettle();
      expect(notifier.state.profile!.characterKey, 'cat');
      expect(find.text('Saved choice'), findsOneWidget);
    });
  }
}
