import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cacheConfig.dart';
import '../models/profile.dart';

// 提供五套可选主题色
const _themes = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.indigo,
];

class Global {
  static late SharedPreferences _prefs;
  static Profile profile = const Profile(theme: 0);

  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  // 初始化全局信息，会在APP启动时执行
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    final profileJson = _prefs.getString("profile");
    if (profileJson != null) {
      try {
        profile = Profile.fromJson(
          jsonDecode(profileJson) as Map<String, dynamic>,
        );
      } catch (e) {
        debugPrint('$e');
      }
    }

  }

  // 持久化Profile信息
  static Future<bool> saveProfile() =>
      _prefs.setString("profile", jsonEncode(profile.toJson()));
}
