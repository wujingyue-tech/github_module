import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/features/session/data/settings_store_impl.dart';
import 'package:learn_flutter/features/session/domain/app_settings.dart';
import 'package:learn_flutter/features/session/domain/settings_store.dart';

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => SettingsStoreImpl(),
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  SettingsStore get _store => ref.read(settingsStoreProvider);

  Future<void> restore() async {
    state = await _store.load();
  }

  Future<void> setLocale(String? code) async {
    state = code == null
        ? state.copyWith(clearLocale: true)
        : state.copyWith(locale: code);
    await _store.save(state);
  }

  Future<void> setThemeMode(String? code) async {
    state = code == null
        ? state.copyWith(clearThemeMode: true)
        : state.copyWith(themeMode: code);
    await _store.save(state);
  }

  Future<void> setColorIndex(int index) async {
    state = state.copyWith(theme: index);
    await _store.save(state);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
