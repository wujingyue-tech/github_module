import 'package:learn_flutter/core/crash_reporting/crash_policy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Last-chance map of [CrashPolicy] onto a Sentry event.
SentryEvent? sanitizeSentryEvent(SentryEvent event, Hint hint) {
  final throwable = event.throwable;
  if (throwable is Object && !CrashPolicy.shouldUpload(throwable)) {
    return null;
  }

  if (!CrashPolicy.sendScreenshots) {
    hint.screenshot = null;
    hint.attachments.clear();
  }
  if (!CrashPolicy.sendViewHierarchy) {
    hint.viewHierarchy = null;
  }
  hint.response = null;

  event.serverName = null;
  event.request = _stripRequest(event.request);
  event.user = _stripUser(event.user);
  // ignore: deprecated_member_use
  event.extra = null;

  final message = event.message;
  if (message != null) {
    message.formatted = CrashPolicy.redact(message.formatted);
    final template = message.template;
    if (template != null) {
      message.template = CrashPolicy.redact(template);
    }
  }

  final exceptions = event.exceptions;
  if (exceptions != null) {
    for (final exception in exceptions) {
      final value = exception.value;
      if (value != null) {
        exception.value = CrashPolicy.redact(value);
      }
    }
  }

  final breadcrumbs = event.breadcrumbs;
  if (breadcrumbs != null) {
    for (final crumb in breadcrumbs) {
      final crumbMessage = crumb.message;
      if (crumbMessage != null) {
        crumb.message = CrashPolicy.redact(crumbMessage);
      }
      crumb.data = _redactMap(crumb.data);
    }
  }

  final tags = event.tags;
  if (tags != null) {
    event.tags = {
      for (final entry in tags.entries)
        entry.key: CrashPolicy.redact(entry.value),
    };
  }

  return event;
}

SentryUser? _stripUser(SentryUser? user) {
  final id = user?.id;
  if (id == null || id.isEmpty) return null;
  return SentryUser(id: id);
}

SentryRequest? _stripRequest(SentryRequest? request) {
  if (request == null) return null;
  if (!CrashPolicy.sendRequestUrlAndMethod) return null;
  return SentryRequest(
    url: request.url,
    method: request.method,
    headers: CrashPolicy.sendRequestHeaders ? request.headers : null,
    cookies: CrashPolicy.sendRequestCookies ? request.cookies : null,
    data: CrashPolicy.sendRequestBodies ? request.data : null,
  );
}

Map<String, dynamic>? _redactMap(Map<String, dynamic>? data) {
  if (data == null) return null;
  return {
    for (final entry in data.entries)
      entry.key: switch (entry.value) {
        final String value => CrashPolicy.redact(value),
        final Map<String, dynamic> nested => _redactMap(nested),
        final value => value,
      },
  };
}
