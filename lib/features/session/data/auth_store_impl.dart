import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:learn_flutter/features/auth/data/user_dto.dart';
import 'package:learn_flutter/features/auth/domain/user.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';
import 'package:learn_flutter/features/session/domain/auth_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStoreImpl implements AuthStore {
  AuthStoreImpl({this._prefs, FlutterSecureStorage? secure})
    : _secure = secure ?? const FlutterSecureStorage();

  static const userKey = 'auth_user';
  static const tokenKey = 'github_token';

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secure;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AuthSession> load() async {
    final prefs = await _ensurePrefs();
    return AuthSession(
      token: await _secure.read(key: tokenKey),
      user: _userFromRaw(prefs.getString(userKey)),
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
      await prefs.setString(
        userKey,
        jsonEncode(UserDto.fromDomain(session.user!).toJson()),
      );
    }
  }

  static User? _userFromRaw(String? raw) {
    if (raw == null) return null;
    try {
      return UserDto.fromJson(jsonDecode(raw) as Map<String, dynamic>)
          .toDomain();
    } catch (_) {
      return null;
    }
  }
}
