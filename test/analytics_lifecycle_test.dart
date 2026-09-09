import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_module/app/di.dart';
import 'package:github_module/app/store_providers.dart';
import 'package:github_module/features/repos/data/fake_repo_repository.dart';

import 'support/fake_app_analytics.dart';
import 'support/pump_app.dart';

void main() {
  testWidgets('backgrounding flushes the analytics queue', (tester) async {
    final analytics = FakeAppAnalytics();
    await pumpMainApp(
      tester,
      overrides: [
        appAnalyticsProvider.overrideWithValue(analytics),
        authStoreProvider.overrideWithValue(MemoryAuthStore()),
        repoRepositoryProvider.overrideWithValue(FakeRepoRepository.empty()),
      ],
    );
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(analytics.flushCount, 1);
  });
}
