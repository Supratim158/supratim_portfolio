import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Subtle floating / bobbing animation for hero code windows.
class FloatingAnimation extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration period;

  const FloatingAnimation({
    super.key,
    required this.child,
    this.amplitude = 8.0,
    this.period = const Duration(seconds: 3),
  });

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy =
            math.sin(_controller.value * 2 * math.pi) * widget.amplitude;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
