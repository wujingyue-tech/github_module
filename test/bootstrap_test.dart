import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/bootstrap.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/crash_reporting/crash_reporter.dart';
import 'package:learn_flutter/features/auth/data/fake_auth_repository.dart';
import 'package:learn_flutter/features/session/domain/app_settings.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';
import 'package:learn_flutter/features/session/domain/auth_store.dart';
import 'package:learn_flutter/features/session/domain/settings_store.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';
import 'package:learn_flutter/features/session/presentation/settings_provider.dart';

class _ThrowingAuthStore implements AuthStore {
  @override
  Future<AuthSession> load() async => throw StateError('keychain');

  @override
  Future<void> save(AuthSession session) async {}
}

class _ThrowingSettingsStore implements SettingsStore {
  @override
  Future<AppSettings> load() async => throw StateError('prefs');

  @override
  Future<void> save(AppSettings settings) async {}
}

class _MemoryAuthStore implements AuthStore {
  _MemoryAuthStore(this.session);

  AuthSession session;

  @override
  Future<AuthSession> load() async => session;

  @override
  Future<void> save(AuthSession session) async {
    this.session = session;
  }
}

class _MemorySettingsStore implements SettingsStore {
  _MemorySettingsStore(this.settings);

  AppSettings settings;

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings settings) async {
    this.settings = settings;
  }
}

void main() {
  test('session restore failure still starts logged out', () async {
    final errors = <Object>[];
    final container = ProviderContainer(
      overrides: [
        authStoreProvider.overrideWithValue(_ThrowingAuthStore()),
        settingsStoreProvider.overrideWithValue(
          _MemorySettingsStore(const AppSettings(locale: 'zh')),
        ),
      ],
    );
    addTearDown(container.dispose);

    await restoreForStartup(
      container,
      onError: (error, _) => errors.add(error),
    );

    expect(container.read(sessionProvider).isLoggedIn, isFalse);
    expect(container.read(settingsProvider).locale, 'zh');
    expect(errors, hasLength(1));
    expect(errors.single, isA<StateError>());
  });

  test(
    'settings restore failure keeps defaults and still restores session',
    () async {
      final errors = <Object>[];
      final container = ProviderContainer(
        overrides: [
          authStoreProvider.overrideWithValue(
            _MemoryAuthStore(const AuthSession(token: 'tok')),
          ),
          settingsStoreProvider.overrideWithValue(_ThrowingSettingsStore()),
        ],
      );
      addTearDown(container.dispose);

      await restoreForStartup(
        container,
        onError: (error, _) => errors.add(error),
      );

      expect(container.read(sessionProvider).token, 'tok');
      expect(container.read(settingsProvider).locale, isNull);
      expect(errors, hasLength(1));
    },
  );

  test('bindCrashReporterUser tracks GitHub login and clears on logout', () async {
    final reporter = _RecordingCrashReporter();
    final store = _MemoryAuthStore(
      const AuthSession(token: 'tok', user: previewUser),
    );
    final container = ProviderContainer(
      overrides: [
        crashReporterProvider.overrideWithValue(reporter),
        authStoreProvider.overrideWithValue(store),
        settingsStoreProvider.overrideWithValue(
          _MemorySettingsStore(const AppSettings()),
        ),
      ],
    );
    addTearDown(container.dispose);

    bindCrashReporterUser(container);
    await container.read(sessionProvider.notifier).restore();
    expect(reporter.userId, 'octocat');

    await container.read(sessionProvider.notifier).clearAuth();
    expect(reporter.userId, isNull);
  });
}

class _RecordingCrashReporter implements CrashReporter {
  String? userId;

  @override
  void capture(Object error, [StackTrace? stackTrace, String? hint]) {}

  @override
  void setUser({String? id}) {
    userId = id;
  }
}
