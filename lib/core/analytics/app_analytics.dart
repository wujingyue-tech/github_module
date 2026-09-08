/// Product analytics port. Empty API key uses [NoOpAppAnalytics].
///
/// Implementations live under `posthog/`. Pages must not import the vendor SDK.
abstract interface class AppAnalytics {
  Future<void> screen(String name);

  Future<void> event(String name, [Map<String, Object>? properties]);

  /// Sets the user id (GitHub login). Null or empty [id] is a no-op.
  /// Logout calls [reset], never [identify]. Never pass a token, email, or
  /// display name.
  Future<void> identify({String? id});

  Future<void> reset();

  /// Push the local queue now (app background / process teardown).
  Future<void> flush();
}

class NoOpAppAnalytics implements AppAnalytics {
  const NoOpAppAnalytics();

  @override
  Future<void> screen(String name) async {}

  @override
  Future<void> event(String name, [Map<String, Object>? properties]) async {}

  @override
  Future<void> identify({String? id}) async {}

  @override
  Future<void> reset() async {}

  @override
  Future<void> flush() async {}
}
