import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/app/app.dart';
import 'package:learn_flutter/app/preview.dart';
import 'package:learn_flutter/features/session/presentation/session_provider.dart';
import 'package:learn_flutter/features/session/presentation/settings_provider.dart';

/// Loads persisted auth and settings before the first frame.
///
/// The [ProviderContainer] lives for the process lifetime. It is only
/// disposed if restore fails before [runApp].
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(
    /// https://riverpod.dev/docs/concepts2/retry
    // retry: (_, _) => null,
    overrides: [if (kDebugMode) ...previewOverrides()],
  );
  try {
    await Future.wait([
      container.read(sessionProvider.notifier).restore(),
      container.read(settingsProvider.notifier).restore(),
    ]);
  } catch (_) {
    container.dispose();
    rethrow;
  }
  runApp(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
}
