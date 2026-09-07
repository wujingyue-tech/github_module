import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/app/di.dart';
import 'package:learn_flutter/l10n/app_localizations.dart';
import 'package:talker_flutter/talker_flutter.dart';

class LogViewerPage extends ConsumerWidget {
  const LogViewerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: TalkerView(
        talker: ref.watch(talkerProvider),
        theme: TalkerScreenTheme.fromTheme(Theme.of(context)),
        appBarTitle: l10n.debugLogs,
        appBarLeading: BackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}
