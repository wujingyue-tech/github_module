import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/analytics/posthog/sanitize_posthog_event.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

void main() {
  test('drops exception events', () {
    final event = PostHogEvent(event: r'$exception');
    expect(sanitizePosthogEvent(event), isNull);
  });

  test('drops screens outside the allowlist', () {
    final logs = PostHogEvent(
      event: r'$screen',
      properties: const {r'$screen_name': '/logs'},
    );
    final repos = PostHogEvent(
      event: r'$screen',
      properties: const {r'$screen_name': '/repos'},
    );

    expect(sanitizePosthogEvent(logs), isNull);
    expect(sanitizePosthogEvent(repos)?.event, r'$screen');
  });

  test('redacts tokens in properties', () {
    final event = PostHogEvent(
      event: 'login_failure',
      properties: const {'note': 'failed Authorization: Bearer ghp_abc123XYZ'},
      userProperties: const {'token': 'github_pat_11AAAA_bbbb'},
    );

    final out = sanitizePosthogEvent(event)!;
    expect(out.properties!['note'], isNot(contains('ghp_')));
    expect(out.properties!['note'], contains('[redacted]'));
    expect(out.userProperties!['token'], isNot(contains('github_pat_')));
  });
}
