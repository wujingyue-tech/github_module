import 'package:dio/dio.dart';

import '../common/global.dart';
import '../models/user.dart';
import 'api_client.dart';

enum AuthErrorCode {
  emptyToken,
  emptyResponse,
  invalidToken,
  forbidden,
  timeout,
  failed,
}

class AuthException implements Exception {
  AuthException(this.code);
  final AuthErrorCode code;
}

class GitHubApi {
  GitHubApi._();

  /// 用 Personal Access Token 调 `GET /user` 验证身份。
  static Future<User> login(String token) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/user',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          extra: {'noCache': true},
        ),
      );
      final data = response.data;
      if (data == null) {
        throw AuthException(AuthErrorCode.emptyResponse);
      }
      final user = User.fromJson(data);
      Global.profile = Global.profile.copyWith(
        token: token,
        user: user,
        lastLogin: user.login,
      );
      await Global.saveProfile();
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException(AuthErrorCode.invalidToken);
      }
      if (e.response?.statusCode == 403) {
        throw AuthException(AuthErrorCode.forbidden);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw AuthException(AuthErrorCode.timeout);
      }
      throw AuthException(AuthErrorCode.failed);
    }
  }

  static Future<void> logout() async {
    Global.profile = Global.profile.copyWith(
      clearToken: true,
      clearUser: true,
    );
    await Global.saveProfile();
  }
}
