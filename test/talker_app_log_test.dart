import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/core/logging/talker_app_log.dart';
import 'package:learn_flutter/core/request_cancel.dart';
import 'package:talker/talker.dart';

void main() {
  test('report skips expected errors', () {
    final talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    final log = TalkerAppLog(talker);

    log.report(AppException(AppErrorCode.emptyToken));
    log.report(const RequestCancelledException());

    expect(talker.history, isEmpty);
  });

  test('report records unexpected errors', () {
    final talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    final log = TalkerAppLog(talker);

    log.report(AppException(AppErrorCode.offline), StackTrace.current, 'test');

    expect(talker.history, isNotEmpty);
  });
}
