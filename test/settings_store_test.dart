import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/features/session/data/settings_store_impl.dart';
import 'package:learn_flutter/features/session/domain/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load returns defaults when nothing is stored', () async {
    final store = SettingsStoreImpl(
      prefs: await SharedPreferences.getInstance(),
    );
    final settings = await store.load();

    expect(settings.theme, 0);
    expect(settings.locale, isNull);
    expect(settings.themeMode, isNull);
  });

  test('load reads app_settings', () async {
    SharedPreferences.setMockInitialValues({
      'app_settings': jsonEncode({
        'theme': 2,
        'locale': 'zh',
        'themeMode': 'dark',
      }),
    });

    final store = SettingsStoreImpl(
      prefs: await SharedPreferences.getInstance(),
    );
    final settings = await store.load();

    expect(settings.theme, 2);
    expect(settings.locale, 'zh');
    expect(settings.themeMode, 'dark');
  });

  test('save writes app_settings key', () async {
    final store = SettingsStoreImpl(
      prefs: await SharedPreferences.getInstance(),
    );
    await store.save(const AppSettings(theme: 1, locale: 'en'));

    final prefs = await SharedPreferences.getInstance();
    final saved =
        jsonDecode(prefs.getString('app_settings')!) as Map<String, dynamic>;
    expect(saved['theme'], 1);
    expect(saved['locale'], 'en');
    expect(saved.containsKey('token'), isFalse);
    expect(saved.containsKey('cache'), isFalse);
  });
}
