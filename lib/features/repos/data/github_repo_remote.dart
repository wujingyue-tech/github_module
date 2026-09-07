import 'package:dio/dio.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/core/error/map_dio_exception.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';

import 'repo_dto.dart';

class GitHubRepoRemote {
  GitHubRepoRemote(this._dio);

  final Dio _dio;

  Future<List<RepoDto>> listRepos({
    required int page,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/user/repos',
        queryParameters: {
          'sort': 'updated',
          'per_page': RepoRepository.pageSize,
          'page': page,
        },
        options: Options(headers: headers),
      );
      final data = response.data;
      if (data == null) return [];
      return data
          .map((e) => RepoDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException(AppErrorCode.parseFailed);
    }
  }
}
