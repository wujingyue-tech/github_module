import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/core/logging/should_report.dart';
import 'package:learn_flutter/core/request_cancel.dart';

void main() {
  test('does not report cancel or empty token', () {
    expect(shouldReport(const RequestCancelledException()), isFalse);
    expect(shouldReport(AppException(AppErrorCode.emptyToken)), isFalse);
  });

  test('reports unexpected failures', () {
    expect(shouldReport(AppException(AppErrorCode.offline)), isTrue);
    expect(shouldReport(StateError('keychain')), isTrue);
  });
}
