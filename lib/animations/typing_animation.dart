import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Terminal-style typing animation widget.
///
/// Types out [text] character by character with a blinking cursor.
class TypingAnimation extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration typingSpeed;
  final Duration startDelay;
  final bool showCursor;
  final VoidCallback? onComplete;

  const TypingAnimation({
    super.key,
    required this.text,
    this.style,
    this.typingSpeed = const Duration(milliseconds: 50),
    this.startDelay = Duration.zero,
    this.showCursor = true,
    this.onComplete,
  });

  @override
  State<TypingAnimation> createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<TypingAnimation> {
  String _displayText = '';
  Timer? _timer;
  int _charIndex = 0;
  bool _cursorVisible = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    // Blinking cursor
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted) setState(() => _cursorVisible = !_cursorVisible);
    });
    // Start typing after delay
    Future.delayed(widget.startDelay, _startTyping);
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.typingSpeed, (timer) {
      if (_charIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayText = widget.text.substring(0, _charIndex + 1);
            _charIndex++;
          });
        }
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cursor = widget.showCursor && _cursorVisible ? '▊' : '';
    return Text(
      '$_displayText$cursor',
      style: widget.style,
    );
  }
}

/// Cycles through a list of strings with typing + erasing animation.
class RoleTypingAnimation extends StatefulWidget {
  final List<String> roles;
  final TextStyle? style;
  final Duration typingSpeed;
  final Duration erasingSpeed;
  final Duration pauseDuration;

  const RoleTypingAnimation({
    super.key,
    required this.roles,
    this.style,
    this.typingSpeed = const Duration(milliseconds: 80),
    this.erasingSpeed = const Duration(milliseconds: 40),
    this.pauseDuration = const Duration(seconds: 2),
  });

  @override
  State<RoleTypingAnimation> createState() => _RoleTypingAnimationState();
}

class _RoleTypingAnimationState extends State<RoleTypingAnimation> {
  String _displayText = '';
  int _roleIndex = 0;
  bool _isTyping = true;
  Timer? _timer;
  bool _cursorVisible = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted) setState(() => _cursorVisible = !_cursorVisible);
    });
    _type();
  }

  void _type() {
    final target = widget.roles[_roleIndex];
    int i = 0;
    _timer = Timer.periodic(widget.typingSpeed, (timer) {
      if (i < target.length) {
        if (mounted) {
          setState(() => _displayText = target.substring(0, i + 1));
        }
        i++;
      } else {
        timer.cancel();
        Future.delayed(widget.pauseDuration, () {
          if (mounted) _erase();
        });
      }
    });
  }

  void _erase() {
    _timer = Timer.periodic(widget.erasingSpeed, (timer) {
      if (_displayText.isNotEmpty) {
        if (mounted) {
          setState(() {
            _displayText =
                _displayText.substring(0, _displayText.length - 1);
          });
        }
      } else {
        timer.cancel();
        _roleIndex = (_roleIndex + 1) % widget.roles.length;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _type();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cursor = _cursorVisible ? '_' : ' ';
    return Text(
      '$_displayText$cursor',
      style: widget.style ??
          TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 20,
            color: AppColors.primaryLight,
          ),
    );
  }
}
