/// Marketing version and store build number from the packaged app
/// (`pubspec.yaml` `version: name+build`).
class AppInfo {
  const AppInfo({required this.version, required this.buildNumber});

  /// Used in tests and before bootstrap injects [PackageInfo].
  static const unset = AppInfo(version: '0.0.0', buildNumber: '0');

  /// `CFBundleShortVersionString` / Android `versionName` (e.g. `2026.1.0`).
  final String version;

  /// `CFBundleVersion` / Android `versionCode` (e.g. `1`).
  final String buildNumber;

  String get label => '$version ($buildNumber)';
}
