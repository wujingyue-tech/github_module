enum AppEnv { github, sandbox }

class AppConfig {
  const AppConfig({
    required this.env,
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    this.apiVersion = '2022-11-28',
    this.logDumpUrl = '',
    this.sentryDsn = '',
  });

  final AppEnv env;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String apiVersion;

  /// Absolute URL for diagnostic log upload. Empty means upload is disabled.
  /// Set with `--dart-define=LOG_DUMP_URL=https://...`.
  final String logDumpUrl;

  /// Sentry DSN (sentry.io, self-hosted, or GlitchTip). Empty disables Sentry.
  /// Set with `--dart-define=SENTRY_DSN=https://...`.
  final String sentryDsn;

  static const github = AppConfig(
    env: AppEnv.github,
    baseUrl: 'https://api.github.com/',
    connectTimeout: Duration(seconds: 8),
    receiveTimeout: Duration(seconds: 8),
  );

  /// Local fake GitHub-shaped API. Override the URL with `API_BASE_URL`
  /// (Android emulator typically needs `http://10.0.2.2:8080/`).
  static const sandbox = AppConfig(
    env: AppEnv.sandbox,
    baseUrl: 'http://127.0.0.1:8080/',
    connectTimeout: Duration(seconds: 8),
    receiveTimeout: Duration(seconds: 8),
  );

  AppConfig copyWith({
    AppEnv? env,
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    String? apiVersion,
    String? logDumpUrl,
    String? sentryDsn,
  }) {
    return AppConfig(
      env: env ?? this.env,
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      apiVersion: apiVersion ?? this.apiVersion,
      logDumpUrl: logDumpUrl ?? this.logDumpUrl,
      sentryDsn: sentryDsn ?? this.sentryDsn,
    );
  }

  /// Compile-time env via `--dart-define=APP_ENV=sandbox` and optional
  /// `--dart-define=API_BASE_URL=...`. Tests pass [envName] / [baseUrl] directly.
  static AppConfig resolve({
    String envName = const String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'github',
    ),
    String baseUrl = const String.fromEnvironment('API_BASE_URL'),
    String logDumpUrl = const String.fromEnvironment('LOG_DUMP_URL'),
    String sentryDsn = const String.fromEnvironment('SENTRY_DSN'),
  }) {
    final preset = switch (envName) {
      'sandbox' => sandbox,
      _ => github,
    };
    var config = preset;
    if (baseUrl.isNotEmpty) config = config.copyWith(baseUrl: baseUrl);
    if (logDumpUrl.isNotEmpty) {
      config = config.copyWith(logDumpUrl: logDumpUrl);
    }
    if (sentryDsn.isNotEmpty) {
      config = config.copyWith(sentryDsn: sentryDsn);
    }
    return config;
  }
}
