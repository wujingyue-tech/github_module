import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_flutter/app/log_console_provider.dart';
import 'package:learn_flutter/app/log_viewer_page.dart';
import 'package:learn_flutter/features/auth/presentation/login_page.dart';
import 'package:learn_flutter/features/auth/presentation/profile_page.dart';
import 'package:learn_flutter/features/repos/presentation/app_shell.dart';
import 'package:learn_flutter/features/repos/presentation/repo_list_page.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';
import 'package:learn_flutter/features/session/presentation/settings_page.dart';

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(sessionProvider.select((s) => s.isLoggedIn), (_, _) {
      notifyListeners();
    });
    ref.listen(logConsoleProvider.select((s) => s.unlocked), (_, _) {
      notifyListeners();
    });
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
      final inLogs = path == '/logs';
      final logsUnlocked = ref.read(logConsoleProvider).unlocked;
      final loggedIn = ref.read(sessionProvider).isLoggedIn;
      if (inLogs && !logsUnlocked) {
        return loggedIn ? '/repos' : '/login';
      }
      if (!loggedIn && !loggingIn && !inSettings && !inLogs) return '/login';
      if (loggedIn && (loggingIn || path == '/')) return '/repos';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/logs',
        builder: (context, state) => const LogViewerPage(),
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
