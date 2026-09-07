import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/core/error/map_dio_exception.dart';

void main() {
  group('mapDioException', () {
    test('maps 401 to invalidToken', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/user'),
        response: Response(
          requestOptions: RequestOptions(path: '/user'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );
      expect(mapDioException(error).code, AppErrorCode.invalidToken);
    });

    test('maps 429 to rateLimited', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/user'),
        response: Response(
          requestOptions: RequestOptions(path: '/user'),
          statusCode: 429,
        ),
        type: DioExceptionType.badResponse,
      );
      expect(mapDioException(error).code, AppErrorCode.rateLimited);
    });

    test('maps 403 with remaining 0 to rateLimited', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/user'),
        response: Response(
          requestOptions: RequestOptions(path: '/user'),
          statusCode: 403,
          headers: Headers.fromMap({
            'x-ratelimit-remaining': ['0'],
          }),
        ),
        type: DioExceptionType.badResponse,
      );
      expect(mapDioException(error).code, AppErrorCode.rateLimited);
    });

    test('maps connectionError to offline', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/user'),
        type: DioExceptionType.connectionError,
      );
      expect(mapDioException(error).code, AppErrorCode.offline);
    });

    test('maps timeout types to timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/user'),
        type: DioExceptionType.receiveTimeout,
      );
      expect(mapDioException(error).code, AppErrorCode.timeout);
    });

    test('keeps the original DioException as cause', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/user'),
        type: DioExceptionType.connectionError,
      );
      final mapped = mapDioException(error);
      expect(mapped.code, AppErrorCode.offline);
      expect(mapped.cause, same(error));
    });
  });
}
