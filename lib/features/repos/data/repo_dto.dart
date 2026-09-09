import 'package:github_module/features/repos/data/owner_dto.dart';
import 'package:github_module/features/repos/domain/repo.dart';

class RepoDto {
  const RepoDto({
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
  final OwnerDto owner;
  final bool private;
  final String? description;
  final bool fork;
  final String? language;
  final int forksCount;
  final int stargazersCount;
  final String defaultBranch;
  final int openIssuesCount;
  final String? pushedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? licenseName;

  factory RepoDto.fromJson(Map<String, dynamic> json) {
    final license = json['license'];
    return RepoDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      owner: OwnerDto.fromJson(json['owner'] as Map<String, dynamic>),
      private: json['private'] as bool? ?? false,
      description: json['description'] as String?,
      fork: json['fork'] as bool? ?? false,
      language: json['language'] as String?,
      forksCount: (json['forks_count'] as num?)?.toInt() ?? 0,
      stargazersCount: (json['stargazers_count'] as num?)?.toInt() ?? 0,
      defaultBranch: json['default_branch'] as String? ?? 'main',
      openIssuesCount: (json['open_issues_count'] as num?)?.toInt() ?? 0,
      pushedAt: json['pushed_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      licenseName: license is Map<String, dynamic>
          ? license['name'] as String?
          : null,
    );
  }

  Repo toDomain() {
    return Repo(
      id: id,
      name: name,
      fullName: fullName,
      owner: owner.toDomain(),
      private: private,
      description: description,
      fork: fork,
      language: language,
      forksCount: forksCount,
      stargazersCount: stargazersCount,
      defaultBranch: defaultBranch,
      openIssuesCount: openIssuesCount,
      pushedAt: _parseDate(pushedAt),
      createdAt: _parseDate(createdAt),
      updatedAt: _parseDate(updatedAt),
      licenseName: licenseName,
    );
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
