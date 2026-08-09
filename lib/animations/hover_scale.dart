import 'package:flutter/material.dart';

/// Hover lift + scale effect for cards and buttons (web-friendly).
class HoverScale extends StatefulWidget {
  final Widget child;
  final double scale;
  final double liftY;
  final Duration duration;

  const HoverScale({
    super.key,
    required this.child,
    this.scale = 1.03,
    this.liftY = -4,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _hovering ? widget.liftY : 0.0)
          ..scale(_hovering ? widget.scale : 1.0),
        child: widget.child,
      ),
    );
  }
}
