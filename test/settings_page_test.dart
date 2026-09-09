import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/app/store_providers.dart';
import 'package:github_module/app/di.dart';
import 'package:github_module/app/router.dart';
import 'package:github_module/features/auth/data/fake_auth_repository.dart';
import 'package:github_module/features/auth/domain/sample_user.dart';
import 'package:github_module/features/repos/data/fake_repo_repository.dart';
import 'package:github_module/features/session/domain/auth_session.dart';
import 'package:github_module/features/session/presentation/settings_page.dart';
import 'package:github_module/l10n/app_localizations_en.dart';
import 'package:github_module/l10n/app_localizations_zh.dart';

import 'support/pump_app.dart';

final _l10n = AppLocalizationsEn();
final _zh = AppLocalizationsZh();

void main() {
  testWidgets('shows language, appearance, and version', (tester) async {
    await pumpPage(
      tester,
      const SettingsPage(),
      overrides: [
        settingsStoreProvider.overrideWithValue(MemorySettingsStore()),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.language), findsOneWidget);
    expect(find.text(_l10n.appearance), findsOneWidget);
    expect(find.text(_l10n.themeColor), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('appVersion')),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('appVersion')), findsOneWidget);
    expect(find.text(_l10n.appVersion('0.0.0 (0)')), findsOneWidget);
  });

  testWidgets('choosing Chinese updates the settings title', (tester) async {
    final container = await pumpMainApp(
      tester,
      restoreSession: true,
      overrides: [
        authStoreProvider.overrideWithValue(
          MemoryAuthStore(const AuthSession(token: 'tok', user: previewUser)),
        ),
        settingsStoreProvider.overrideWithValue(MemorySettingsStore()),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
      ],
    );
    await tester.pumpAndSettle();

    container.read(goRouterProvider).go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n.languageChinese));
    await tester.pumpAndSettle();

    expect(find.text(_zh.settings), findsOneWidget);
  });

  testWidgets('choosing dark sets the dark theme', (tester) async {
    final container = await pumpMainApp(
      tester,
      restoreSession: true,
      overrides: [
        authStoreProvider.overrideWithValue(
          MemoryAuthStore(const AuthSession(token: 'tok', user: previewUser)),
        ),
        settingsStoreProvider.overrideWithValue(MemorySettingsStore()),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.list()),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository.success()),
      ],
    );
    await tester.pumpAndSettle();

    container.read(goRouterProvider).go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n.appearanceDark));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SettingsPage));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('choosing a color selects that chip', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpPage(
      tester,
      const SettingsPage(),
      overrides: [
        settingsStoreProvider.overrideWithValue(MemorySettingsStore()),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, _l10n.colorCyan));
    await tester.pumpAndSettle();

    final cyan = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, _l10n.colorCyan),
    );
    final blue = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, _l10n.colorBlue),
    );
    expect(cyan.selected, isTrue);
    expect(blue.selected, isFalse);
  });
}
