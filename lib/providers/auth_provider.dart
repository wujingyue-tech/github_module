import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/global.dart';
import '../models/user.dart';
import '../services/github_api.dart';

bool get hasSavedToken => Global.profile.token?.isNotEmpty == true;

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    if (!hasSavedToken) return null;
    return Global.profile.user;
  }

  Future<void> login(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      state = AsyncError(
        AuthException(AuthErrorCode.emptyToken),
        StackTrace.current,
      );
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => GitHubApi.login(trimmed));
  }

  Future<void> logout() async {
    await GitHubApi.logout();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
