/// GitHub account identity as it appears nested on other resources
/// (repo owner, issue author). Not a profile — no follower counts or bio.
class UserRef {
  const UserRef({
    required this.login,
    required this.avatarUrl,
    required this.type,
    this.name,
  });

  final String login;
  final String avatarUrl;
  final String type;
  final String? name;
}
