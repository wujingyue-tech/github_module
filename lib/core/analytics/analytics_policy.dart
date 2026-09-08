import 'package:learn_flutter/core/logging/sanitize_log_dump.dart';

/// What this app is willing to send to any product-analytics backend.
///
/// Vendor option names belong in `posthog/`. Keep this file free of
/// `posthog_flutter` so upgrades remap flags here → SDK, without rewriting
/// the rules.
abstract final class AnalyticsPolicy {
  static const captureLifecycleEvents = false;
  static const captureSessionReplay = false;
  static const captureSurveys = false;
  static const captureRageClicks = false;
  static const capturePushNotifications = false;
  static const preloadFeatureFlags = false;
  static const sendFeatureFlagEvents = false;
  static const captureExceptions = false;
  static const identifiedOnly = true;

  /// Debug: send each event so Activity and the install wizard can verify.
  /// Release: batch like the SDK default (cheaper radio, fine for funnels).
  static const flushAtDebug = 1;
  static const flushAtRelease = 20;
  static const flushIntervalDebug = Duration(seconds: 5);
  static const flushIntervalRelease = Duration(seconds: 30);

  static const loginSuccess = 'login_success';
  static const loginFailure = 'login_failure';
  static const logout = 'logout';
  static const repoLoadMore = 'repo_load_more';
  static const repoLoadMoreFailure = 'repo_load_more_failure';

  static const trackedScreens = {'/login', '/settings', '/repos', '/profile'};

  static bool shouldTrackScreen(String path) => trackedScreens.contains(path);

  static bool shouldSendEvent(String name) {
    if (name == r'$exception') return false;
    return true;
  }

  static String redact(String raw) => sanitizeLogDump(raw);
}
