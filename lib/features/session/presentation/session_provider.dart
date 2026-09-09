import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_module/app/store_providers.dart';
import 'package:github_module/features/auth/domain/user.dart';
import 'package:github_module/features/session/domain/auth_session.dart';
import 'package:github_module/features/session/domain/auth_store.dart';

class SessionNotifier extends Notifier<AuthSession> {
  @override
  AuthSession build() => const AuthSession();

  AuthStore get _store => ref.read(authStoreProvider);

  Future<void> restore() async {
    state = await _store.load();
  }

  Future<void> setAuth({required String token, required User user}) async {
    state = state.copyWith(token: token, user: user);
    await _store.save(state);
  }

  Future<void> setUser(User user) async {
    state = state.copyWith(user: user);
    await _store.save(state);
  }

  Future<void> clearAuth() async {
    if (!state.isLoggedIn) return;
    state = state.copyWith(clearToken: true, clearUser: true);
    await _store.save(state);
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, AuthSession>(
  SessionNotifier.new,
);
