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
