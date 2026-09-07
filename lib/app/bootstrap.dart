import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/app/app.dart';
import 'package:learn_flutter/app/preview.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';
import 'package:learn_flutter/features/session/presentation/settings_provider.dart';

/// Loads persisted auth and settings before the first frame.
///
/// Restore failures are reported and ignored so the app can still start
/// logged-out with default settings. The [ProviderContainer] lives for the
/// process lifetime.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(
    retry: kDebugMode && appPreview != AppPreview.off ? (_, _) => null : null,
    overrides: [if (kDebugMode) ...previewOverrides()],
  );
  await restoreForStartup(
    container,
    onError: (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'bootstrap',
          context: ErrorDescription('startup restore failed'),
        ),
      );
    },
  );
  runApp(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
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
