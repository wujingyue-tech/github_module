import 'package:dio/dio.dart';

import '../common/global.dart';

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

class NetCache extends Interceptor {
  final cache = <String, CacheObject>{};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (Global.profile.cache?.enable != true) {
      handler.next(options);
      return;
    }

    final refresh = options.extra["refresh"] == true;
    if (refresh) {
      if (options.extra["list"] == true) {
        cache.removeWhere((key, value) => key.contains(options.path));
      } else {
        delete(options.uri.toString());
      }
      handler.next(options);
      return;
    }
    if (options.extra["noCache"] != true &&
        options.method.toLowerCase() == 'get') {
      final String key = options.extra["cacheKey"] ?? options.uri.toString();
      final ob = cache[key];
      if (ob != null) {
        // 若缓存未过期，则返回缓存内容
        if ((DateTime.now().millisecondsSinceEpoch - ob.timestamp) / 1000 <
            Global.profile.cache!.maxAge) {
          handler.resolve(ob.response);
          return;
        }
        // 若已过期则删除缓存，继续向服务器请求
        cache.remove(key);
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (Global.profile.cache?.enable == true) {
      _saveCache(response);
    }
    handler.next(response);
  }

  void _saveCache(Response object) {
    final options = object.requestOptions;
    if (options.extra["noCache"] != true &&
        options.method.toLowerCase() == "get") {
      if (cache.length == Global.profile.cache!.maxCount) {
        cache.remove(cache.keys.first);
      }
      final String key = options.extra["cacheKey"] ?? options.uri.toString();
      cache[key] = CacheObject(object);
    }
  }

  void delete(String key) {
    cache.remove(key);
  }
}
