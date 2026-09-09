import 'package:github_module/core/crash_reporting/crash_reporter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryCrashReporter implements CrashReporter {
  @override
  void capture(Object error, [StackTrace? stackTrace, String? hint]) {
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (hint != null && hint.isNotEmpty) {
          scope.setTag('source', hint);
        }
      },
    );
  }

  @override
  void setUser({String? id}) {
    Sentry.configureScope((scope) {
      if (id == null || id.isEmpty) {
        scope.setUser(null);
      } else {
        scope.setUser(SentryUser(id: id));
      }
    });
  }
}
