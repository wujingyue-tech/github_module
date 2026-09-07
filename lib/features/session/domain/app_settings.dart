import 'package:learn_flutter/core/network/cache_config.dart';

class AppSettings {
  const AppSettings({
    this.theme = 0,
    this.locale,
    this.themeMode,
    this.cache = CacheConfig.defaults,
  });

  final int theme;
  final String? locale;
  final String? themeMode;
  final CacheConfig cache;

  AppSettings copyWith({
    int? theme,
    String? locale,
    String? themeMode,
    CacheConfig? cache,
    bool clearLocale = false,
    bool clearThemeMode = false,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      locale: clearLocale ? null : locale ?? this.locale,
      themeMode: clearThemeMode ? null : themeMode ?? this.themeMode,
      cache: cache ?? this.cache,
    );
  }
}
