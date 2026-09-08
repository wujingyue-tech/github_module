import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/app/di.dart';

/// Flushes the analytics queue when the app leaves the foreground.
class AnalyticsLifecycle extends ConsumerStatefulWidget {
  const AnalyticsLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AnalyticsLifecycle> createState() => _AnalyticsLifecycleState();
}

class _AnalyticsLifecycleState extends ConsumerState<AnalyticsLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      ref.read(appAnalyticsProvider).flush();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
