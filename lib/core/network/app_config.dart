enum AppEnv { github, sandbox }

class AppConfig {
  const AppConfig({
    required this.env,
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    this.apiVersion = '2022-11-28',
  });

  final AppEnv env;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String apiVersion;

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
  }) {
    return AppConfig(
      env: env ?? this.env,
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      apiVersion: apiVersion ?? this.apiVersion,
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
  }) {
    final preset = switch (envName) {
      'sandbox' => sandbox,
      _ => github,
    };
    if (baseUrl.isEmpty) return preset;
    return preset.copyWith(baseUrl: baseUrl);
  }
}
