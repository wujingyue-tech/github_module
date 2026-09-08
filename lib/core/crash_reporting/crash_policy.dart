import 'package:learn_flutter/core/logging/sanitize_log_dump.dart';
import 'package:learn_flutter/core/logging/should_report.dart';

/// What this app is willing to send to any crash backend.
///
/// Vendor option names belong in `sentry/`. Keep this file free of
/// `sentry_flutter` so upgrades remap flags here → SDK, without rewriting
/// the rules.
abstract final class CrashPolicy {
  static const sendDefaultPii = false;
  static const sendScreenshots = false;
  static const sendViewHierarchy = false;
  static const sendSessionReplay = false;
  static const sendFailedHttp = false;
  static const sendDebugLogs = false;
  static const sendPerformanceTraces = false;
  static const sendRequestBodies = false;
  static const sendRequestHeaders = false;
  static const sendRequestCookies = false;

  /// Method + URL only; no headers or body.
  static const sendRequestUrlAndMethod = true;

  static bool shouldUpload(Object error) => shouldReport(error);

  static String redact(String raw) => sanitizeLogDump(raw);
}
