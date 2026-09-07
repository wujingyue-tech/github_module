import 'package:dio/dio.dart';

import 'app_config.dart';

Dio createDio(AppConfig config) {
  return Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      headers: {
        Headers.acceptHeader: 'application/vnd.github+json',
        'X-GitHub-Api-Version': config.apiVersion,
      },
    ),
  );
}
