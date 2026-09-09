import 'package:github_module/core/request_cancel.dart';
import 'package:github_module/features/repos/domain/repo.dart';
import 'package:github_module/features/repos/domain/repo_repository.dart';

import 'github_repo_remote.dart';

class RepoRepositoryImpl implements RepoRepository {
  RepoRepositoryImpl(this._remote);

  final GitHubRepoRemote _remote;

  @override
  Future<List<Repo>> listRepos({
    required int page,
    Map<String, String>? headers,
    RequestCancel? cancel,
  }) async {
    final dtos = await _remote.listRepos(
      page: page,
      headers: headers,
      cancel: cancel,
    );
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
