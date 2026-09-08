import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/analytics/analytics_policy.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/features/auth/domain/user.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return ref.read(sessionProvider).user;
  }

  Future<void> login(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      state = AsyncError(
        AppException(AppErrorCode.emptyToken),
        StackTrace.current,
      );
      await ref.read(appAnalyticsProvider).event(AnalyticsPolicy.loginFailure, {
        'reason': AppErrorCode.emptyToken.name,
      });
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .getUser(
            token: trimmed,
            headers: const {'cache-control': 'no-store'},
          );
      await ref
          .read(sessionProvider.notifier)
          .setAuth(token: trimmed, user: user);
      return user;
    });
    final analytics = ref.read(appAnalyticsProvider);
    if (state.hasError) {
      await analytics.event(AnalyticsPolicy.loginFailure, {
        'reason': _loginFailureReason(state.error!),
      });
    } else if (state.value != null) {
      await analytics.event(AnalyticsPolicy.loginSuccess);
    }
  }

  Future<void> refreshProfile() async {
    final user = await ref
        .read(authRepositoryProvider)
        .getUser(headers: const {'cache-control': 'no-cache'});
    await ref.read(sessionProvider.notifier).setUser(user);
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await ref.read(appAnalyticsProvider).event(AnalyticsPolicy.logout);
    await ref.read(sessionProvider.notifier).clearAuth();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

String _loginFailureReason(Object error) {
  if (error is AppException) return error.code.name;
  return AppErrorCode.failed.name;
}
