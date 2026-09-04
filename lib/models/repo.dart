import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'repo.g.dart';

@JsonSerializable(explicitToJson: true)
class Repo {
  const Repo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.owner,
    this.parent,
    required this.private,
    required this.description,
    required this.fork,
    this.language,
    required this.forksCount,
    required this.stargazersCount,
    required this.size,
    required this.defaultBranch,
    required this.openIssuesCount,
    required this.pushedAt,
    required this.createdAt,
    required this.updatedAt,
    this.subscribersCount,
    this.license,
  });

  final int id;
  final String name;

  @JsonKey(name: 'full_name')
  final String fullName;

  final User owner;
  final Repo? parent;
  final bool private;
  final String description;
  final bool fork;
  final String? language;

  @JsonKey(name: 'forks_count')
  final int forksCount;

  @JsonKey(name: 'stargazers_count')
  final int stargazersCount;

  final int size;

  @JsonKey(name: 'default_branch')
  final String defaultBranch;

  @JsonKey(name: 'open_issues_count')
  final int openIssuesCount;

  @JsonKey(name: 'pushed_at')
  final String pushedAt;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @JsonKey(name: 'subscribers_count')
  final int? subscribersCount;

  final Map<String, dynamic>? license;

  factory Repo.fromJson(Map<String, dynamic> json) => _$RepoFromJson(json);
  Map<String, dynamic> toJson() => _$RepoToJson(this);
}