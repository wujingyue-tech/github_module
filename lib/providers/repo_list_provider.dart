import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/repo.dart';
import '../services/github_api.dart';

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

  Future<RepoListState> _fetch({
    required int page,
    required bool refresh,
  }) async {
    final items = await GitHubApi.listRepos(page: page, refresh: refresh);
    return RepoListState(
      items: items,
      page: page,
      hasMore: items.length >= GitHubApi.pageSize,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => _fetch(page: 1, refresh: true),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final nextPage = current.page + 1;
      final more = await GitHubApi.listRepos(page: nextPage);
      state = AsyncData(
        RepoListState(
          items: [...current.items, ...more],
          page: nextPage,
          hasMore: more.length >= GitHubApi.pageSize,
        ),
      );
    } catch (_) {
      // 保留已加载列表，避免翻页失败把整页打成错误
    } finally {
      _loadingMore = false;
    }
  }
}

final repoListProvider =
    AsyncNotifierProvider.autoDispose<RepoListNotifier, RepoListState>(
      RepoListNotifier.new,
    );
