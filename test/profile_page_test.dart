import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/app/store_providers.dart';
import 'package:learn_flutter/features/auth/data/fake_auth_repository.dart';
import 'package:learn_flutter/features/auth/domain/sample_user.dart';
import 'package:learn_flutter/features/auth/domain/user.dart';
import 'package:learn_flutter/features/auth/presentation/profile_page.dart';
import 'package:learn_flutter/features/repos/data/fake_repo_repository.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';
import 'package:learn_flutter/l10n/app_localizations_en.dart';

import 'support/mock_network_images.dart';
import 'support/pump_app.dart';

final _l10n = AppLocalizationsEn();

const _updatedUser = User(
  login: 'octocat',
  avatarUrl: 'https://example.com/a.png',
  type: 'User',
  name: 'Updated',
  publicRepos: 12,
  followers: 0,
  following: 0,
  totalPrivateRepos: 0,
  ownedPrivateRepos: 0,
);

void main() {
  setUp(installMockNetworkImages);
  tearDown(uninstallMockNetworkImages);

  testWidgets('empty session shows the saved-token placeholder', (
    tester,
  ) async {
    await pumpPage(tester, const ProfilePage());
    await tester.pumpAndSettle();

    expect(find.text(_l10n.savedToken), findsOneWidget);
  });

  testWidgets('shows the signed-in profile from session', (tester) async {
    await pumpMainApp(
      tester,
      restoreSession: true,
      overrides: [
        authStoreProvider.overrideWithValue(
          MemoryAuthStore(const AuthSession(token: 'tok', user: previewUser)),
        ),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n.profileTab));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text(_l10n.profileTitle),
      ),
      findsOneWidget,
    );
    expect(find.text('Octocat'), findsOneWidget);
    expect(find.text('@octocat'), findsOneWidget);
    expect(find.text('${_l10n.publicRepos} 0'), findsOneWidget);
  });

  testWidgets('settings from profile opens settings', (tester) async {
    await pumpMainApp(
      tester,
      restoreSession: true,
      overrides: [
        authStoreProvider.overrideWithValue(
          MemoryAuthStore(const AuthSession(token: 'tok', user: previewUser)),
        ),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n.profileTab));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(_l10n.settings));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.language), findsOneWidget);
  });

  testWidgets('sign out returns to login', (tester) async {
    await pumpMainApp(
      tester,
      restoreSession: true,
      overrides: [
        authStoreProvider.overrideWithValue(
          MemoryAuthStore(const AuthSession(token: 'tok', user: previewUser)),
        ),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n.profileTab));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_l10n.signOut));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.loginTitle), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text(_l10n.profileTitle),
      ),
      findsNothing,
    );
  });

  testWidgets('pull to refresh replaces the profile from the repository', (
    tester,
  ) async {
    await pumpMainApp(
      tester,
      restoreSession: true,
      overrides: [
        authStoreProvider.overrideWithValue(
          MemoryAuthStore(const AuthSession(token: 'tok', user: previewUser)),
        ),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository.success(_updatedUser),
        ),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n.profileTab));
    await tester.pumpAndSettle();
    expect(find.text('Octocat'), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Updated'), findsOneWidget);
    expect(find.text('${_l10n.publicRepos} 12'), findsOneWidget);
    expect(find.text('Octocat'), findsNothing);
  });
}
