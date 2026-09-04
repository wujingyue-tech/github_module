import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/global.dart';

class SettingsState {
  const SettingsState({
    this.localeCode,
    this.themeModeCode,
    this.colorIndex = 0,
  });

  /// `null` 表示跟随系统
  final String? localeCode;
  /// `null` 表示跟随系统
  final String? themeModeCode;
  final int colorIndex;

  Locale? get locale => switch (localeCode) {
    'zh' => const Locale('zh'),
    'en' => const Locale('en'),
    _ => null,
  };

  ThemeMode get themeMode => switch (themeModeCode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  MaterialColor get seedColor {
    final colors = Global.themes;
    if (colorIndex < 0 || colorIndex >= colors.length) {
      return colors.first;
    }
    return colors[colorIndex];
  }

  @override
  String toString() {
    return 'SettingsState(locale: $locale, themeMode: $themeMode, seedColor: $seedColor)';
  }

  factory SettingsState.fromProfile() {
    final profile = Global.profile;
    return SettingsState(
      localeCode: profile.locale,
      themeModeCode: profile.themeMode,
      colorIndex: profile.theme,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => SettingsState.fromProfile();

  Future<void> setLocale(String? code) async {
    Global.profile = code == null
        ? Global.profile.copyWith(clearLocale: true)
        : Global.profile.copyWith(locale: code);
    await Global.saveProfile();
    state = SettingsState.fromProfile();
  }

  Future<void> setThemeMode(String? code) async {
    Global.profile = code == null
        ? Global.profile.copyWith(clearThemeMode: true)
        : Global.profile.copyWith(themeMode: code);
    await Global.saveProfile();
    state = SettingsState.fromProfile();
  }

  Future<void> setColorIndex(int index) async {
    Global.profile = Global.profile.copyWith(theme: index);
    await Global.saveProfile();
    state = SettingsState.fromProfile();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
