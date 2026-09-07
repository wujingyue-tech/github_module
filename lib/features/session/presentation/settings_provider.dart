import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/features/session/data/settings_store.dart';
import 'package:learn_flutter/features/session/domain/app_settings.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  SettingsStore? _store;

  @override
  AppSettings build() => const AppSettings();

  Future<void> restore() async {
    final store = await _ensureStore();
    state = await store.load();
  }

  Future<void> setLocale(String? code) async {
    state = code == null
        ? state.copyWith(clearLocale: true)
        : state.copyWith(locale: code);
    await _persist();
  }

  Future<void> setThemeMode(String? code) async {
    state = code == null
        ? state.copyWith(clearThemeMode: true)
        : state.copyWith(themeMode: code);
    await _persist();
  }

  Future<void> setColorIndex(int index) async {
    state = state.copyWith(theme: index);
    await _persist();
  }

  Future<SettingsStore> _ensureStore() async {
    return _store ??= await SettingsStore.open();
  }

  Future<void> _persist() async {
    final store = await _ensureStore();
    await store.save(state);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
