import 'package:github_module/core/request_cancel.dart';

import 'repo.dart';

abstract interface class RepoRepository {
  static const pageSize = 20;

  Future<List<Repo>> listRepos({
    required int page,
    Map<String, String>? headers,
    RequestCancel? cancel,
  });
}
