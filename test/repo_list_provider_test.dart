import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/features/auth/domain/user.dart';
import 'package:learn_flutter/features/repos/domain/repo.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';
import 'package:learn_flutter/features/repos/presentation/repo_list_provider.dart';

const _owner = User(
  login: 'octocat',
  avatarUrl: 'https://example.com/a.png',
  type: 'User',
  publicRepos: 0,
  followers: 0,
  following: 0,
  totalPrivateRepos: 0,
  ownedPrivateRepos: 0,
);

Repo _repo(int id) {
  return Repo(
    id: id,
    name: 'repo-$id',
    fullName: 'octocat/repo-$id',
    owner: _owner,
    private: false,
    fork: false,
    forksCount: 0,
    stargazersCount: 0,
    defaultBranch: 'main',
    openIssuesCount: 0,
  );
}

class _FakeRepoRepository implements RepoRepository {
  _FakeRepoRepository(this.pages);

  final List<List<Repo>> pages;

  @override
  Future<List<Repo>> listRepos({
    required int page,
    Map<String, String>? headers,
  }) async {
    return pages[page - 1];
  }
}

class _FailingLoadMoreRepository implements RepoRepository {
  @override
  Future<List<Repo>> listRepos({
    required int page,
    Map<String, String>? headers,
  }) async {
    if (page == 1) {
      return [for (var i = 0; i < RepoRepository.pageSize; i++) _repo(i)];
    }
    throw AppException(AppErrorCode.failed);
  }
}

void main() {
  test('first page loads and reports hasMore', () async {
    final container = ProviderContainer(
      overrides: [
        repoRepositoryProvider.overrideWithValue(
          _FakeRepoRepository([
            [for (var i = 0; i < RepoRepository.pageSize; i++) _repo(i)],
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(repoListProvider.future);
    expect(state.items, hasLength(RepoRepository.pageSize));
    expect(state.hasMore, isTrue);
  });

  test('loadMore surfaces errors', () async {
    final container = ProviderContainer(
      overrides: [
        repoRepositoryProvider.overrideWithValue(_FailingLoadMoreRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(repoListProvider.future);
    await container.read(repoListProvider.notifier).loadMore();

    expect(container.read(repoListProvider).hasError, isTrue);
    expect(
      (container.read(repoListProvider).error! as AppException).code,
      AppErrorCode.failed,
    );
  });
}
