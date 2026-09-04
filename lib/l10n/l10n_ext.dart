import '../l10n/app_localizations.dart';
import '../services/github_api.dart';

String colorLabel(AppLocalizations l10n, int index) {
  return switch (index) {
    0 => l10n.colorBlue,
    1 => l10n.colorCyan,
    2 => l10n.colorTeal,
    3 => l10n.colorGreen,
    4 => l10n.colorRed,
    5 => l10n.colorOrange,
    6 => l10n.colorPurple,
    7 => l10n.colorPink,
    8 => l10n.colorIndigo,
    _ => l10n.colorBlue,
  };
}

String authErrorText(AppLocalizations l10n, Object error) {
  if (error is AuthException) {
    return switch (error.code) {
      AuthErrorCode.emptyToken => l10n.authErrorEmptyToken,
      AuthErrorCode.emptyResponse => l10n.authErrorEmptyResponse,
      AuthErrorCode.invalidToken => l10n.authErrorInvalidToken,
      AuthErrorCode.forbidden => l10n.authErrorForbidden,
      AuthErrorCode.timeout => l10n.authErrorTimeout,
      AuthErrorCode.failed => l10n.authErrorFailed,
    };
  }
  return l10n.authErrorFailed;
}
