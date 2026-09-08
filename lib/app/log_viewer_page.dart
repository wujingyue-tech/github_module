import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/core/logging/debug_log_view.dart';
import 'package:learn_flutter/l10n/app_localizations.dart';

class LogViewerPage extends ConsumerWidget {
  const LogViewerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: DebugLogView(
        talker: ref.watch(talkerProvider),
        title: l10n.debugLogs,
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
    );
  }
}
