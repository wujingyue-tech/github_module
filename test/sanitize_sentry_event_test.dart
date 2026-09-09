import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/core/error/app_exception.dart';
import 'package:github_module/core/crash_reporting/sentry/sanitize_sentry_event.dart';
import 'package:github_module/core/request_cancel.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  test('drops expected errors', () {
    final cancelled = SentryEvent(throwable: const RequestCancelledException());
    final emptyToken = SentryEvent(
      throwable: AppException(AppErrorCode.emptyToken),
    );

    expect(sanitizeSentryEvent(cancelled, Hint()), isNull);
    expect(sanitizeSentryEvent(emptyToken, Hint()), isNull);
  });

  test('redacts tokens and strips request bodies, cookies, and PII', () {
    final event = SentryEvent(
      message: SentryMessage('failed Authorization: Bearer ghp_abc123XYZ'),
      throwable: StateError('boom'),
      user: SentryUser(
        id: 'octocat',
        email: 'octocat@example.com',
        username: 'Octocat',
        ipAddress: '1.2.3.4',
      ),
      request: SentryRequest(
        url: 'https://api.github.com/user',
        method: 'GET',
        cookies: 'session=secret',
        data: '{"token":"github_pat_11AAAA_bbbb"}',
        headers: const {'Authorization': 'Bearer ghp_abc123XYZ'},
      ),
      breadcrumbs: [
        Breadcrumb(
          message: 'github_pat_11AAAA_bbbb',
          data: const {'Authorization': 'token ghp_abc123XYZ'},
        ),
      ],
      tags: const {'note': 'ghp_abc123XYZ'},
    );
    final hint = Hint()
      ..screenshot = SentryAttachment.fromIntList(const [1], 'shot.png')
      ..response = SentryResponse();

    final out = sanitizeSentryEvent(event, hint)!;

    expect(out.message!.formatted, isNot(contains('ghp_')));
    expect(out.message!.formatted, contains('[redacted]'));
    expect(out.user?.id, 'octocat');
    expect(out.user?.email, isNull);
    expect(out.user?.username, isNull);
    expect(out.user?.ipAddress, isNull);
    expect(out.request?.url, 'https://api.github.com/user');
    expect(out.request?.method, 'GET');
    expect(out.request?.cookies, isNull);
    expect(out.request?.data, isNull);
    expect(out.request?.headers, isEmpty);
    expect(out.breadcrumbs!.single.message, isNot(contains('github_pat_')));
    expect(
      out.breadcrumbs!.single.data!['Authorization'],
      contains('[redacted]'),
    );
    expect(out.tags!['note'], '[redacted]');
    // ignore: deprecated_member_use
    expect(out.extra, isNull);
    expect(hint.screenshot, isNull);
    expect(hint.response, isNull);
  });
}
