import 'package:github_module/features/auth/domain/user.dart';
import 'package:github_module/features/auth/domain/user_ref.dart';

/// Shared fixtures for Fake repositories and widget tests. Domain types only.
const previewUserRef = UserRef(
  login: 'octocat',
  avatarUrl: 'https://example.com/a.png',
  type: 'User',
  name: 'Octocat',
);

const previewUser = User(
  login: 'octocat',
  avatarUrl: 'https://example.com/a.png',
  type: 'User',
  name: 'Octocat',
  publicRepos: 0,
  followers: 0,
  following: 0,
  totalPrivateRepos: 0,
  ownedPrivateRepos: 0,
);
