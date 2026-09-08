import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/store_providers.dart';
import 'package:learn_flutter/features/auth/domain/sample_user.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';
import 'package:learn_flutter/features/session/domain/auth_store.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';

class _FakeAuthStore implements AuthStore {
  _FakeAuthStore([this.session = const AuthSession()]);

  AuthSession session;

  @override
  Future<AuthSession> load() async => session;

  @override
  Future<void> save(AuthSession session) async {
    this.session = session;
  }
}

void main() {
  test('restore reads the auth store', () async {
    final store = _FakeAuthStore(
      const AuthSession(token: 'tok', user: previewUser),
    );
    final container = ProviderContainer(
      overrides: [authStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).restore();

    expect(container.read(sessionProvider).token, 'tok');
    expect(container.read(sessionProvider).user?.login, 'octocat');
  });

  test('setAuth persists to the auth store', () async {
    final store = _FakeAuthStore();
    final container = ProviderContainer(
      overrides: [authStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    await container
        .read(sessionProvider.notifier)
        .setAuth(token: 'ghp_test', user: previewUser);

    expect(container.read(sessionProvider).token, 'ghp_test');
    expect(store.session.token, 'ghp_test');
    expect(store.session.user?.login, 'octocat');
  });

  test('clearAuth persists an empty session', () async {
    final store = _FakeAuthStore(
      const AuthSession(token: 'tok', user: previewUser),
    );
    final container = ProviderContainer(
      overrides: [authStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).restore();
    await container.read(sessionProvider.notifier).clearAuth();

    expect(container.read(sessionProvider).isLoggedIn, isFalse);
    expect(store.session.token, isNull);
    expect(store.session.user, isNull);
  });
}
