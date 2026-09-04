import 'package:dio/dio.dart';

import '../common/global.dart';
import '../models/repo.dart';
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

  static const pageSize = 20;

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
      throw _fromDio(e);
    }
  }

  static Future<User> fetchCurrentUser({bool refresh = false}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/user',
        options: Options(
          extra: {if (refresh) 'refresh': true},
        ),
      );
      final data = response.data;
      if (data == null) {
        throw AuthException(AuthErrorCode.emptyResponse);
      }
      final user = User.fromJson(data);
      Global.profile = Global.profile.copyWith(
        user: user,
        lastLogin: user.login,
      );
      await Global.saveProfile();
      return user;
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  static Future<List<Repo>> listRepos({
    required int page,
    bool refresh = false,
  }) async {
    try {
      final response = await apiClient.get<List<dynamic>>(
        '/user/repos',
        queryParameters: {
          'sort': 'updated',
          'per_page': pageSize,
          'page': page,
        },
        options: Options(
          extra: {
            if (refresh) 'refresh': true,
            if (refresh) 'list': true,
          },
        ),
      );
      final data = response.data;
      if (data == null) return [];
      return data
          .map((e) => Repo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  static Future<void> logout() async {
    Global.profile = Global.profile.copyWith(
      clearToken: true,
      clearUser: true,
    );
    await Global.saveProfile();
  }

  static AuthException _fromDio(DioException e) {
    if (e.response?.statusCode == 401) {
      return AuthException(AuthErrorCode.invalidToken);
    }
    if (e.response?.statusCode == 403) {
      return AuthException(AuthErrorCode.forbidden);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AuthException(AuthErrorCode.timeout);
    }
    return AuthException(AuthErrorCode.failed);
  }
}
