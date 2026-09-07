abstract interface class AppLog {
  void debug(String message, {Object? error, StackTrace? stackTrace});
  void info(String message, {Object? error, StackTrace? stackTrace});
  void warn(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});

  /// Uncaught / unexpected failures. No-ops for expected cases
  /// (cancel, empty token). See [shouldReport].
  void report(Object error, [StackTrace? stackTrace, String? hint]);
}
