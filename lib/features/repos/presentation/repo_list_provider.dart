import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/features/repos/domain/repo.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';

class RepoListState {
  const RepoListState({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<Repo> items;
  final int page;
  final bool hasMore;
}

class RepoListNotifier extends AsyncNotifier<RepoListState> {
  var _loadingMore = false;

  @override
  Future<RepoListState> build() => _fetch(page: 1, refresh: false);

  RepoRepository get _repo => ref.read(repoRepositoryProvider);

  Future<RepoListState> _fetch({
    required int page,
    required bool refresh,
  }) async {
    final items = await _repo.listRepos(page: page, refresh: refresh);
    return RepoListState(
      items: items,
      page: page,
      hasMore: items.length >= RepoRepository.pageSize,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetch(page: 1, refresh: true));
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final nextPage = current.page + 1;
      final more = await _repo.listRepos(page: nextPage);
      state = AsyncData(
        RepoListState(
          items: [...current.items, ...more],
          page: nextPage,
          hasMore: more.length >= RepoRepository.pageSize,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _loadingMore = false;
    }
  }
}

final repoListProvider =
    AsyncNotifierProvider.autoDispose<RepoListNotifier, RepoListState>(
      RepoListNotifier.new,
    );
