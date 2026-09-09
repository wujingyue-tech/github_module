import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/app/di.dart';
import 'package:github_module/app/router.dart';
import 'package:github_module/app/store_providers.dart';
import 'package:github_module/features/auth/data/fake_auth_repository.dart';
import 'package:github_module/features/auth/domain/sample_user.dart';
import 'package:github_module/features/repos/data/fake_repo_repository.dart';
import 'package:github_module/features/session/domain/auth_session.dart';
import 'package:github_module/l10n/app_localizations_en.dart';

import 'support/fake_app_analytics.dart';
import 'support/pump_app.dart';

final _l10n = AppLocalizationsEn();

void main() {
  testWidgets('logged-out users are sent to login', (tester) async {
    await pumpMainApp(
      tester,
      overrides: [
        authStoreProvider.overrideWithValue(MemoryAuthStore()),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.empty()),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.loginTitle), findsOneWidget);
    expect(find.text(_l10n.reposTitle), findsNothing);
  });

  testWidgets('logged-in users land on the repo list', (tester) async {
    await pumpMainApp(
      tester,
      restoreSession: true,
      overrides: [
        authStoreProvider.overrideWithValue(
          MemoryAuthStore(const AuthSession(token: 'tok', user: previewUser)),
        ),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.reposTitle), findsOneWidget);
    expect(find.text(_l10n.loginTitle), findsNothing);
  });

  testWidgets('logged-in users opening /login are sent to repos', (
    tester,
  ) async {
    final container = await pumpMainApp(
      tester,
      restoreSession: true,
      overrides: [
        authStoreProvider.overrideWithValue(
          MemoryAuthStore(const AuthSession(token: 'tok', user: previewUser)),
        ),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
      ],
    );
    await tester.pumpAndSettle();

    container.read(goRouterProvider).go('/login');
    await tester.pumpAndSettle();

    expect(find.text(_l10n.loginTitle), findsNothing);
    expect(find.text(_l10n.reposTitle), findsOneWidget);
  });

  testWidgets('logged-out launch records the login screen', (tester) async {
    final analytics = FakeAppAnalytics();
    await pumpMainApp(
      tester,
      overrides: [
        appAnalyticsProvider.overrideWithValue(analytics),
        authStoreProvider.overrideWithValue(MemoryAuthStore()),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.empty()),
      ],
    );
    await tester.pumpAndSettle();

    expect(analytics.screens, contains('/login'));
    expect(analytics.screens, isNot(contains('/logs')));
  });

  testWidgets('settings records a tracked screen', (tester) async {
    final analytics = FakeAppAnalytics();
    final container = await pumpMainApp(
      tester,
      restoreSession: true,
      overrides: [
        appAnalyticsProvider.overrideWithValue(analytics),
        authStoreProvider.overrideWithValue(
          MemoryAuthStore(const AuthSession(token: 'tok', user: previewUser)),
        ),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
      ],
    );
    await tester.pumpAndSettle();

    expect(analytics.screens, contains('/repos'));

    container.read(goRouterProvider).go('/settings');
    await tester.pumpAndSettle();

    expect(analytics.screens, contains('/settings'));
  });
}
