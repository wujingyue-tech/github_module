import 'package:dio/dio.dart';

import 'cache_config.dart';

class CacheObject {
  CacheObject(this.response)
    : timestamp = DateTime.now().millisecondsSinceEpoch;

  Response response;
  int timestamp;

  @override
  bool operator ==(Object other) {
    return other is CacheObject && response.hashCode == other.response.hashCode;
  }

  @override
  int get hashCode => response.hashCode;
}

/// In-memory GET cache. Entries live for the process lifetime only.
class NetCache extends Interceptor {
  NetCache({required this.readConfig});

  final CacheConfig Function() readConfig;
  final cache = <String, CacheObject>{};

  CacheConfig get _config => readConfig();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final config = _config;
    if (!config.enable) {
      handler.next(options);
      return;
    }

    final refresh = options.extra['refresh'] == true;
    if (refresh) {
      if (options.extra['list'] == true) {
        cache.removeWhere((key, value) => key.contains(options.path));
      } else {
        delete(options.uri.toString());
      }
      handler.next(options);
      return;
    }
    if (options.extra['noCache'] != true &&
        options.method.toLowerCase() == 'get') {
      final String key = options.extra['cacheKey'] ?? options.uri.toString();
      final ob = cache[key];
      if (ob != null) {
        if ((DateTime.now().millisecondsSinceEpoch - ob.timestamp) / 1000 <
            config.maxAge) {
          handler.resolve(ob.response);
          return;
        }
        cache.remove(key);
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_config.enable) {
      _saveCache(response);
    }
    handler.next(response);
  }

  void _saveCache(Response object) {
    final config = _config;
    final options = object.requestOptions;
    if (options.extra['noCache'] != true &&
        options.method.toLowerCase() == 'get') {
      if (cache.length == config.maxCount) {
        cache.remove(cache.keys.first);
      }
      final String key = options.extra['cacheKey'] ?? options.uri.toString();
      cache[key] = CacheObject(object);
    }
  }

  void delete(String key) {
    cache.remove(key);
  }
}
