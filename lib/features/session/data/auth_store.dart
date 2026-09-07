import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:learn_flutter/features/auth/data/user_dto.dart';
import 'package:learn_flutter/features/auth/domain/user.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStore {
  AuthStore({required this.prefs, required this.secure});

  static const userKey = 'auth_user';
  static const tokenKey = 'github_token';

  final SharedPreferences prefs;
  final FlutterSecureStorage secure;

  static Future<AuthStore> open() async {
    return AuthStore(
      prefs: await SharedPreferences.getInstance(),
      secure: const FlutterSecureStorage(),
    );
  }

  Future<AuthSession> load() async {
    return AuthSession(
      token: await secure.read(key: tokenKey),
      user: _userFromRaw(prefs.getString(userKey)),
    );
  }

  Future<void> save(AuthSession session) async {
    if (session.token == null || session.token!.isEmpty) {
      await secure.delete(key: tokenKey);
    } else {
      await secure.write(key: tokenKey, value: session.token);
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
