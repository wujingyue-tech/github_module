import 'package:learn_flutter/core/network/cache_config.dart';

/// Legacy local snapshot used only to migrate the old `profile` prefs key.
class ProfileDto {
  const ProfileDto({
    this.user,
    this.token,
    this.theme = 0,
    this.cache,
    this.lastLogin,
    this.locale,
    this.themeMode,
  });

  final Map<String, dynamic>? user;
  final String? token;
  final int theme;
  final CacheConfig? cache;
  final String? lastLogin;
  final String? locale;
  final String? themeMode;

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      user: json['user'] as Map<String, dynamic>?,
      token: json['token'] as String?,
      theme: (json['theme'] as num?)?.toInt() ?? 0,
      cache: json['cache'] == null
          ? null
          : CacheConfig.fromJson(json['cache'] as Map<String, dynamic>),
      lastLogin: json['lastLogin'] as String?,
      locale: json['locale'] as String?,
      themeMode: json['themeMode'] as String?,
    );
  }
}
