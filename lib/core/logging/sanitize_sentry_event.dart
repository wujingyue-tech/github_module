import 'package:learn_flutter/core/logging/sanitize_log_dump.dart';
import 'package:learn_flutter/core/logging/should_report.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Last-chance filter: drop expected errors, strip tokens / PII / bodies.
SentryEvent? sanitizeSentryEvent(SentryEvent event, Hint hint) {
  final throwable = event.throwable;
  if (throwable is Object && !shouldReport(throwable)) {
    return null;
  }

  hint.screenshot = null;
  hint.viewHierarchy = null;
  hint.response = null;
  hint.attachments.clear();

  event.serverName = null;
  event.request = _stripRequest(event.request);
  event.user = _stripUser(event.user);

  final message = event.message;
  if (message != null) {
    message.formatted = sanitizeLogDump(message.formatted);
    final template = message.template;
    if (template != null) {
      message.template = sanitizeLogDump(template);
    }
  }

  final exceptions = event.exceptions;
  if (exceptions != null) {
    for (final exception in exceptions) {
      final value = exception.value;
      if (value != null) {
        exception.value = sanitizeLogDump(value);
      }
    }
  }

  final breadcrumbs = event.breadcrumbs;
  if (breadcrumbs != null) {
    for (final crumb in breadcrumbs) {
      final crumbMessage = crumb.message;
      if (crumbMessage != null) {
        crumb.message = sanitizeLogDump(crumbMessage);
      }
      crumb.data = _sanitizeMap(crumb.data);
    }
  }

  final tags = event.tags;
  if (tags != null) {
    event.tags = {
      for (final entry in tags.entries) entry.key: sanitizeLogDump(entry.value),
    };
  }

  // ignore: deprecated_member_use
  final extra = event.extra;
  if (extra != null) {
    for (final key in extra.keys.toList()) {
      final value = extra[key];
      if (value is String) {
        extra[key] = sanitizeLogDump(value);
      }
    }
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
  return SentryRequest(url: request.url, method: request.method);
}

Map<String, dynamic>? _sanitizeMap(Map<String, dynamic>? data) {
  if (data == null) return null;
  return {
    for (final entry in data.entries)
      entry.key: switch (entry.value) {
        final String value => sanitizeLogDump(value),
        final Map<String, dynamic> nested => _sanitizeMap(nested),
        final value => value,
      },
  };
}
