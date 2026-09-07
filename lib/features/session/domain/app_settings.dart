class AppSettings {
  const AppSettings({this.theme = 0, this.locale, this.themeMode});

  final int theme;
  final String? locale;
  final String? themeMode;

  AppSettings copyWith({
    int? theme,
    String? locale,
    String? themeMode,
    bool clearLocale = false,
    bool clearThemeMode = false,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      locale: clearLocale ? null : locale ?? this.locale,
      themeMode: clearThemeMode ? null : themeMode ?? this.themeMode,
    );
  }
}
