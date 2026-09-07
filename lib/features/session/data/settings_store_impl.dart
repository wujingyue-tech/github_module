import 'dart:convert';

import 'package:learn_flutter/features/session/domain/app_settings.dart';
import 'package:learn_flutter/features/session/domain/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStoreImpl implements SettingsStore {
  SettingsStoreImpl({this._prefs});

  static const settingsKey = 'app_settings';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AppSettings> load() async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getString(settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await _ensurePrefs();
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
