import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/features/session/data/auth_store.dart';
import 'package:learn_flutter/features/auth/domain/user.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';

class SessionNotifier extends Notifier<AuthSession> {
  AuthStore? _store;

  @override
  AuthSession build() => const AuthSession();

  Future<void> restore() async {
    final store = await _ensureStore();
    state = await store.load();
  }

  Future<void> setAuth({required String token, required User user}) async {
    state = state.copyWith(token: token, user: user);
    await _persist();
  }

  Future<void> setUser(User user) async {
    state = state.copyWith(user: user);
    await _persist();
  }

  Future<void> clearAuth() async {
    if (!state.isLoggedIn) return;
    state = state.copyWith(clearToken: true, clearUser: true);
    await _persist();
  }

  Future<AuthStore> _ensureStore() async {
    return _store ??= await AuthStore.open();
  }

  Future<void> _persist() async {
    final store = await _ensureStore();
    await store.save(state);
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, AuthSession>(
  SessionNotifier.new,
);
