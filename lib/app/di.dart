import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/core/app_info.dart';
import 'package:learn_flutter/core/logging/app_log.dart';
import 'package:learn_flutter/core/logging/http_log_dump.dart';
import 'package:learn_flutter/core/logging/log_dump.dart';
import 'package:learn_flutter/core/logging/talker_app_log.dart';
import 'package:learn_flutter/core/network/app_config.dart';
import 'package:learn_flutter/core/network/auth_interceptor.dart';
import 'package:learn_flutter/core/network/create_dio.dart';
import 'package:learn_flutter/core/network/http_cache.dart';
import 'package:learn_flutter/core/network/http_log_interceptor.dart';
import 'package:learn_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:learn_flutter/features/auth/data/github_auth_remote.dart';
import 'package:learn_flutter/features/auth/domain/auth_repository.dart';
import 'package:learn_flutter/features/repos/data/github_repo_remote.dart';
import 'package:learn_flutter/features/repos/data/repo_repository_impl.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';
import 'package:talker/talker.dart';

final talkerProvider = Provider<Talker>((ref) => Talker());

final appInfoProvider = Provider<AppInfo>((ref) => AppInfo.unset);

final appLogProvider = Provider<AppLog>((ref) {
  return TalkerAppLog(ref.watch(talkerProvider));
});

/// Dedicated client so uploading a dump is not logged by TalkerDioLogger.
final logDumpDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
});

final logDumpProvider = Provider<LogDump>((ref) {
  return HttpLogDump(
    talker: ref.watch(talkerProvider),
    dio: ref.watch(logDumpDioProvider),
    endpoint: ref.watch(appConfigProvider).logDumpUrl,
    appInfo: ref.watch(appInfoProvider),
  );
});

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.resolve());

final cacheStoreProvider = Provider<CacheStore>((ref) => createCacheStore());

final cacheOptionsProvider = Provider<CacheOptions>((ref) {
  return createCacheOptions(store: ref.watch(cacheStoreProvider));
});

final dioProvider = Provider<Dio>((ref) {
  final dio = createDio(ref.watch(appConfigProvider));
  dio.interceptors.addAll([
    AuthInterceptor(
      readToken: () => ref.read(sessionProvider).token,
      onUnauthorized: () {
        ref.read(appLogProvider).warn('cleared session after 401');
        ref.read(sessionProvider.notifier).clearAuth();
      },
    ),
    createHttpLogInterceptor(ref.watch(talkerProvider)),
    DioCacheInterceptor(options: ref.watch(cacheOptionsProvider)),
  ]);
  return dio;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(GitHubAuthRemote(ref.watch(dioProvider)));
});

final repoRepositoryProvider = Provider<RepoRepository>((ref) {
  return RepoRepositoryImpl(GitHubRepoRemote(ref.watch(dioProvider)));
});
