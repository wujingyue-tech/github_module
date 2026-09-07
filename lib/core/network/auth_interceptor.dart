import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.readToken, required this.onUnauthorized});

  final String? Function() readToken;
  final void Function() onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] ??= 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isAuthAttempt = err.requestOptions.extra['authAttempt'] == true;
    if (err.response?.statusCode == 401 && !isAuthAttempt) {
      onUnauthorized();
    }
    handler.next(err);
  }
}
