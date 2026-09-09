import 'package:github_module/features/auth/domain/user.dart';

class AuthSession {
  const AuthSession({this.token, this.user});

  final String? token;
  final User? user;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  AuthSession copyWith({
    String? token,
    User? user,
    bool clearToken = false,
    bool clearUser = false,
  }) {
    return AuthSession(
      token: clearToken ? null : token ?? this.token,
      user: clearUser ? null : user ?? this.user,
    );
  }
}
