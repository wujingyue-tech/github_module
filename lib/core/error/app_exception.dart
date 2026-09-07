enum AppErrorCode {
  emptyToken,
  emptyResponse,
  invalidToken,
  forbidden,
  rateLimited,
  timeout,
  offline,
  parseFailed,
  failed,
}

class AppException implements Exception {
  AppException(this.code);
  final AppErrorCode code;

  @override
  String toString() => 'AppException($code)';
}
