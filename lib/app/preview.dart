import 'package:learn_flutter/features/repos/data/fake_repo_repository.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';

/// Debug snapshot of one UI state. Change [appPreview], then **hot restart**.
///
/// Release builds never apply these fakes. Leave [AppPreview.off] when you
/// want the real GitHub port.
///
/// This is snapshot preview (one fixed response). It is not a multi-step
/// flow script. See ADD_FEATURE.md.
enum AppPreview {
  off,
  reposEmpty,
  reposError,
  reposList,
  reposHasMore,
  reposLoading,
}

const appPreview = AppPreview.off;

/// Fake port for the selected snapshot, or `null` to use DI's real impl.
RepoRepository? previewRepoRepository() {
  return switch (appPreview) {
    AppPreview.off => null,
    AppPreview.reposEmpty => FakeRepoRepository.empty(),
    AppPreview.reposError => FakeRepoRepository.error(),
    AppPreview.reposList => FakeRepoRepository.list(),
    AppPreview.reposHasMore => FakeRepoRepository.hasMore(),
    AppPreview.reposLoading => FakeRepoRepository.loading(),
  };
}
