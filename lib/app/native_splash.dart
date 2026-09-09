import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

/// Pins the OS launch splash until [removeNativeSplash].
///
/// Pages must not import `flutter_native_splash`.
void preserveNativeSplash(WidgetsBinding binding) {
  FlutterNativeSplash.preserve(widgetsBinding: binding);
}

void removeNativeSplash() {
  FlutterNativeSplash.remove();
}
