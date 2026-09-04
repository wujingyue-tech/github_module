// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Repo _$RepoFromJson(Map<String, dynamic> json) => Repo(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  fullName: json['full_name'] as String,
  owner: User.fromJson(json['owner'] as Map<String, dynamic>),
  parent: json['parent'] == null
      ? null
      : Repo.fromJson(json['parent'] as Map<String, dynamic>),
  private: json['private'] as bool,
  description: json['description'] as String,
  fork: json['fork'] as bool,
  language: json['language'] as String?,
  forksCount: (json['forks_count'] as num).toInt(),
  stargazersCount: (json['stargazers_count'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  defaultBranch: json['default_branch'] as String,
  openIssuesCount: (json['open_issues_count'] as num).toInt(),
  pushedAt: json['pushed_at'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  subscribersCount: (json['subscribers_count'] as num?)?.toInt(),
  license: json['license'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$RepoToJson(Repo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'full_name': instance.fullName,
  'owner': instance.owner.toJson(),
  'parent': instance.parent?.toJson(),
  'private': instance.private,
  'description': instance.description,
  'fork': instance.fork,
  'language': instance.language,
  'forks_count': instance.forksCount,
  'stargazers_count': instance.stargazersCount,
  'size': instance.size,
  'default_branch': instance.defaultBranch,
  'open_issues_count': instance.openIssuesCount,
  'pushed_at': instance.pushedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'subscribers_count': instance.subscribersCount,
  'license': instance.license,
};
