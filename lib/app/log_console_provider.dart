import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogConsoleState {
  const LogConsoleState({required this.unlocked});

  final bool unlocked;
}

class LogConsoleNotifier extends Notifier<LogConsoleState> {
  LogConsoleNotifier({this.startUnlocked});

  final bool? startUnlocked;

  @override
  LogConsoleState build() {
    return LogConsoleState(unlocked: startUnlocked ?? kDebugMode);
  }

  void unlock() {
    state = const LogConsoleState(unlocked: true);
  }
}

final logConsoleProvider =
    NotifierProvider<LogConsoleNotifier, LogConsoleState>(
      LogConsoleNotifier.new,
    );

final hiddenLogHoldProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 10),
);
