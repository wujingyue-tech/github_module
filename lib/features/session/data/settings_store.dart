import 'dart:convert';

import 'package:learn_flutter/core/network/cache_config.dart';
import 'package:learn_flutter/features/session/data/profile_dto.dart';
import 'package:learn_flutter/features/session/domain/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  SettingsStore({required this.prefs});

  static const settingsKey = 'app_settings';
  static const legacyProfileKey = 'profile';

  final SharedPreferences prefs;

  static Future<SettingsStore> open() async {
    return SettingsStore(prefs: await SharedPreferences.getInstance());
  }

  Future<AppSettings> load() async {
    final raw = prefs.getString(settingsKey);
    if (raw != null) {
      try {
        final settings = _fromJson(jsonDecode(raw) as Map<String, dynamic>);
        await save(settings);
        return settings;
      } catch (_) {}
    }

    final settings = _fromLegacy() ?? const AppSettings();
    await save(settings);
    return settings;
  }

  Future<void> save(AppSettings settings) async {
    await prefs.setString(settingsKey, jsonEncode(_toJson(settings)));
  }

  AppSettings? _fromLegacy() {
    final raw = prefs.getString(legacyProfileKey);
    if (raw == null) return null;
    try {
      final profile = ProfileDto.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return AppSettings(
        theme: profile.theme,
        locale: profile.locale,
        themeMode: profile.themeMode,
        cache: profile.cache ?? CacheConfig.defaults,
      );
    } catch (_) {
      return null;
    }
  }

  static AppSettings _fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: (json['theme'] as num?)?.toInt() ?? 0,
      locale: json['locale'] as String?,
      themeMode: json['themeMode'] as String?,
      cache: json['cache'] == null
          ? CacheConfig.defaults
          : CacheConfig.fromJson(json['cache'] as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> _toJson(AppSettings settings) {
    return {
      'theme': settings.theme,
      'locale': settings.locale,
      'themeMode': settings.themeMode,
      'cache': settings.cache.toJson(),
    };
  }
}
