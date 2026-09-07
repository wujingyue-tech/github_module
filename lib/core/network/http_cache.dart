import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

CacheStore createCacheStore() {
  return MemCacheStore(maxSize: 8 * 1024 * 1024);
}

CacheOptions createCacheOptions({required CacheStore store}) {
  return CacheOptions(
    store: store,
    policy: CachePolicy.request,
    maxStale: const Duration(hours: 1),
    hitCacheOnErrorCodes: const [500, 502, 503, 504],
    hitCacheOnNetworkFailure: true,
  );
}
