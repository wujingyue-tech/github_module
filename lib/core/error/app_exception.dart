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
  logDumpUnavailable,
}

class AppException implements Exception {
  AppException(this.code, {this.cause, this.stackTrace});

  final AppErrorCode code;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    if (cause == null) return 'AppException($code)';
    return 'AppException($code, cause: $cause)';
  }
}
