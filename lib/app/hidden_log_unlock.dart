import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Double-tap, then hold [holdDuration], then double-tap again.
class HiddenLogUnlock extends StatefulWidget {
  const HiddenLogUnlock({
    super.key,
    required this.onUnlocked,
    required this.holdDuration,
    required this.child,
  });

  final VoidCallback onUnlocked;
  final Duration holdDuration;
  final Widget child;

  @override
  State<HiddenLogUnlock> createState() => _HiddenLogUnlockState();
}

enum _Phase { idle, waitHold, holding, waitSecondDouble }

class _HiddenLogUnlockState extends State<HiddenLogUnlock> {
  _Phase _phase = _Phase.idle;
  Timer? _holdTimer;
  Timer? _resetTimer;

  @override
  void dispose() {
    _holdTimer?.cancel();
    _resetTimer?.cancel();
    super.dispose();
  }

  void _armReset(Duration duration) {
    _resetTimer?.cancel();
    _resetTimer = Timer(duration, _reset);
  }

  void _reset() {
    _holdTimer?.cancel();
    _resetTimer?.cancel();
    if (mounted) setState(() => _phase = _Phase.idle);
  }

  void _onDoubleTap() {
    if (_phase == _Phase.idle) {
      setState(() => _phase = _Phase.waitHold);
      _armReset(const Duration(seconds: 3));
      return;
    }
    if (_phase == _Phase.waitSecondDouble) {
      _resetTimer?.cancel();
      HapticFeedback.mediumImpact();
      widget.onUnlocked();
      _reset();
    }
  }

  void _onPointerDown(PointerDownEvent _) {
    if (_phase != _Phase.waitHold) return;
    _resetTimer?.cancel();
    setState(() => _phase = _Phase.holding);
    _holdTimer?.cancel();
    _holdTimer = Timer(widget.holdDuration, () {
      if (!mounted || _phase != _Phase.holding) return;
      setState(() => _phase = _Phase.waitSecondDouble);
      _armReset(const Duration(seconds: 5));
    });
  }

  void _onPointerEnd(PointerEvent _) {
    if (_phase != _Phase.holding) return;
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerEnd,
        onPointerCancel: _onPointerEnd,
        child: widget.child,
      ),
    );
  }
}
