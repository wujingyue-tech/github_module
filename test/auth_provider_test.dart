import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/features/auth/domain/auth_repository.dart';
import 'package:learn_flutter/features/auth/domain/user.dart';
import 'package:learn_flutter/features/auth/presentation/auth_provider.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _user = User(
  login: 'octocat',
  avatarUrl: 'https://example.com/a.png',
  type: 'User',
  publicRepos: 1,
  followers: 0,
  following: 0,
  totalPrivateRepos: 0,
  ownedPrivateRepos: 0,
);

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository();

  @override
  Future<User> getUser({String? token, bool refresh = false}) async => _user;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('empty token does not write session', () async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(const _FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.future);
    await container.read(authProvider.notifier).login('  ');
    final auth = container.read(authProvider);
    expect(auth.error, isA<AppException>());
    expect((auth.error! as AppException).code, AppErrorCode.emptyToken);
    expect(container.read(sessionProvider).isLoggedIn, isFalse);
  });

  test('login writes auth session', () async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(const _FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).restore();
    await container.read(authProvider.future);
    await container.read(authProvider.notifier).login('ghp_test');

    expect(container.read(authProvider).value?.login, 'octocat');
    expect(container.read(sessionProvider).token, 'ghp_test');
    expect(container.read(sessionProvider).user?.login, 'octocat');
  });
}
