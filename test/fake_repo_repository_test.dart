import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/features/repos/data/fake_repo_repository.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';

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
}
