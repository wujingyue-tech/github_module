import 'package:learn_flutter/core/logging/app_log.dart';

class NoOpAppLog implements AppLog {
  const NoOpAppLog();

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void warn(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void report(Object error, [StackTrace? stackTrace, String? hint]) {}
}
