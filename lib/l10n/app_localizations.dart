import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GitHub Learn'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'GitHub Sign In'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GitHub no longer allows username and password for the API.\nThis demo signs in with a Personal Access Token.'**
  String get loginSubtitle;

  /// No description provided for @tokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal Access Token'**
  String get tokenLabel;

  /// No description provided for @tokenHint.
  ///
  /// In en, this message translates to:
  /// **'Starts with ghp_ or github_pat_'**
  String get tokenHint;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @tokenHelp.
  ///
  /// In en, this message translates to:
  /// **'How to get a token\n1. Open github.com/settings/tokens\n2. Generate new token (classic)\n3. Enable read:user (profile) and repo (repository list, including private)\n4. Paste it above (shown only once — save it)'**
  String get tokenHelp;

  /// No description provided for @loggedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get loggedIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @savedToken.
  ///
  /// In en, this message translates to:
  /// **'Token saved'**
  String get savedToken;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @debugLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get debugLogs;

  /// No description provided for @uploadLogs.
  ///
  /// In en, this message translates to:
  /// **'Upload logs'**
  String get uploadLogs;

  /// No description provided for @uploadLogsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Uploaded. Dump id: {id}'**
  String uploadLogsSuccess(String id);

  /// No description provided for @logDumpUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Log upload is not configured. Set LOG_DUMP_URL.'**
  String get logDumpUnavailable;

  /// No description provided for @minimizeLogs.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimizeLogs;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get themeColor;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorCyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get colorCyan;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get colorIndigo;

  /// No description provided for @authErrorEmptyToken.
  ///
  /// In en, this message translates to:
  /// **'Please enter a token'**
  String get authErrorEmptyToken;

  /// No description provided for @authErrorEmptyResponse.
  ///
  /// In en, this message translates to:
  /// **'Empty server response'**
  String get authErrorEmptyResponse;

  /// No description provided for @authErrorInvalidToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired token. Generate a new one on GitHub.'**
  String get authErrorInvalidToken;

  /// No description provided for @authErrorForbidden.
  ///
  /// In en, this message translates to:
  /// **'Insufficient permission. The token needs at least read:user.'**
  String get authErrorForbidden;

  /// No description provided for @authErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Check your network.'**
  String get authErrorTimeout;

  /// No description provided for @authErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'No network connection.'**
  String get authErrorOffline;

  /// No description provided for @authErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait and try again.'**
  String get authErrorRateLimited;

  /// No description provided for @authErrorParseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not parse the server response.'**
  String get authErrorParseFailed;

  /// No description provided for @authErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get authErrorFailed;

  /// No description provided for @reposTab.
  ///
  /// In en, this message translates to:
  /// **'Repos'**
  String get reposTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @reposTitle.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get reposTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @reposEmpty.
  ///
  /// In en, this message translates to:
  /// **'No repositories yet'**
  String get reposEmpty;

  /// No description provided for @repoPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get repoPrivate;

  /// No description provided for @repoNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get repoNoDescription;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @publicRepos.
  ///
  /// In en, this message translates to:
  /// **'Repos'**
  String get publicRepos;

  /// No description provided for @privateRepos.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateRepos;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @joinedAt.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedAt(String date);

  /// No description provided for @starCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stars'**
  String starCount(int count);

  /// No description provided for @forkCount.
  ///
  /// In en, this message translates to:
  /// **'{count} forks'**
  String forkCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
