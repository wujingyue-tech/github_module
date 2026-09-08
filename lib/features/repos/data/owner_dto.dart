import 'package:learn_flutter/features/auth/domain/user_ref.dart';

/// GitHub's nested repo `owner` object — not the `/user` profile payload.
class OwnerDto {
  const OwnerDto({
    required this.login,
    required this.avatarUrl,
    required this.type,
    this.name,
  });

  final String login;
  final String avatarUrl;
  final String type;
  final String? name;

  factory OwnerDto.fromJson(Map<String, dynamic> json) {
    return OwnerDto(
      login: json['login'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      type: json['type'] as String? ?? 'User',
      name: json['name'] as String?,
    );
  }

  UserRef toDomain() {
    return UserRef(login: login, avatarUrl: avatarUrl, type: type, name: name);
  }
}
