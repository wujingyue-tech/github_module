import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:github_module/features/auth/domain/user.dart';
import 'package:github_module/features/session/domain/auth_session.dart';
import 'package:github_module/features/session/domain/auth_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStoreImpl implements AuthStore {
  AuthStoreImpl({
    required this.encodeUser,
    required this.decodeUser,
    this._prefs,
    FlutterSecureStorage? secure,
  }) : _secure = secure ?? const FlutterSecureStorage();

  static const userKey = 'auth_user';
  static const tokenKey = 'github_token';

  final String Function(User user) encodeUser;
  final User? Function(String raw) decodeUser;

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secure;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AuthSession> load() async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getString(userKey);
    return AuthSession(
      token: await _secure.read(key: tokenKey),
      user: raw == null ? null : decodeUser(raw),
    );
  }

  @override
  Future<void> save(AuthSession session) async {
    final prefs = await _ensurePrefs();
    if (session.token == null || session.token!.isEmpty) {
      await _secure.delete(key: tokenKey);
    } else {
      await _secure.write(key: tokenKey, value: session.token);
    }

    if (session.user == null) {
      await prefs.remove(userKey);
    } else {
      await prefs.setString(userKey, encodeUser(session.user!));
    }
  }
}
