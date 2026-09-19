import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final routerBackDispatchers = Expando<MobileBackDispatcher>();

/// Ask the actual navigators first so root-page PopScopes also receive Back.
/// Routes reached with go() have no stack, so give them a logical parent.
class MobileBackDispatcher extends RootBackButtonDispatcher {
  MobileBackDispatcher(this.router, this.rootKey, this.shellKey);

  final GoRouter router;
  final GlobalKey<NavigatorState> rootKey;
  final GlobalKey<NavigatorState> shellKey;

  @override
  Future<bool> didPopRoute() async {
    if (await rootKey.currentState?.maybePop() ?? false) return true;
    if (await shellKey.currentState?.maybePop() ?? false) return true;
    final path = router.routeInformationProvider.value.uri.path;
    final parent = switch (path) {
      '/' || '/home' => null,
      '/profile/create' => '/',
      '/character/select' => '/profile/create',
      '/tutorial' => '/home',
      _ when path.startsWith('/play/') => '/play',
      _ => '/home',
    };
    if (parent != null) router.go(parent);
    // Never let a missing route stack silently close the app.
    return true;
  }
}
