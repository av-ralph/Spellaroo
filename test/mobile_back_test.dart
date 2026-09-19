import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spellaroo/navigation/mobile_back_dispatcher.dart';

void main() {
  testWidgets('Phone Back handles root screens, shell screens and dialogs', (
    tester,
  ) async {
    final root = GlobalKey<NavigatorState>();
    final shell = GlobalKey<NavigatorState>();
    var homeBacks = 0;
    var gameBacks = 0;
    final router = GoRouter(
      navigatorKey: root,
      initialLocation: '/shop',
      routes: [
        ShellRoute(
          navigatorKey: shell,
          builder: (_, _, child) => child,
          routes: [
            GoRoute(path: '/shop', builder: (_, _) => const Text('Shop')),
            GoRoute(
              path: '/home',
              builder: (_, _) => PopScope(
                canPop: false,
                onPopInvokedWithResult: (_, _) => homeBacks++,
                child: const Text('Home'),
              ),
            ),
          ],
        ),
        GoRoute(path: '/play', builder: (_, _) => const Text('Categories')),
        GoRoute(path: '/play/easy', builder: (_, _) => const Text('Levels')),
        GoRoute(
          path: '/play/easy/1',
          builder: (_, _) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (_, _) => gameBacks++,
            child: const Text('Game'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        backButtonDispatcher: MobileBackDispatcher(router, root, shell),
      ),
    );
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    await tester.binding.handlePopRoute();
    expect(homeBacks, 1);
    router.go('/play/easy');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsOneWidget);
    router.go('/play/easy/1');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    expect(gameBacks, 1);
    showDialog<void>(
      context: root.currentContext!,
      builder: (_) => const AlertDialog(title: Text('Confirm')),
    );
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Confirm'), findsNothing);
    expect(gameBacks, 1);
  });
}
