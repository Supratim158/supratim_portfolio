import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// A wrapper that adds pull-to-refresh behavior on all platforms.
/// When the user pulls down from the top of the scroll, it shows a
/// "reboot" indicator. On release past the threshold, it navigates
/// to the loader screen.
///
/// This uses pointer events for universal compatibility across
/// mobile, web, and desktop.
class PullToReload extends StatefulWidget {
  final Widget child;

  const PullToReload({super.key, required this.child});

  @override
  State<PullToReload> createState() => _PullToReloadState();
}

class _PullToReloadState extends State<PullToReload>
    with SingleTickerProviderStateMixin {
  double _pullDistance = 0.0;
  bool _isPulling = false;
  bool _triggered = false;
  bool _isAtTop = true;

  static const double _triggerThreshold = 130.0;
  static const double _damping = 0.45;

  late AnimationController _resetController;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _animateReset() {
    final startValue = _pullDistance;
    _resetController.reset();
    late VoidCallback listener;
    listener = () {
      if (mounted) {
        setState(() {
          _pullDistance = startValue * (1 - Curves.easeOut.transform(_resetController.value));
        });
      }
      if (_resetController.isCompleted) {
        _resetController.removeListener(listener);
        if (mounted) setState(() => _pullDistance = 0);
      }
    };
    _resetController.addListener(listener);
    _resetController.forward();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      _isAtTop = notification.metrics.pixels <= 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_pullDistance / _triggerThreshold).clamp(0.0, 1.0);

    return Listener(
      onPointerDown: (event) {
        _isPulling = true;
        _triggered = false;
      },
      onPointerMove: (event) {
        if (!_isPulling || _triggered) return;

        if (_isAtTop && event.delta.dy > 0) {
          // Pulling down while at top
          setState(() {
            _pullDistance = (_pullDistance + event.delta.dy * _damping)
                .clamp(0.0, _triggerThreshold * 1.5);
          });
        } else if (_pullDistance > 0 && event.delta.dy < 0) {
          // Pulling back up while indicator is showing
          setState(() {
            _pullDistance = (_pullDistance + event.delta.dy * _damping)
                .clamp(0.0, double.infinity);
          });
        }
      },
      onPointerUp: (event) {
        _isPulling = false;
        if (_pullDistance >= _triggerThreshold && !_triggered) {
          _triggered = true;
          context.go('/');
        } else if (_pullDistance > 0) {
          _animateReset();
        }
      },
      onPointerCancel: (event) {
        _isPulling = false;
        if (_pullDistance > 0 && !_triggered) {
          _animateReset();
        }
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Stack(
          children: [
            // Content with slight downward shift when pulling
            AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              transform: Matrix4.translationValues(0, _pullDistance * 0.25, 0),
              child: widget.child,
            ),
            // Pull indicator
            if (_pullDistance > 5)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _PullIndicator(
                  pullDistance: _pullDistance,
                  progress: progress,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PullIndicator extends StatelessWidget {
  final double pullDistance;
  final double progress;

  const _PullIndicator({
    required this.pullDistance,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (pullDistance * 0.5).clamp(0.0, 72.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.12 * progress),
            AppColors.primary.withOpacity(0.04 * progress),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Center(
        child: AnimatedOpacity(
          opacity: pullDistance > 15 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rotating icon
              Transform.rotate(
                angle: progress * math.pi * 2,
                child: Container(
                  width: 28 + 6 * progress,
                  height: 28 + 6 * progress,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryLight.withOpacity(0.3 + 0.5 * progress),
                      width: 1.5,
                    ),
                    color: progress >= 1.0
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    progress >= 1.0
                        ? Icons.refresh_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                    color: AppColors.primaryLight.withOpacity(0.4 + 0.6 * progress),
                  ),
                ),
              ),
              if (pullDistance > 40) ...[
                const SizedBox(height: 6),
                Text(
                  progress >= 1.0 ? 'RELEASE TO REBOOT' : 'PULL TO REBOOT',
                  style: AppTextStyles.mono(
                    size: 9,
                    color: AppColors.primaryLight.withOpacity(0.3 + 0.5 * progress),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
