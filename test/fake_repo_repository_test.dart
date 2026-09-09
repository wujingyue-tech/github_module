import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/core/error/app_exception.dart';
import 'package:github_module/core/request_cancel.dart';
import 'package:github_module/features/repos/data/fake_repo_repository.dart';
import 'package:github_module/features/repos/domain/repo_repository.dart';

void main() {
  test('empty and list snapshots', () async {
    final empty = FakeRepoRepository.empty();
    expect(await empty.listRepos(page: 1), isEmpty);

    final list = FakeRepoRepository.list(count: 3);
    expect(await list.listRepos(page: 1), hasLength(3));
  });

  test('error and hasMore snapshots', () async {
    expect(
      FakeRepoRepository.error().listRepos(page: 1),
      throwsA(
        isA<AppException>().having((e) => e.code, 'code', AppErrorCode.offline),
      ),
    );

    final full = FakeRepoRepository.hasMore();
    expect(full.items, hasLength(RepoRepository.pageSize));
  });

  test('loading snapshot completes when cancelled', () async {
    final cancel = RequestCancel();
    final future = FakeRepoRepository.loading().listRepos(
      page: 1,
      cancel: cancel,
    );
    cancel.cancel();
    await expectLater(future, throwsA(isA<RequestCancelledException>()));
  });
}
