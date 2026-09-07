import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/features/auth/data/fake_auth_repository.dart';
import 'package:learn_flutter/features/auth/presentation/auth_provider.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';
import 'package:learn_flutter/features/session/domain/auth_store.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';

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
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
        authStoreProvider.overrideWithValue(store),
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
  });

  test('login writes auth session', () async {
    final store = _FakeAuthStore();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
        authStoreProvider.overrideWithValue(store),
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
  });
}
