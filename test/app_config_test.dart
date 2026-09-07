import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/network/app_config.dart';

void main() {
  test('resolve defaults to GitHub', () {
    final config = AppConfig.resolve();
    expect(config.env, AppEnv.github);
    expect(config.baseUrl, 'https://api.github.com/');
  });

  test('APP_ENV=sandbox selects the sandbox preset', () {
    final config = AppConfig.resolve(envName: 'sandbox');
    expect(config.env, AppEnv.sandbox);
    expect(config.baseUrl, 'http://127.0.0.1:8080/');
  });

  test('API_BASE_URL overrides the preset host', () {
    final config = AppConfig.resolve(
      envName: 'sandbox',
      baseUrl: 'http://10.0.2.2:8080/',
    );
    expect(config.env, AppEnv.sandbox);
    expect(config.baseUrl, 'http://10.0.2.2:8080/');
  });

  test('LOG_DUMP_URL is attached without changing the API host', () {
    final config = AppConfig.resolve(
      logDumpUrl: 'https://dumps.example/upload',
    );
    expect(config.env, AppEnv.github);
    expect(config.baseUrl, 'https://api.github.com/');
    expect(config.logDumpUrl, 'https://dumps.example/upload');
  });

  test('unknown APP_ENV falls back to GitHub', () {
    expect(AppConfig.resolve(envName: 'staging').env, AppEnv.github);
  });
}
