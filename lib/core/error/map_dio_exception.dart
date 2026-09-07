import 'package:dio/dio.dart';

import 'app_exception.dart';

AppException mapDioException(DioException error) {
  if (error.type == DioExceptionType.connectionError) {
    return AppException(AppErrorCode.offline);
  }
  final status = error.response?.statusCode;
  if (status == 401) {
    return AppException(AppErrorCode.invalidToken);
  }
  if (status == 429) {
    return AppException(AppErrorCode.rateLimited);
  }
  if (status == 403) {
    final remaining = error.response?.headers.value('x-ratelimit-remaining');
    if (remaining == '0') {
      return AppException(AppErrorCode.rateLimited);
    }
    return AppException(AppErrorCode.forbidden);
  }
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return AppException(AppErrorCode.timeout);
  }
  return AppException(AppErrorCode.failed);
}
