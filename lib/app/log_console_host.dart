import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:github_module/app/log_console_provider.dart';

class LogConsoleHost extends ConsumerStatefulWidget {
  const LogConsoleHost({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<LogConsoleHost> createState() => _LogConsoleHostState();
}

class _LogConsoleHostState extends ConsumerState<LogConsoleHost> {
  Offset? _bubble;

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_onRoute);
  }

  @override
  void didUpdateWidget(LogConsoleHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router.routerDelegate != widget.router.routerDelegate) {
      oldWidget.router.routerDelegate.removeListener(_onRoute);
      widget.router.routerDelegate.addListener(_onRoute);
    }
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRoute);
    super.dispose();
  }

  void _onRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  bool get _onLogs {
    final config = widget.router.routerDelegate.currentConfiguration;
    final last = config.lastOrNull;
    return last?.matchedLocation == '/logs' || config.uri.path == '/logs';
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = ref.watch(logConsoleProvider).unlocked;
    final size = MediaQuery.sizeOf(context);
    _bubble ??= Offset(size.width - 72, size.height - 168);

    return Stack(
      children: [
        widget.child,
        if (unlocked && !_onLogs)
          Positioned(
            left: _bubble!.dx.clamp(0, size.width - 56),
            top: _bubble!.dy.clamp(0, size.height - 56),
            child: _Bubble(
              onTap: () => widget.router.push('/logs'),
              onDrag: (delta) {
                setState(() {
                  _bubble = Offset(
                    (_bubble!.dx + delta.dx).clamp(0, size.width - 56),
                    (_bubble!.dy + delta.dy).clamp(0, size.height - 56),
                  );
                });
              },
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.onTap, required this.onDrag});

  final VoidCallback onTap;
  final ValueChanged<Offset> onDrag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      onPanUpdate: (details) => onDrag(details.delta),
      child: Material(
        key: const Key('logConsoleBubble'),
        elevation: 6,
        color: scheme.primary,
        shape: const CircleBorder(),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.bug_report, color: scheme.onPrimary),
        ),
      ),
    );
  }
}
