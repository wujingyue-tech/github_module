import 'package:learn_flutter/core/error/app_exception.dart';
import 'package:learn_flutter/l10n/app_localizations.dart';

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
  if (error is AppException) {
    return switch (error.code) {
      AppErrorCode.emptyToken => l10n.authErrorEmptyToken,
      AppErrorCode.emptyResponse => l10n.authErrorEmptyResponse,
      AppErrorCode.invalidToken => l10n.authErrorInvalidToken,
      AppErrorCode.forbidden => l10n.authErrorForbidden,
      AppErrorCode.rateLimited => l10n.authErrorRateLimited,
      AppErrorCode.timeout => l10n.authErrorTimeout,
      AppErrorCode.offline => l10n.authErrorOffline,
      AppErrorCode.parseFailed => l10n.authErrorParseFailed,
      AppErrorCode.failed => l10n.authErrorFailed,
      AppErrorCode.logDumpUnavailable => l10n.logDumpUnavailable,
    };
  }
  return l10n.authErrorFailed;
}
