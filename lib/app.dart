import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_create_screen.dart';
import 'screens/character_select_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_levels_screen.dart';
import 'screens/game_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/character_customize_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/tutorial_screen.dart';
import 'widgets/bottom_nav.dart';
import 'navigation/mobile_back_dispatcher.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
      GoRoute(
        path: '/profile/create',
        builder: (c, s) => const ProfileCreateScreen(),
      ),
      GoRoute(
        path: '/character/select',
        builder: (c, s) => const CharacterSelectScreen(),
      ),
      GoRoute(path: '/tutorial', builder: (c, s) => const TutorialScreen()),
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) => Scaffold(
          extendBody: state.uri.path == '/home',
          body: child,
          bottomNavigationBar: const Padding(
            padding: EdgeInsets.fromLTRB(7, 0, 7, 12),
            child: BottomNav(),
          ),
        ),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/shop', builder: (c, s) => const ShopScreen()),
          GoRoute(
            path: '/character/customize',
            builder: (c, s) => const CharacterCustomizeScreen(),
          ),
          GoRoute(path: '/progress', builder: (c, s) => const ProgressScreen()),
          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        ],
      ),
      GoRoute(path: '/play', builder: (c, s) => const CategorySelectScreen()),
      GoRoute(
        path: '/play/random',
        builder: (c, s) => const GameScreen(category: 'random'),
      ),
      GoRoute(
        path: '/play/random/play',
        builder: (c, s) => const GameScreen(category: 'random'),
      ),
      GoRoute(
        path: '/play/:category',
        builder: (c, s) {
          final category = s.pathParameters['category'] ?? 'easy';
          return CategoryLevelsScreen(category: category);
        },
      ),
      GoRoute(
        path: '/play/:category/:levelId',
        builder: (c, s) {
          final category = s.pathParameters['category'] ?? 'easy';
          final levelId = int.tryParse(s.pathParameters['levelId'] ?? '');
          if (levelId == null || levelId < 1) {
            final firstLevel =
                StorageService.allLevels
                    .where((l) => l.category == category)
                    .toList()
                  ..sort((a, b) => a.id.compareTo(b.id));
            final fallbackId = firstLevel.isNotEmpty ? firstLevel.first.id : 1;
            return GameScreen(category: category, levelId: fallbackId);
          }
          return GameScreen(category: category, levelId: levelId);
        },
      ),
      GoRoute(
        path: '/parent',
        builder: (c, s) => const ParentDashboardScreen(),
      ),
    ],
  );
  routerBackDispatchers[router] = MobileBackDispatcher(
    router,
    rootKey,
    shellKey,
  );
  ref.onDispose(router.dispose);
  return router;
});

class SpellarooApp extends ConsumerWidget {
  const SpellarooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Spellaroo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: routerBackDispatchers[router],
    );
  }
}
