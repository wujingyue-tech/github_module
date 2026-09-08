import 'package:learn_flutter/core/crash_reporting/crash_policy.dart';
import 'package:learn_flutter/core/crash_reporting/sentry/sanitize_sentry_event.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Maps [CrashPolicy] onto sentry_flutter. Empty [dsn] skips init.
Future<void> initSentry({
  required String dsn,
  required String environment,
  required String release,
  required String dist,
}) async {
  if (dsn.isEmpty) return;
  await SentryFlutter.init((options) {
    options.dsn = dsn;
    options.environment = environment;
    options.release = release;
    options.dist = dist;
    _applyPolicy(options);
    options.beforeSend = sanitizeSentryEvent;
    _dropHooksAlreadyOwnedByAppLog(options);
  });
}

void _applyPolicy(SentryFlutterOptions options) {
  options.sendDefaultPii = CrashPolicy.sendDefaultPii;
  options.attachScreenshot = CrashPolicy.sendScreenshots;
  options.captureFailedRequests = CrashPolicy.sendFailedHttp;
  options.captureNativeFailedRequests = CrashPolicy.sendFailedHttp;
  options.enableLogs = CrashPolicy.sendDebugLogs;
  options.enableAutoPerformanceTracing = CrashPolicy.sendPerformanceTraces;
  options.tracesSampleRate = CrashPolicy.sendPerformanceTraces ? 1 : 0;
  options.enableUserInteractionTracing = CrashPolicy.sendPerformanceTraces;
  options.enableFramesTracking = CrashPolicy.sendPerformanceTraces;
  options.enableUserInteractionBreadcrumbs = false;
  options.reportSilentFlutterErrors = false;
  options.maxRequestBodySize = CrashPolicy.sendRequestBodies
      ? MaxRequestBodySize.always
      : MaxRequestBodySize.never;
  options.replay.sessionSampleRate = CrashPolicy.sendSessionReplay ? 0.1 : 0;
  options.replay.onErrorSampleRate = CrashPolicy.sendSessionReplay ? 1 : 0;
}

/// Dart errors go through `AppLog.report` → `CrashReporter`. Sentry's own
/// FlutterError / PlatformDispatcher hooks would duplicate them.
///
/// `FlutterErrorIntegration` is not exported; match by type name. Revisit
/// when upgrading sentry_flutter — the class name or list API may change.
void _dropHooksAlreadyOwnedByAppLog(SentryFlutterOptions options) {
  for (final integration in List<Integration>.of(options.integrations)) {
    final name = integration.runtimeType.toString();
    if (integration is OnErrorIntegration || name == 'FlutterErrorIntegration') {
      options.removeIntegration(integration);
    }
  }
}
