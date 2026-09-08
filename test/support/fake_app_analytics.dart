import 'package:learn_flutter/core/analytics/app_analytics.dart';

class FakeAppAnalytics implements AppAnalytics {
  final screens = <String>[];
  final events = <({String name, Map<String, Object>? properties})>[];
  final identifies = <String?>[];
  var resetCount = 0;
  var flushCount = 0;

  String? get userId {
    if (identifies.isEmpty) return null;
    final id = identifies.last;
    if (id == null || id.isEmpty) return null;
    return id;
  }

  @override
  Future<void> screen(String name) async {
    screens.add(name);
  }

  @override
  Future<void> event(String name, [Map<String, Object>? properties]) async {
    events.add((name: name, properties: properties));
  }

  @override
  Future<void> identify({String? id}) async {
    identifies.add(id);
  }

  @override
  Future<void> reset() async {
    resetCount++;
    identifies.add(null);
  }

  @override
  Future<void> flush() async {
    flushCount++;
  }
}
