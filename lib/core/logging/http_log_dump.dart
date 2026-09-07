import 'package:dio/dio.dart';
import 'package:learn_flutter/core/app_info.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/core/error/map_dio_exception.dart';
import 'package:learn_flutter/core/logging/log_dump.dart';
import 'package:learn_flutter/core/logging/sanitize_log_dump.dart';
import 'package:talker/talker.dart';

class HttpLogDump implements LogDump {
  HttpLogDump({
    required this.talker,
    required this.dio,
    required this.endpoint,
    this.appInfo = AppInfo.unset,
  });

  final Talker talker;
  final Dio dio;
  final String endpoint;
  final AppInfo appInfo;

  @override
  String exportText() => sanitizeLogDump(talker.history.text());

  @override
  Future<LogDumpReport> upload() async {
    if (endpoint.isEmpty) {
      throw AppException(AppErrorCode.logDumpUnavailable);
    }
    try {
      final response = await dio.post<dynamic>(
        endpoint,
        data: {
          'logs': exportText(),
          'version': appInfo.version,
          'buildNumber': appInfo.buildNumber,
        },
        options: Options(
          headers: const {Headers.contentTypeHeader: Headers.jsonContentType},
        ),
      );
      final id = _idFrom(response.data);
      if (id == null || id.isEmpty) {
        throw AppException(AppErrorCode.parseFailed);
      }
      return LogDumpReport(id: id);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  String? _idFrom(Object? data) {
    if (data is Map) {
      return data['id']?.toString();
    }
    return null;
  }
}
