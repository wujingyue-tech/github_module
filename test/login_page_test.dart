import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/app/di.dart';
import 'package:github_module/app/store_providers.dart';
import 'package:github_module/features/auth/data/fake_auth_repository.dart';
import 'package:github_module/features/auth/presentation/login_page.dart';
import 'package:github_module/features/repos/data/fake_repo_repository.dart';
import 'package:github_module/l10n/app_localizations_en.dart';

import 'support/pump_app.dart';

final _l10n = AppLocalizationsEn();

void main() {
  testWidgets('empty token shows a validation error', (tester) async {
    await pumpPage(
      tester,
      const LoginPage(),
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
        authStoreProvider.overrideWithValue(MemoryAuthStore()),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n.signIn));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.authErrorEmptyToken), findsOneWidget);
  });

  testWidgets('sign in leaves the login page', (tester) async {
    await pumpMainApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
        authStoreProvider.overrideWithValue(MemoryAuthStore()),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.loginTitle), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ghp_test');
    await tester.tap(find.text(_l10n.signIn));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.loginTitle), findsNothing);
    expect(find.text(_l10n.reposTitle), findsOneWidget);
    expect(find.text('repo-0'), findsOneWidget);
  });
}
