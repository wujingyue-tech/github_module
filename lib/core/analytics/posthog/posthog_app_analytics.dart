import 'package:learn_flutter/core/analytics/analytics_policy.dart';
import 'package:learn_flutter/core/analytics/app_analytics.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class PosthogAppAnalytics implements AppAnalytics {
  @override
  Future<void> screen(String name) {
    if (!AnalyticsPolicy.shouldTrackScreen(name)) return Future.value();
    return Posthog().screen(screenName: name);
  }

  @override
  Future<void> event(String name, [Map<String, Object>? properties]) {
    return Posthog().capture(eventName: name, properties: _redact(properties));
  }

  @override
  Future<void> identify({String? id}) {
    if (id == null || id.isEmpty) return Future.value();
    return Posthog().identify(userId: id);
  }

  @override
  Future<void> reset() => Posthog().reset();

  @override
  Future<void> flush() => Posthog().flush();

  Map<String, Object>? _redact(Map<String, Object>? properties) {
    if (properties == null) return null;
    return {
      for (final entry in properties.entries)
        entry.key: switch (entry.value) {
          final String value => AnalyticsPolicy.redact(value),
          final value => value,
        },
    };
  }
}
