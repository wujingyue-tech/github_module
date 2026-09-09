import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/core/network/auth_interceptor.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.status);

  final int status;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
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
  test('401 clears session except login attempts', () async {
    var unauthorized = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com/'))
      ..httpClientAdapter = _Adapter(401)
      ..interceptors.add(
        AuthInterceptor(
          readToken: () => 'stored',
          onUnauthorized: () => unauthorized++,
        ),
      );

    await expectLater(
      dio.get<void>('/user/repos'),
      throwsA(isA<DioException>()),
    );
    expect(unauthorized, 1);

    unauthorized = 0;
    await expectLater(
      dio.get<void>('/user', options: Options(extra: {'authAttempt': true})),
      throwsA(isA<DioException>()),
    );
    expect(unauthorized, 0);
  });
}
