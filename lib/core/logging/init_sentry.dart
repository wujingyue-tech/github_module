import 'package:learn_flutter/core/logging/sanitize_sentry_event.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Initializes Sentry when [dsn] is non-empty. Compatible with sentry.io,
/// self-hosted Sentry, and GlitchTip.
///
/// Dart errors still go through `AppLog.report`; FlutterError / Zone
/// integrations are removed so events are not sent twice. Native crashes stay
/// on the native SDK.
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
    options.sendDefaultPii = false;
    options.captureFailedRequests = false;
    options.captureNativeFailedRequests = false;
    options.maxRequestBodySize = MaxRequestBodySize.never;
    options.attachScreenshot = false;
    options.enableAutoPerformanceTracing = false;
    options.tracesSampleRate = 0;
    options.enableLogs = false;
    options.enableUserInteractionTracing = false;
    options.enableUserInteractionBreadcrumbs = false;
    options.reportSilentFlutterErrors = false;
    options.enableFramesTracking = false;
    options.replay.sessionSampleRate = 0;
    options.replay.onErrorSampleRate = 0;
    options.beforeSend = sanitizeSentryEvent;
    for (final integration in List<Integration>.of(options.integrations)) {
      final name = integration.runtimeType.toString();
      if (integration is OnErrorIntegration ||
          name == 'FlutterErrorIntegration') {
        options.removeIntegration(integration);
      }
    }
  });
}
