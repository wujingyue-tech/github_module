import 'package:learn_flutter/core/logging/app_log.dart';
import 'package:learn_flutter/core/logging/crash_reporter.dart';
import 'package:learn_flutter/core/logging/should_report.dart';
import 'package:talker/talker.dart';

class TalkerAppLog implements AppLog {
  TalkerAppLog(
    this._talker, {
    this._crashReporter = const NoOpCrashReporter(),
  });

  final Talker _talker;
  final CrashReporter _crashReporter;

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.debug(message, error, stackTrace);
  }

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.info(message, error, stackTrace);
  }

  @override
  void warn(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.warning(message, error, stackTrace);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.error(message, error, stackTrace);
  }

  @override
  void report(Object error, [StackTrace? stackTrace, String? hint]) {
    if (!shouldReport(error)) return;
    _talker.handle(error, stackTrace, hint);
    _crashReporter.capture(error, stackTrace, hint);
  }
}
