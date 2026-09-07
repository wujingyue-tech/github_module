class AppConfig {
  const AppConfig({
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    this.apiVersion = '2022-11-28',
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String apiVersion;

  static const github = AppConfig(
    baseUrl: 'https://api.github.com/',
    connectTimeout: Duration(seconds: 8),
    receiveTimeout: Duration(seconds: 8),
  );
}
