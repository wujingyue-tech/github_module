import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/features/repos/domain/repo.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';

/// Flip this, then **hot restart** (not hot reload) to preview repo list UI.
///
/// Keep `false` when you want real GitHub data.
const debugForceRepoListError = true;

class ForceErrorRepoRepository implements RepoRepository {
  const ForceErrorRepoRepository();

  @override
  Future<List<Repo>> listRepos({
    required int page,
    Map<String, String>? headers,
  }) async {
    throw AppException(AppErrorCode.offline);
  }
}
