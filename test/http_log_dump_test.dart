import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/core/error/app_exception.dart';
import 'package:github_module/core/logging/http_log_dump.dart';
import 'package:talker/talker.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter({required this.status, required this.body});

  final int status;
  final String body;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  Talker talkerWithSecret() {
    final talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    talker.info('token ghp_secretTokenValue');
    return talker;
  }

  test('throws when the dump URL is empty', () async {
    final dump = HttpLogDump(
      talker: Talker(settings: TalkerSettings(useConsoleLogs: false)),
      dio: Dio(),
      endpoint: '',
    );
    expectLater(
      dump.upload(),
      throwsA(
        isA<AppException>().having(
          (e) => e.code,
          'code',
          AppErrorCode.logDumpUnavailable,
        ),
      ),
    );
  });

  test('POSTs sanitized history and returns the dump id', () async {
    final adapter = _Adapter(status: 200, body: '{"id":"abc-1"}');
    final dio = Dio()..httpClientAdapter = adapter;
    final dump = HttpLogDump(
      talker: talkerWithSecret(),
      dio: dio,
      endpoint: 'https://dumps.example/upload',
    );

    final report = await dump.upload();

    expect(report.id, 'abc-1');
    expect(adapter.last?.method, 'POST');
    expect(adapter.last?.uri.toString(), 'https://dumps.example/upload');
    expect(dump.exportText(), isNot(contains('ghp_secretTokenValue')));
  });
}
