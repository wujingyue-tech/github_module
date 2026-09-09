import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/app/di.dart';
import 'package:github_module/app/store_providers.dart';
import 'package:github_module/core/analytics/analytics_policy.dart';
import 'package:github_module/core/error/app_exception.dart';
import 'package:github_module/features/auth/data/fake_auth_repository.dart';
import 'package:github_module/features/auth/domain/sample_user.dart';
import 'package:github_module/features/auth/presentation/auth_provider.dart';
import 'package:github_module/features/session/domain/auth_session.dart';
import 'package:github_module/features/session/domain/auth_store.dart';
import 'package:github_module/features/session/presentation/session_provider.dart';

import 'support/fake_app_analytics.dart';

class _FakeAuthStore implements AuthStore {
  _FakeAuthStore() : session = const AuthSession();

  AuthSession session;

  @override
  Future<AuthSession> load() async => session;

  @override
  Future<void> save(AuthSession session) async {
    this.session = session;
  }
}

void main() {
  test('empty token does not write session', () async {
    final store = _FakeAuthStore();
    final analytics = FakeAppAnalytics();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
        authStoreProvider.overrideWithValue(store),
        appAnalyticsProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.future);
    await container.read(authProvider.notifier).login('  ');
    final auth = container.read(authProvider);
    expect(auth.error, isA<AppException>());
    expect((auth.error! as AppException).code, AppErrorCode.emptyToken);
    expect(container.read(sessionProvider).isLoggedIn, isFalse);
    expect(store.session.isLoggedIn, isFalse);
    expect(analytics.events, hasLength(1));
    expect(analytics.events.single.name, AnalyticsPolicy.loginFailure);
    expect(analytics.events.single.properties, {
      'reason': AppErrorCode.emptyToken.name,
    });
  });

  test('login writes auth session', () async {
    final store = _FakeAuthStore();
    final analytics = FakeAppAnalytics();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
        authStoreProvider.overrideWithValue(store),
        appAnalyticsProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).restore();
    await container.read(authProvider.future);
    await container.read(authProvider.notifier).login('ghp_test');

    expect(container.read(authProvider).value?.login, 'octocat');
    expect(container.read(sessionProvider).token, 'ghp_test');
    expect(container.read(sessionProvider).user?.login, 'octocat');
    expect(store.session.token, 'ghp_test');
    expect(analytics.events.single.name, AnalyticsPolicy.loginSuccess);
  });

  test('failed login captures a reason without identifying', () async {
    final analytics = FakeAppAnalytics();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.error()),
        authStoreProvider.overrideWithValue(_FakeAuthStore()),
        appAnalyticsProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.future);
    await container.read(authProvider.notifier).login('ghp_bad');

    expect(container.read(authProvider).hasError, isTrue);
    expect(analytics.identifies, isEmpty);
    expect(analytics.events.single.name, AnalyticsPolicy.loginFailure);
    expect(analytics.events.single.properties, {
      'reason': AppErrorCode.invalidToken.name,
    });
  });

  test('logout captures the event before clearing the session', () async {
    final analytics = FakeAppAnalytics();
    final store = _FakeAuthStore()
      ..session = const AuthSession(token: 'tok', user: previewUser);
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
        authStoreProvider.overrideWithValue(store),
        appAnalyticsProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).restore();
    await container.read(authProvider.future);
    await container.read(authProvider.notifier).logout();

    expect(container.read(sessionProvider).isLoggedIn, isFalse);
    expect(analytics.events.single.name, AnalyticsPolicy.logout);
  });
}
