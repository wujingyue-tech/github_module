/// Remote crash sink. Empty DSN uses [NoOpCrashReporter].
abstract interface class CrashReporter {
  void capture(Object error, [StackTrace? stackTrace, String? hint]);

  /// Sets the affected user id (GitHub login). Null clears it.
  /// Never pass a token, email, or display name.
  void setUser({String? id});
}

class NoOpCrashReporter implements CrashReporter {
  const NoOpCrashReporter();

  @override
  void capture(Object error, [StackTrace? stackTrace, String? hint]) {}

  @override
  void setUser({String? id}) {}
}
