import 'package:dio/dio.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/core/error/map_dio_exception.dart';

import 'user_dto.dart';

class GitHubAuthRemote {
  GitHubAuthRemote(this._dio);

  final Dio _dio;

  Future<UserDto> getUser({String? token, bool refresh = false}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/user',
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
          extra: {
            if (token != null) 'authAttempt': true,
            if (token != null) 'noCache': true,
            if (refresh) 'refresh': true,
          },
        ),
      );
      final data = response.data;
      if (data == null) {
        throw AppException(AppErrorCode.emptyResponse);
      }
      return UserDto.fromJson(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException(AppErrorCode.parseFailed);
    }
  }
}
