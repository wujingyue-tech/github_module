import 'package:flutter/foundation.dart';
import 'package:learn_flutter/core/analytics/analytics_policy.dart';
import 'package:learn_flutter/core/analytics/posthog/sanitize_posthog_event.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Maps [AnalyticsPolicy] onto posthog_flutter. Empty [apiKey] skips init.
///
/// Flutter web still needs the posthog-js snippet in `web/index.html`; this
/// Dart setup is what iOS/Android (and tests) actually use.
Future<void> initPosthog({
  required String apiKey,
  required String host,
}) async {
  if (apiKey.isEmpty) return;
  final config = PostHogConfig(apiKey, beforeSend: [sanitizePosthogEvent]);
  if (host.isNotEmpty) config.host = host;
  config.debug = kDebugMode;
  config.flushAt = kDebugMode
      ? AnalyticsPolicy.flushAtDebug
      : AnalyticsPolicy.flushAtRelease;
  config.flushInterval = kDebugMode
      ? AnalyticsPolicy.flushIntervalDebug
      : AnalyticsPolicy.flushIntervalRelease;
  config.personProfiles = AnalyticsPolicy.identifiedOnly
      ? PostHogPersonProfiles.identifiedOnly
      : PostHogPersonProfiles.never;
  config.captureApplicationLifecycleEvents =
      AnalyticsPolicy.captureLifecycleEvents;
  config.sessionReplay = AnalyticsPolicy.captureSessionReplay;
  config.surveys = AnalyticsPolicy.captureSurveys;
  config.rageClickConfig.enabled = AnalyticsPolicy.captureRageClicks;
  config.preloadFeatureFlags = AnalyticsPolicy.preloadFeatureFlags;
  config.sendFeatureFlagEvents = AnalyticsPolicy.sendFeatureFlagEvents;
  config.capturePushNotificationOpened =
      AnalyticsPolicy.capturePushNotifications;
  config.capturePushNotificationSubscriptions =
      AnalyticsPolicy.capturePushNotifications;
  config.errorTrackingConfig.captureFlutterErrors =
      AnalyticsPolicy.captureExceptions;
  config.errorTrackingConfig.capturePlatformDispatcherErrors =
      AnalyticsPolicy.captureExceptions;
  config.errorTrackingConfig.captureIsolateErrors =
      AnalyticsPolicy.captureExceptions;
  await Posthog().setup(config);
}
