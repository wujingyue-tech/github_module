import 'package:learn_flutter/features/repos/domain/repo.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';

import 'github_repo_remote.dart';

class RepoRepositoryImpl implements RepoRepository {
  RepoRepositoryImpl(this._remote);

  final GitHubRepoRemote _remote;

  @override
  Future<List<Repo>> listRepos({
    required int page,
    bool refresh = false,
  }) async {
    final dtos = await _remote.listRepos(page: page, refresh: refresh);
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
