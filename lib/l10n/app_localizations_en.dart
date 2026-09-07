// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GitHub Learn';

  @override
  String get loginTitle => 'GitHub Sign In';

  @override
  String get loginSubtitle =>
      'GitHub no longer allows username and password for the API.\nThis demo signs in with a Personal Access Token.';

  @override
  String get tokenLabel => 'Personal Access Token';

  @override
  String get tokenHint => 'Starts with ghp_ or github_pat_';

  @override
  String get signIn => 'Sign in';

  @override
  String get tokenHelp =>
      'How to get a token\n1. Open github.com/settings/tokens\n2. Generate new token (classic)\n3. Enable read:user (profile) and repo (repository list, including private)\n4. Paste it above (shown only once — save it)';

  @override
  String get loggedIn => 'Signed in';

  @override
  String get signOut => 'Sign out';

  @override
  String get savedToken => 'Token saved';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSystem => 'System default';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get themeColor => 'Theme color';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorRed => 'Red';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get authErrorEmptyToken => 'Please enter a token';

  @override
  String get authErrorEmptyResponse => 'Empty server response';

  @override
  String get authErrorInvalidToken =>
      'Invalid or expired token. Generate a new one on GitHub.';

  @override
  String get authErrorForbidden =>
      'Insufficient permission. The token needs at least read:user.';

  @override
  String get authErrorTimeout => 'Connection timed out. Check your network.';

  @override
  String get authErrorOffline => 'No network connection.';

  @override
  String get authErrorRateLimited =>
      'Too many requests. Please wait and try again.';

  @override
  String get authErrorParseFailed => 'Could not parse the server response.';

  @override
  String get authErrorFailed => 'Request failed';

  @override
  String get reposTab => 'Repos';

  @override
  String get profileTab => 'Profile';

  @override
  String get reposTitle => 'Repositories';

  @override
  String get profileTitle => 'Profile';

  @override
  String get reposEmpty => 'No repositories yet';

  @override
  String get repoPrivate => 'Private';

  @override
  String get repoNoDescription => 'No description';

  @override
  String get retry => 'Retry';

  @override
  String get publicRepos => 'Repos';

  @override
  String get privateRepos => 'Private';

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String joinedAt(String date) {
    return 'Joined $date';
  }

  @override
  String starCount(int count) {
    return '$count stars';
  }

  @override
  String forkCount(int count) {
    return '$count forks';
  }
}
