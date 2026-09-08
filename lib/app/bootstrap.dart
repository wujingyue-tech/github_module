import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/app/app.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/app/error_hooks.dart';
import 'package:learn_flutter/app/preview.dart';
import 'package:learn_flutter/core/analytics/posthog/init_posthog.dart';
import 'package:learn_flutter/core/app_info.dart';
import 'package:learn_flutter/core/crash_reporting/sentry/init_sentry.dart';
import 'package:learn_flutter/core/network/app_config.dart';
import 'package:learn_flutter/features/session/domain/auth_session.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';
import 'package:learn_flutter/features/session/presentation/settings_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Loads persisted auth and settings before the first frame.
///
/// Restore failures are reported and ignored so the app can still start
/// logged-out with default settings. The [ProviderContainer] lives for the
/// process lifetime.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();
  final config = AppConfig.resolve();
  await initSentry(
    dsn: config.sentryDsn,
    environment: config.env.name,
    release:
        '${packageInfo.packageName}@${packageInfo.version}+${packageInfo.buildNumber}',
    dist: packageInfo.buildNumber,
  );
  await initPosthog(
    apiKey: config.posthogApiKey,
    host: config.posthogHost,
  );
  final talker = TalkerFlutter.init(logger: TalkerLogger(output: debugPrint));
  final container = ProviderContainer(
    retry: kDebugMode && appPreview != AppPreview.off ? (_, _) => null : null,
    overrides: [
      talkerProvider.overrideWithValue(talker),
      appConfigProvider.overrideWithValue(config),
      appInfoProvider.overrideWithValue(
        AppInfo(
          version: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
        ),
      ),
      if (kDebugMode) ...previewOverrides(),
    ],
  );
  final log = container.read(appLogProvider);
  installErrorHooks(log);
  await restoreForStartup(
    container,
    onError: (error, stackTrace) {
      log.report(error, stackTrace, 'startup restore');
    },
  );
  bindCrashReporterUser(container);
  bindAnalyticsUser(container);
  if (config.posthogApiKey.isEmpty) {
    log.warn('analytics: disabled (empty POSTHOG_API_KEY)');
  }
  runApp(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
}

/// Keeps Sentry's user id in sync with the GitHub login. Never sends the PAT.
void bindCrashReporterUser(ProviderContainer container) {
  container.listen<AuthSession>(sessionProvider, (_, next) {
    container.read(crashReporterProvider).setUser(id: next.user?.login);
  }, fireImmediately: true);
}

/// Keeps PostHog's distinct id in sync with the GitHub login. Never sends the PAT.
///
/// A cold start while logged out must not call [AppAnalytics.reset] — that
/// races the first `$screen` and can wipe the install-verification event.
void bindAnalyticsUser(ProviderContainer container) {
  container.listen<AuthSession>(sessionProvider, (prev, next) {
    final analytics = container.read(appAnalyticsProvider);
    final id = next.user?.login;
    if (id != null && id.isNotEmpty) {
      analytics.identify(id: id);
    } else if (prev?.user?.login != null) {
      analytics.reset();
    }
  }, fireImmediately: true);
}

/// Restores session and settings independently. A failure in one does not
/// block the other or prevent [runApp].
Future<void> restoreForStartup(
  ProviderContainer container, {
  required void Function(Object error, StackTrace stackTrace) onError,
}) async {
  await Future.wait([
    _restoreIgnoringErrors(
      () => container.read(sessionProvider.notifier).restore(),
      onError,
    ),
    _restoreIgnoringErrors(
      () => container.read(settingsProvider.notifier).restore(),
      onError,
    ),
  ]);
}

Future<void> _restoreIgnoringErrors(
  Future<void> Function() restore,
  void Function(Object error, StackTrace stackTrace) onError,
) async {
  try {
    await restore();
  } catch (error, stackTrace) {
    onError(error, stackTrace);
  }
}
