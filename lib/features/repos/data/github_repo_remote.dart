import 'package:dio/dio.dart';
import 'package:github_module/core/error/app_exception.dart';
import 'package:github_module/core/error/map_dio_exception.dart';
import 'package:github_module/core/network/dio_cancel.dart';
import 'package:github_module/core/request_cancel.dart';
import 'package:github_module/features/repos/domain/repo_repository.dart';

import 'repo_dto.dart';

class GitHubRepoRemote {
  GitHubRepoRemote(this._dio);

  final Dio _dio;

  Future<List<RepoDto>> listRepos({
    required int page,
    Map<String, String>? headers,
    RequestCancel? cancel,
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
        cancelToken: cancelTokenFor(cancel),
      );
      final data = response.data;
      if (data == null) return [];
      return data
          .map((e) => RepoDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw const RequestCancelledException();
      }
      throw mapDioException(e);
    } on AppException {
      rethrow;
    } on RequestCancelledException {
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
