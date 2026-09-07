import 'package:dio/dio.dart';

import 'app_exception.dart';

AppException mapDioException(DioException error) {
  return AppException(
    _codeFor(error),
    cause: error,
    stackTrace: error.stackTrace,
  );
}

AppErrorCode _codeFor(DioException error) {
  if (error.type == DioExceptionType.connectionError) {
    return AppErrorCode.offline;
  }
  final status = error.response?.statusCode;
  if (status == 401) return AppErrorCode.invalidToken;
  if (status == 429) return AppErrorCode.rateLimited;
  if (status == 403) {
    final remaining = error.response?.headers.value('x-ratelimit-remaining');
    if (remaining == '0') return AppErrorCode.rateLimited;
    return AppErrorCode.forbidden;
  }
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return AppErrorCode.timeout;
  }
  return AppErrorCode.failed;
}
