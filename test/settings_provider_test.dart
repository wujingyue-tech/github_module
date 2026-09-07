import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/features/session/domain/app_settings.dart';
import 'package:learn_flutter/features/session/domain/settings_store.dart';
import 'package:learn_flutter/features/session/presentation/settings_provider.dart';

class _FakeSettingsStore implements SettingsStore {
  _FakeSettingsStore([this.settings = const AppSettings()]);

  AppSettings settings;

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings settings) async {
    this.settings = settings;
  }
}

void main() {
  test('restore reads the settings store', () async {
    final store = _FakeSettingsStore(
      const AppSettings(theme: 2, locale: 'zh', themeMode: 'dark'),
    );
    final container = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    await container.read(settingsProvider.notifier).restore();

    final settings = container.read(settingsProvider);
    expect(settings.theme, 2);
    expect(settings.locale, 'zh');
    expect(settings.themeMode, 'dark');
  });

  test('setLocale persists to the settings store', () async {
    final store = _FakeSettingsStore();
    final container = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    await container.read(settingsProvider.notifier).setLocale('en');

    expect(container.read(settingsProvider).locale, 'en');
    expect(store.settings.locale, 'en');
  });
}
