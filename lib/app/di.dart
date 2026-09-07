import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/core/network/app_config.dart';
import 'package:learn_flutter/core/network/auth_interceptor.dart';
import 'package:learn_flutter/core/network/create_dio.dart';
import 'package:learn_flutter/core/network/net_cache.dart';
import 'package:learn_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:learn_flutter/features/auth/data/github_auth_remote.dart';
import 'package:learn_flutter/features/auth/domain/auth_repository.dart';
import 'package:learn_flutter/features/repos/data/github_repo_remote.dart';
import 'package:learn_flutter/features/repos/data/repo_repository_impl.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';
import 'package:learn_flutter/features/session/presentation/settings_provider.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.github);

final dioProvider = Provider<Dio>((ref) {
  final dio = createDio(ref.watch(appConfigProvider));
  dio.interceptors.addAll([
    AuthInterceptor(
      readToken: () => ref.read(sessionProvider).token,
      onUnauthorized: () {
        ref.read(sessionProvider.notifier).clearAuth();
      },
    ),
    NetCache(readConfig: () => ref.read(settingsProvider).cache),
  ]);
  return dio;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(GitHubAuthRemote(ref.watch(dioProvider)));
});

final repoRepositoryProvider = Provider<RepoRepository>((ref) {
  return RepoRepositoryImpl(GitHubRepoRemote(ref.watch(dioProvider)));
});
