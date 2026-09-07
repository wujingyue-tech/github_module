import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/request_cancel.dart';
import 'package:learn_flutter/features/repos/domain/repo.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';

class RepoListState {
  const RepoListState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.loadMoreError,
  });

  final List<Repo> items;
  final int page;
  final bool hasMore;

  /// Set when the next page fails. Existing [items] stay on screen.
  /// Scroll must not auto-retry while this is non-null; call [RepoListNotifier.retryLoadMore].
  final Object? loadMoreError;

  RepoListState copyWith({
    List<Repo>? items,
    int? page,
    bool? hasMore,
    Object? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return RepoListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadMoreError: clearLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
    );
  }
}

class RepoListNotifier extends AsyncNotifier<RepoListState> {
  var _cancel = RequestCancel();
  var _loadingMore = false;

  @override
  Future<RepoListState> build() {
    ref.onDispose(() => _cancel.cancel());
    return _fetch(page: 1);
  }

  RepoRepository get _repo => ref.read(repoRepositoryProvider);

  void _replaceCancel() {
    _cancel.cancel();
    _cancel = RequestCancel();
  }

  Future<RepoListState> _fetch({
    required int page,
    Map<String, String>? headers,
  }) async {
    final items = await _repo.listRepos(
      page: page,
      headers: headers,
      cancel: _cancel,
    );
    return RepoListState(
      items: items,
      page: page,
      hasMore: items.length >= RepoRepository.pageSize,
    );
  }

  Future<void> refresh() async {
    _replaceCancel();
    try {
      state = AsyncData(
        await _fetch(page: 1, headers: const {'cache-control': 'no-cache'}),
      );
    } on RequestCancelledException {
      return;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        _loadingMore ||
        current.loadMoreError != null) {
      return;
    }
    _loadingMore = true;
    try {
      final nextPage = current.page + 1;
      final more = await _repo.listRepos(page: nextPage, cancel: _cancel);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...more],
          page: nextPage,
          hasMore: more.length >= RepoRepository.pageSize,
          clearLoadMoreError: true,
        ),
      );
    } on RequestCancelledException {
      return;
    } catch (error) {
      state = AsyncData(current.copyWith(loadMoreError: error));
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> retryLoadMore() async {
    final current = state.value;
    if (current?.loadMoreError == null) return;
    state = AsyncData(current!.copyWith(clearLoadMoreError: true));
    await loadMore();
  }
}

final repoListProvider =
    AsyncNotifierProvider.autoDispose<RepoListNotifier, RepoListState>(
      RepoListNotifier.new,
    );
