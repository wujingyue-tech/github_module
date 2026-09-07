import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/features/repos/data/fake_repo_repository.dart';
import 'package:learn_flutter/features/repos/domain/repo.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';
import 'package:learn_flutter/features/repos/presentation/repo_list_provider.dart';

class _FailingLoadMoreRepository implements RepoRepository {
  @override
  Future<List<Repo>> listRepos({
    required int page,
    Map<String, String>? headers,
  }) async {
    if (page == 1) return FakeRepoRepository.hasMore().items;
    throw AppException(AppErrorCode.failed);
  }
}

void main() {
  test('first page loads and reports hasMore', () async {
    final container = ProviderContainer(
      overrides: [
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.hasMore()),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(repoListProvider.future);
    expect(state.items, hasLength(RepoRepository.pageSize));
    expect(state.hasMore, isTrue);
  });

  test('loadMore keeps items and stores the error on the list state', () async {
    final container = ProviderContainer(
      overrides: [
        repoRepositoryProvider.overrideWithValue(_FailingLoadMoreRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(repoListProvider.future);
    await container.read(repoListProvider.notifier).loadMore();

    final value = container.read(repoListProvider);
    expect(value.hasError, isFalse);
    final state = value.requireValue;
    expect(state.items, hasLength(RepoRepository.pageSize));
    expect(state.hasMore, isTrue);
    expect((state.loadMoreError! as AppException).code, AppErrorCode.failed);
  });

  test('loadMore does not auto-retry while the footer error is set', () async {
    final repo = _CountingFailingLoadMoreRepository();
    final container = ProviderContainer(
      overrides: [repoRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    await container.read(repoListProvider.future);
    await container.read(repoListProvider.notifier).loadMore();
    await container.read(repoListProvider.notifier).loadMore();

    expect(repo.calls, 2);
    expect(
      container.read(repoListProvider).requireValue.loadMoreError,
      isNotNull,
    );
  });

  test('retryLoadMore appends the next page after a failure', () async {
    final container = ProviderContainer(
      overrides: [
        repoRepositoryProvider.overrideWithValue(
          _FailThenSucceedLoadMoreRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(repoListProvider.future);
    await container.read(repoListProvider.notifier).loadMore();
    expect(
      container.read(repoListProvider).requireValue.items,
      hasLength(RepoRepository.pageSize),
    );

    await container.read(repoListProvider.notifier).retryLoadMore();

    final state = container.read(repoListProvider).requireValue;
    expect(state.items, hasLength(RepoRepository.pageSize + 1));
    expect(state.loadMoreError, isNull);
    expect(state.hasMore, isFalse);
  });
}

class _FailThenSucceedLoadMoreRepository implements RepoRepository {
  var _page2Calls = 0;

  @override
  Future<List<Repo>> listRepos({
    required int page,
    Map<String, String>? headers,
  }) async {
    if (page == 1) return FakeRepoRepository.hasMore().items;
    _page2Calls++;
    if (_page2Calls == 1) throw AppException(AppErrorCode.failed);
    return [sampleRepo(100)];
  }
}

class _CountingFailingLoadMoreRepository extends _FailingLoadMoreRepository {
  var calls = 0;

  @override
  Future<List<Repo>> listRepos({
    required int page,
    Map<String, String>? headers,
  }) async {
    calls++;
    return super.listRepos(page: page, headers: headers);
  }
}
