import 'dart:async';

import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/core/request_cancel.dart';
import 'package:learn_flutter/features/auth/data/fake_auth_repository.dart';
import 'package:learn_flutter/features/repos/domain/repo.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';

Repo sampleRepo(int id) {
  return Repo(
    id: id,
    name: 'repo-$id',
    fullName: 'octocat/repo-$id',
    owner: previewUser,
    private: false,
    fork: false,
    forksCount: 1,
    stargazersCount: id,
    defaultBranch: 'main',
    openIssuesCount: 0,
    description: 'Preview repo $id',
    language: 'Dart',
  );
}

/// In-memory [RepoRepository] for snapshot preview and notifier tests.
///
/// Always implements the domain port. Do not fake Dio or the notifier
/// when you only need a fixed list / empty / error / hang.
class FakeRepoRepository implements RepoRepository {
  const FakeRepoRepository({
    this.items = const [],
    this.error,
    this.hang = false,
  });

  factory FakeRepoRepository.empty() => const FakeRepoRepository();

  factory FakeRepoRepository.error([AppErrorCode code = AppErrorCode.offline]) {
    return FakeRepoRepository(error: AppException(code));
  }

  factory FakeRepoRepository.list({int count = 3}) {
    return FakeRepoRepository(
      items: [for (var i = 0; i < count; i++) sampleRepo(i)],
    );
  }

  factory FakeRepoRepository.hasMore() {
    return FakeRepoRepository.list(count: RepoRepository.pageSize);
  }

  factory FakeRepoRepository.loading() => const FakeRepoRepository(hang: true);

  final List<Repo> items;
  final Object? error;
  final bool hang;

  @override
  Future<List<Repo>> listRepos({
    required int page,
    Map<String, String>? headers,
    RequestCancel? cancel,
  }) async {
    if (hang) {
      final completer = Completer<List<Repo>>();
      cancel?.whenCancelled(() {
        if (!completer.isCompleted) {
          completer.completeError(const RequestCancelledException());
        }
      });
      return completer.future;
    }
    if (cancel?.isCancelled ?? false) {
      throw const RequestCancelledException();
    }
    if (error != null) throw error!;
    return items;
  }
}
