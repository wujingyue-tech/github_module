import 'dart:convert';

import 'package:learn_flutter/features/session/domain/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  SettingsStore({required this.prefs});

  static const settingsKey = 'app_settings';

  final SharedPreferences prefs;

  static Future<SettingsStore> open() async {
    return SettingsStore(prefs: await SharedPreferences.getInstance());
  }

  Future<AppSettings> load() async {
    final raw = prefs.getString(settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    await prefs.setString(settingsKey, jsonEncode(_toJson(settings)));
  }

  static AppSettings _fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: (json['theme'] as num?)?.toInt() ?? 0,
      locale: json['locale'] as String?,
      themeMode: json['themeMode'] as String?,
    );
  }

  static Map<String, dynamic> _toJson(AppSettings settings) {
    return {
      'theme': settings.theme,
      'locale': settings.locale,
      'themeMode': settings.themeMode,
    };
  }
}
