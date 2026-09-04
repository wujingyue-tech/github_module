import 'package:dio/dio.dart';

import 'net_cache.dart';
import '../common/global.dart';

final apiClient = Dio(
  BaseOptions(
    baseUrl: 'https://api.github.com/',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {
      Headers.acceptHeader: 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    },
  ),
)..interceptors.addAll([
  AuthInterceptor(),
  NetCache(),
]);

/// 登录成功后，后续请求自动带上 token。
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = Global.profile.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] ??= 'Bearer $token';
    }
    handler.next(options);
  }
}
