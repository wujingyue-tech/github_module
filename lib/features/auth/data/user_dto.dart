import 'package:learn_flutter/features/auth/domain/user.dart';

class UserDto {
  const UserDto({
    required this.login,
    required this.avatarUrl,
    required this.type,
    this.name,
    this.company,
    this.blog,
    this.location,
    this.email,
    this.hireable,
    this.bio,
    required this.publicRepos,
    required this.followers,
    required this.following,
    this.createdAt,
    this.updatedAt,
    required this.totalPrivateRepos,
    required this.ownedPrivateRepos,
  });

  final String login;
  final String avatarUrl;
  final String type;
  final String? name;
  final String? company;
  final String? blog;
  final String? location;
  final String? email;
  final bool? hireable;
  final String? bio;
  final int publicRepos;
  final int followers;
  final int following;
  final String? createdAt;
  final String? updatedAt;
  final int totalPrivateRepos;
  final int ownedPrivateRepos;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      login: json['login'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      type: json['type'] as String? ?? 'User',
      name: json['name'] as String?,
      company: json['company'] as String?,
      blog: json['blog'] as String?,
      location: json['location'] as String?,
      email: json['email'] as String?,
      hireable: json['hireable'] as bool?,
      bio: json['bio'] as String?,
      publicRepos: (json['public_repos'] as num?)?.toInt() ?? 0,
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      following: (json['following'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      totalPrivateRepos: (json['total_private_repos'] as num?)?.toInt() ?? 0,
      ownedPrivateRepos: (json['owned_private_repos'] as num?)?.toInt() ?? 0,
    );
  }

  factory UserDto.fromDomain(User user) {
    return UserDto(
      login: user.login,
      avatarUrl: user.avatarUrl,
      type: user.type,
      name: user.name,
      company: user.company,
      blog: user.blog,
      location: user.location,
      email: user.email,
      hireable: user.hireable,
      bio: user.bio,
      publicRepos: user.publicRepos,
      followers: user.followers,
      following: user.following,
      createdAt: user.createdAt?.toIso8601String(),
      updatedAt: user.updatedAt?.toIso8601String(),
      totalPrivateRepos: user.totalPrivateRepos,
      ownedPrivateRepos: user.ownedPrivateRepos,
    );
  }

  Map<String, dynamic> toJson() => {
    'login': login,
    'avatar_url': avatarUrl,
    'type': type,
    'name': name,
    'company': company,
    'blog': blog,
    'location': location,
    'email': email,
    'hireable': hireable,
    'bio': bio,
    'public_repos': publicRepos,
    'followers': followers,
    'following': following,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'total_private_repos': totalPrivateRepos,
    'owned_private_repos': ownedPrivateRepos,
  };

  User toDomain() {
    return User(
      login: login,
      avatarUrl: avatarUrl,
      type: type,
      name: name,
      company: company,
      blog: blog,
      location: location,
      email: email,
      hireable: hireable,
      bio: bio,
      publicRepos: publicRepos,
      followers: followers,
      following: following,
      createdAt: _parseDate(createdAt),
      updatedAt: _parseDate(updatedAt),
      totalPrivateRepos: totalPrivateRepos,
      ownedPrivateRepos: ownedPrivateRepos,
    );
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
