import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/app_shell.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/repo_list_page.dart';
import 'pages/settings_page.dart';
import 'providers/auth_provider.dart';

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/repos',
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final loggingIn = path == '/login';
      final inSettings = path == '/settings';
      if (!hasSavedToken && !loggingIn && !inSettings) return '/login';
      if (hasSavedToken && (loggingIn || path == '/')) return '/repos';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/repos',
                builder: (context, state) => const RepoListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
