import 'package:flutter/foundation.dart';
import 'package:learn_flutter/core/logging/app_log.dart';

void installErrorHooks(AppLog log) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log.report(details.exception, details.stack, 'FlutterError');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log.report(error, stack, 'PlatformDispatcher');
    return true;
  };
}
