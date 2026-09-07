import 'package:dio/dio.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// Dio logger that never prints Authorization (or other auth headers).
Interceptor createHttpLogInterceptor(Talker talker) {
  return TalkerDioLogger(
    talker: talker,
    settings: TalkerDioLoggerSettings(
      printRequestHeaders: false,
      printErrorHeaders: false,
      printRequestData: false,
      printResponseTime: true,
      hiddenHeaders: const {'Authorization', 'authorization'},
      errorFilter: (error) => error.type != DioExceptionType.cancel,
    ),
  );
}
