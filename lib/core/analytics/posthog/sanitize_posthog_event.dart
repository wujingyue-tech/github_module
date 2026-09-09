import 'package:github_module/core/analytics/analytics_policy.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Last-chance map of [AnalyticsPolicy] onto a PostHog event.
PostHogEvent? sanitizePosthogEvent(PostHogEvent event) {
  if (!AnalyticsPolicy.shouldSendEvent(event.event)) return null;

  if (event.event == r'$screen') {
    final name = event.properties?[r'$screen_name'];
    if (name is! String || !AnalyticsPolicy.shouldTrackScreen(name)) {
      return null;
    }
  }

  event.properties = _redactProps(event.properties);
  event.userProperties = _redactProps(event.userProperties);
  event.userPropertiesSetOnce = _redactProps(event.userPropertiesSetOnce);
  return event;
}

Map<String, Object>? _redactProps(Map<String, Object>? properties) {
  if (properties == null) return null;
  return {
    for (final entry in properties.entries)
      entry.key: switch (entry.value) {
        final String value => AnalyticsPolicy.redact(value),
        final value => value,
      },
  };
}
