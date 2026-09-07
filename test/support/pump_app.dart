import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/app.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/logging/noop_app_log.dart';
import 'package:learn_flutter/features/session/domain/app_settings.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';
import 'package:learn_flutter/features/session/domain/auth_store.dart';
import 'package:learn_flutter/features/session/domain/settings_store.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';
import 'package:learn_flutter/l10n/app_localizations.dart';

class MemoryAuthStore implements AuthStore {
  MemoryAuthStore([this.session = const AuthSession()]);

  AuthSession session;

  @override
  Future<AuthSession> load() async => session;

  @override
  Future<void> save(AuthSession session) async {
    this.session = session;
  }
}

class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([this.settings = const AppSettings()]);

  AppSettings settings;

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings settings) async {
    this.settings = settings;
  }
}

Future<void> pumpPage(
  WidgetTester tester,
  Widget page, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        appLogProvider.overrideWithValue(const NoOpAppLog()),
        ...overrides,
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: page,
      ),
    ),
  );
}

Future<ProviderContainer> pumpMainApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
  bool restoreSession = false,
}) async {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      appLogProvider.overrideWithValue(const NoOpAppLog()),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  if (restoreSession) {
    await container.read(sessionProvider.notifier).restore();
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  return container;
}
