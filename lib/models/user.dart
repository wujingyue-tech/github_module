import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  const User({
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
    required this.createdAt,
    required this.updatedAt,
    required this.totalPrivateRepos,
    required this.ownedPrivateRepos,
  });

  final String login;

  @JsonKey(name: 'avatar_url')
  final String avatarUrl;

  final String type;
  final String? name;
  final String? company;
  final String? blog;
  final String? location;
  final String? email;
  final bool? hireable;
  final String? bio;

  @JsonKey(name: 'public_repos', defaultValue: 0)
  final int publicRepos;

  @JsonKey(defaultValue: 0)
  final int followers;

  @JsonKey(defaultValue: 0)
  final int following;

  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;

  @JsonKey(name: 'updated_at', defaultValue: '')
  final String updatedAt;

  @JsonKey(name: 'total_private_repos', defaultValue: 0)
  final int totalPrivateRepos;

  @JsonKey(name: 'owned_private_repos', defaultValue: 0)
  final int ownedPrivateRepos;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}