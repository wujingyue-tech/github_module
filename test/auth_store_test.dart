import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/features/auth/domain/user.dart';
import 'package:learn_flutter/features/session/data/auth_store_impl.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('load is empty when nothing is stored', () async {
    final store = AuthStoreImpl(
      prefs: await SharedPreferences.getInstance(),
      secure: const FlutterSecureStorage(),
    );

    final session = await store.load();
    expect(session.token, isNull);
    expect(session.user, isNull);
    expect(session.isLoggedIn, isFalse);
  });

  test('save keeps token in secure storage only', () async {
    final store = AuthStoreImpl(
      prefs: await SharedPreferences.getInstance(),
      secure: const FlutterSecureStorage(),
    );
    await store.save(
      const AuthSession(
        token: 'secret',
        user: User(
          login: 'octocat',
          avatarUrl: 'https://example.com/a.png',
          type: 'User',
          publicRepos: 0,
          followers: 0,
          following: 0,
          totalPrivateRepos: 0,
          ownedPrivateRepos: 0,
        ),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('profile'), isNull);
    expect(prefs.getString('auth_user'), isNotNull);

    final token = await const FlutterSecureStorage().read(key: 'github_token');
    expect(token, 'secret');
  });
}
