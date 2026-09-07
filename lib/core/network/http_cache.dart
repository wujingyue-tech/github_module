import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import 'cache_config.dart';

CacheStore createCacheStore(CacheConfig config) {
  final maxSize = (config.maxCount * 64 * 1024).clamp(
    2560000,
    16 * 1024 * 1024,
  );
  return MemCacheStore(maxSize: maxSize);
}

CacheOptions createCacheOptions(
  CacheConfig config, {
  required CacheStore store,
}) {
  return CacheOptions(
    store: store,
    policy: config.enable ? CachePolicy.request : CachePolicy.noCache,
    maxStale: Duration(seconds: config.maxAge),
    hitCacheOnErrorCodes: const [500, 502, 503, 504],
    hitCacheOnNetworkFailure: true,
  );
}
