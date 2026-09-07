import 'auth_session.dart';

abstract interface class AuthStore {
  Future<AuthSession> load();
  Future<void> save(AuthSession session);
}
