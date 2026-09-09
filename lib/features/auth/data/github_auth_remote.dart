import 'package:dio/dio.dart';
import 'package:github_module/core/error/app_exception.dart';
import 'package:github_module/core/error/map_dio_exception.dart';

import 'user_dto.dart';

class GitHubAuthRemote {
  GitHubAuthRemote(this._dio);

  final Dio _dio;

  Future<UserDto> getUser({String? token, Map<String, String>? headers}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/user',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            ...?headers,
          },
          extra: {if (token != null) 'authAttempt': true},
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
    } catch (error, stackTrace) {
      throw AppException(
        AppErrorCode.parseFailed,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
