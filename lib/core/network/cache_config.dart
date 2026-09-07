class CacheConfig {
  const CacheConfig({
    required this.enable,
    required this.maxAge,
    required this.maxCount,
  });

  final bool enable;
  final int maxAge;
  final int maxCount;

  static const defaults = CacheConfig(
    enable: true,
    maxAge: 3600,
    maxCount: 100,
  );

  factory CacheConfig.fromJson(Map<String, dynamic> json) {
    return CacheConfig(
      enable: json['enable'] as bool? ?? defaults.enable,
      maxAge: (json['maxAge'] as num?)?.toInt() ?? defaults.maxAge,
      maxCount: (json['maxCount'] as num?)?.toInt() ?? defaults.maxCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'enable': enable,
    'maxAge': maxAge,
    'maxCount': maxCount,
  };
}
