import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/core/network/cache_config.dart';
import 'package:learn_flutter/core/network/http_cache.dart';

void main() {
  test('enabled config uses request policy like a browser', () {
    final options = createCacheOptions(
      const CacheConfig(enable: true, maxAge: 3600, maxCount: 100),
      store: MemCacheStore(),
    );
    expect(options.policy, CachePolicy.request);
    expect(options.maxStale, const Duration(seconds: 3600));
  });

  test('disabled config uses noCache policy', () {
    final options = createCacheOptions(
      const CacheConfig(enable: false, maxAge: 60, maxCount: 10),
      store: MemCacheStore(),
    );
    expect(options.policy, CachePolicy.noCache);
  });
}
