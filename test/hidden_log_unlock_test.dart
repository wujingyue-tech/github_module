import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/hidden_log_unlock.dart';

void main() {
  testWidgets('unlocks after double-tap, hold, double-tap', (tester) async {
    var unlocked = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HiddenLogUnlock(
              holdDuration: const Duration(milliseconds: 50),
              onUnlocked: () => unlocked++,
              child: const Text('Version', key: Key('appVersion')),
            ),
          ),
        ),
      ),
    );

    final version = find.byKey(const Key('appVersion'));

    await tester.tap(version);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(version);
    await tester.pump();

    final gesture = await tester.startGesture(tester.getCenter(version));
    await tester.pump(const Duration(milliseconds: 80));
    await gesture.up();
    await tester.pump();

    await tester.tap(version);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(version);
    await tester.pump();
    await tester.pump(kDoubleTapTimeout);

    expect(unlocked, 1);
  });

  testWidgets('releasing the hold early does not unlock', (tester) async {
    var unlocked = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HiddenLogUnlock(
              holdDuration: const Duration(milliseconds: 80),
              onUnlocked: () => unlocked++,
              child: const Text('Version', key: Key('appVersion')),
            ),
          ),
        ),
      ),
    );

    final version = find.byKey(const Key('appVersion'));

    await tester.tap(version);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(version);
    await tester.pump();

    final gesture = await tester.startGesture(tester.getCenter(version));
    await tester.pump(const Duration(milliseconds: 20));
    await gesture.up();
    await tester.pump();

    await tester.tap(version);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(version);
    await tester.pump();
    await tester.pump(kDoubleTapTimeout);

    expect(unlocked, 0);
  });
}
