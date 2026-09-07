import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/core/request_cancel.dart';
import 'package:learn_flutter/features/repos/data/fake_repo_repository.dart';
import 'package:learn_flutter/features/repos/domain/repo.dart';
import 'package:learn_flutter/features/repos/domain/repo_repository.dart';
import 'package:learn_flutter/features/repos/presentation/repo_list_page.dart';
import 'package:learn_flutter/l10n/app_localizations_en.dart';

import 'support/pump_app.dart';

final _l10n = AppLocalizationsEn();

void main() {
  testWidgets('shows a loading indicator while the first page hangs', (
    tester,
  ) async {
    await pumpPage(
      tester,
      const RepoListPage(),
      overrides: [
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.loading()),
      ],
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an empty state', (tester) async {
    await pumpPage(
      tester,
      const RepoListPage(),
      overrides: [
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.empty()),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.reposEmpty), findsOneWidget);
  });

  testWidgets('shows repo names', (tester) async {
    await pumpPage(
      tester,
      const RepoListPage(),
      overrides: [
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('repo-0'), findsOneWidget);
    expect(find.text('repo-1'), findsOneWidget);
  });

  testWidgets('shows a full-page error and retry loads data', (tester) async {
    await pumpPage(
      tester,
      const RepoListPage(),
      overrides: [
        repoRepositoryProvider.overrideWithValue(_FailThenListRepository()),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.authErrorOffline), findsOneWidget);
    await tester.tap(find.text(_l10n.retry));
    await tester.pumpAndSettle();

    expect(find.text('repo-0'), findsOneWidget);
    expect(find.text(_l10n.authErrorOffline), findsNothing);
  });
}

class _FailThenListRepository implements RepoRepository {
  var _calls = 0;

  @override
  Future<List<Repo>> listRepos({
    required int page,
    Map<String, String>? headers,
    RequestCancel? cancel,
  }) async {
    _calls++;
    if (_calls == 1) throw AppException(AppErrorCode.offline);
    return FakeRepoRepository.list().items;
  }
}
