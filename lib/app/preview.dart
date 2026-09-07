import 'package:flutter_riverpod/misc.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/features/repos/data/fake_repo_repository.dart';

/// Debug snapshot of one UI state. Change [appPreview], then **hot restart**.
///
/// Release builds never apply these overrides. Leave [AppPreview.off] when
/// you want the real GitHub port.
///
/// [Override] comes from `package:flutter_riverpod/misc.dart`.
enum AppPreview {
  off,
  reposEmpty,
  reposError,
  reposList,
  reposHasMore,
  reposLoading,
}

const appPreview = AppPreview.off;

List<Override> previewOverrides() {
  return switch (appPreview) {
    AppPreview.off => const [],
    AppPreview.reposEmpty => [
      repoRepositoryProvider.overrideWithValue(FakeRepoRepository.empty()),
    ],
    AppPreview.reposError => [
      repoRepositoryProvider.overrideWithValue(FakeRepoRepository.error()),
    ],
    AppPreview.reposList => [
      repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
    ],
    AppPreview.reposHasMore => [
      repoRepositoryProvider.overrideWithValue(FakeRepoRepository.hasMore()),
    ],
    AppPreview.reposLoading => [
      repoRepositoryProvider.overrideWithValue(FakeRepoRepository.loading()),
    ],
  };
}
