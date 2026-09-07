import 'package:learn_flutter/features/auth/domain/user.dart';

class AuthSession {
  const AuthSession({this.token, this.user, this.lastLogin});

  final String? token;
  final User? user;
  final String? lastLogin;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  AuthSession copyWith({
    String? token,
    User? user,
    String? lastLogin,
    bool clearToken = false,
    bool clearUser = false,
  }) {
    return AuthSession(
      token: clearToken ? null : token ?? this.token,
      user: clearUser ? null : user ?? this.user,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
