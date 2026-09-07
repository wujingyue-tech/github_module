import 'package:learn_flutter/core/logging/log_dump.dart';

class FakeLogDump implements LogDump {
  FakeLogDump({this.text = '', this.report, this.error});

  final String text;
  final LogDumpReport? report;
  final Object? error;
  var uploadCount = 0;

  @override
  String exportText() => text;

  @override
  Future<LogDumpReport> upload() async {
    uploadCount++;
    final thrown = error;
    if (thrown != null) {
      throw thrown;
    }
    return report ?? const LogDumpReport(id: 'dump-1');
  }
}
