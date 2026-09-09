import 'package:flutter/foundation.dart';
import 'package:github_module/core/logging/app_log.dart';

void installErrorHooks(AppLog log) {
  FlutterError.onError = (details) {
    if (_isListTileInkHiddenAssertion(details)) {
      return;
    }
    FlutterError.presentError(details);
    log.report(details.exception, details.stack, 'FlutterError');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log.report(error, stack, 'PlatformDispatcher');
    return true;
  };
}

/// talker_flutter wraps ListTiles in a colored card; Flutter 3.32+ asserts.
bool _isListTileInkHiddenAssertion(FlutterErrorDetails details) {
  return details.exceptionAsString().contains(
    'ListTile background color or ink splashes may be invisible',
  );
}
