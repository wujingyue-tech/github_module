import 'package:json_annotation/json_annotation.dart';

import 'cacheConfig.dart';
import 'user.dart';

part 'profile.g.dart';

@JsonSerializable(explicitToJson: true)
class Profile {
  const Profile({
    this.user,
    this.token,
    required this.theme,
    this.cache,
    this.lastLogin,
    this.locale,
    this.themeMode,
  });

  final User? user;
  final String? token;
  final int theme;
  final CacheConfig? cache;
  final String? lastLogin;
  /// `null` = 跟随系统，`zh` / `en` = 手动指定
  final String? locale;
  /// `null` = 跟随系统，`light` / `dark` = 手动指定
  final String? themeMode;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({
    User? user,
    String? token,
    int? theme,
    CacheConfig? cache,
    String? lastLogin,
    String? locale,
    String? themeMode,
    bool clearUser = false,
    bool clearToken = false,
    bool clearLocale = false,
    bool clearThemeMode = false,
  }) {
    return Profile(
      user: clearUser ? null : user ?? this.user,
      token: clearToken ? null : token ?? this.token,
      theme: theme ?? this.theme,
      cache: cache ?? this.cache,
      lastLogin: lastLogin ?? this.lastLogin,
      locale: clearLocale ? null : locale ?? this.locale,
      themeMode: clearThemeMode ? null : themeMode ?? this.themeMode,
    );
  }
}