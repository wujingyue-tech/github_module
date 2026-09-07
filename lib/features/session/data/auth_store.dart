import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:learn_flutter/features/auth/data/user_dto.dart';
import 'package:learn_flutter/features/auth/domain/user.dart';
import 'package:learn_flutter/features/session/data/profile_dto.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStore {
  AuthStore({required this.prefs, required this.secure});

  static const userKey = 'auth_user';
  static const tokenKey = 'github_token';
  static const lastLoginKey = 'auth_last_login';
  static const legacyProfileKey = 'profile';

  final SharedPreferences prefs;
  final FlutterSecureStorage secure;

  static Future<AuthStore> open() async {
    return AuthStore(
      prefs: await SharedPreferences.getInstance(),
      secure: const FlutterSecureStorage(),
    );
  }

  Future<AuthSession> load() async {
    final legacy = _legacyProfile();

    var token = await secure.read(key: tokenKey);
    final legacyToken = legacy?.token;
    if ((token == null || token.isEmpty) &&
        legacyToken != null &&
        legacyToken.isNotEmpty) {
      token = legacyToken;
      await secure.write(key: tokenKey, value: token);
    }

    final user =
        _userFromRaw(prefs.getString(userKey)) ??
        (legacy?.user == null
            ? null
            : UserDto.fromJson(legacy!.user!).toDomain());
    final lastLogin = prefs.getString(lastLoginKey) ?? legacy?.lastLogin;

    final session = AuthSession(token: token, user: user, lastLogin: lastLogin);
    await save(session);
    return session;
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

    if (session.lastLogin == null || session.lastLogin!.isEmpty) {
      await prefs.remove(lastLoginKey);
    } else {
      await prefs.setString(lastLoginKey, session.lastLogin!);
    }
  }

  ProfileDto? _legacyProfile() {
    final raw = prefs.getString(legacyProfileKey);
    if (raw == null) return null;
    try {
      return ProfileDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
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
