import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/core/network/http_cache.dart';

void main() {
  test('uses request policy and a one-hour stale window', () {
    final options = createCacheOptions(store: MemCacheStore());
    expect(options.policy, CachePolicy.request);
    expect(options.maxStale, const Duration(hours: 1));
  });
}
