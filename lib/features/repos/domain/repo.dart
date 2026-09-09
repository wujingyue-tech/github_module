import 'package:github_module/features/auth/domain/user_ref.dart';

class Repo {
  const Repo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.owner,
    required this.private,
    this.description,
    required this.fork,
    this.language,
    required this.forksCount,
    required this.stargazersCount,
    required this.defaultBranch,
    required this.openIssuesCount,
    this.pushedAt,
    this.createdAt,
    this.updatedAt,
    this.licenseName,
  });

  final int id;
  final String name;
  final String fullName;
  final UserRef owner;
  final bool private;
  final String? description;
  final bool fork;
  final String? language;
  final int forksCount;
  final int stargazersCount;
  final String defaultBranch;
  final int openIssuesCount;
  final DateTime? pushedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? licenseName;
}
