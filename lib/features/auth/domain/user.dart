/// Signed-in GitHub profile (`GET /user`). Nested owners/authors use [UserRef].
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int totalPrivateRepos;
  final int ownedPrivateRepos;
}
