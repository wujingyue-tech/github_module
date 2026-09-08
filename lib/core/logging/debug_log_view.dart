import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Talker UI for the debug log route. Pages import this, not talker_flutter.
class DebugLogView extends StatelessWidget {
  const DebugLogView({
    super.key,
    required this.talker,
    required this.title,
    this.leading,
  });

  final Talker talker;
  final String title;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return TalkerView(
      talker: talker,
      theme: TalkerScreenTheme.fromTheme(Theme.of(context)),
      appBarTitle: title,
      appBarLeading: leading,
    );
  }
}
