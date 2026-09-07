import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/logging/log_dump.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';
import 'package:learn_flutter/features/session/presentation/settings_page.dart';
import 'package:learn_flutter/features/session/presentation/settings_provider.dart';
import 'package:learn_flutter/l10n/app_localizations_en.dart';

import 'support/fake_log_dump.dart';
import 'support/pump_app.dart';

final _l10n = AppLocalizationsEn();

void main() {
  testWidgets('debug overlay shows the floating console bubble', (
    tester,
  ) async {
    await pumpMainApp(
      tester,
      overrides: [authStoreProvider.overrideWithValue(MemoryAuthStore())],
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('logConsoleBubble')), findsOneWidget);
  });

  testWidgets('tapping the bubble opens the full logs page', (tester) async {
    await pumpMainApp(
      tester,
      overrides: [authStoreProvider.overrideWithValue(MemoryAuthStore())],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('logConsoleBubble')));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.debugLogs), findsWidgets);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('settings upload shows the dump id', (tester) async {
    final dump = FakeLogDump(report: const LogDumpReport(id: 'abc-1'));
    await pumpPage(
      tester,
      const SettingsPage(),
      overrides: [
        logDumpProvider.overrideWithValue(dump),
        settingsStoreProvider.overrideWithValue(MemorySettingsStore()),
      ],
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(_l10n.uploadLogs),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(_l10n.uploadLogs));
    await tester.pumpAndSettle();

    expect(dump.uploadCount, 1);
    expect(find.text(_l10n.uploadLogsSuccess('abc-1')), findsOneWidget);
  });
}
