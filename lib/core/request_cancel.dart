class RequestCancelledException implements Exception {
  const RequestCancelledException();

  @override
  String toString() => 'RequestCancelledException';
}

/// Transport-agnostic cancel signal. HTTP maps it to Dio's CancelToken;
/// MQTT / BLE can unsubscribe in [whenCancelled].
class RequestCancel {
  var _cancelled = false;
  final _listeners = <void Function()>[];

  bool get isCancelled => _cancelled;

  void whenCancelled(void Function() listener) {
    if (_cancelled) {
      listener();
      return;
    }
    _listeners.add(listener);
  }

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }
}
