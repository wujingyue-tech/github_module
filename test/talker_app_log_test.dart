import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/core/crash_reporting/crash_reporter.dart';
import 'package:learn_flutter/core/logging/talker_app_log.dart';
import 'package:learn_flutter/core/request_cancel.dart';
import 'package:talker/talker.dart';

class _RecordingCrashReporter implements CrashReporter {
  final captures = <Object>[];
  String? userId;

  @override
  void capture(Object error, [StackTrace? stackTrace, String? hint]) {
    captures.add(error);
  }

  @override
  void setUser({String? id}) {
    userId = id;
  }
}

void main() {
  test('report skips expected errors', () {
    final talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    final reporter = _RecordingCrashReporter();
    final log = TalkerAppLog(talker, crashReporter: reporter);

    log.report(AppException(AppErrorCode.emptyToken));
    log.report(const RequestCancelledException());

    expect(talker.history, isEmpty);
    expect(reporter.captures, isEmpty);
  });

  test('report records unexpected errors and forwards to CrashReporter', () {
    final talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    final reporter = _RecordingCrashReporter();
    final log = TalkerAppLog(talker, crashReporter: reporter);

    log.report(AppException(AppErrorCode.offline), StackTrace.current, 'test');

    expect(talker.history, isNotEmpty);
    expect(reporter.captures, hasLength(1));
    expect(reporter.captures.single, isA<AppException>());
  });
}
