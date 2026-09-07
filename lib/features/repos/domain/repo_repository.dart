import 'repo.dart';

abstract interface class RepoRepository {
  static const pageSize = 20;

  Future<List<Repo>> listRepos({required int page, bool refresh = false});
}
