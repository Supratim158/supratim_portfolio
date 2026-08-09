import 'dart:async';
import 'package:flutter/material.dart';

enum ScreenType { ide, terminal, database, analytics }

class MiniTerminalTyping extends StatefulWidget {
  final ScreenType type;
  final Duration typingSpeed;
  final Duration pauseBetweenBlocks;
  final bool isBackground;

  const MiniTerminalTyping({
    super.key,
    required this.type,
    this.typingSpeed = const Duration(milliseconds: 30),
    this.pauseBetweenBlocks = const Duration(seconds: 3),
    this.isBackground = false,
  });

  @override
  State<MiniTerminalTyping> createState() => _MiniTerminalTypingState();
}

class _MiniTerminalTypingState extends State<MiniTerminalTyping> {
  final List<String> _visibleLines = [];
  String _currentLineBuffer = "";
  int _blockIndex = 0;
  int _lineIndex = 0;
  int _charIndex = 0;
  Timer? _typingTimer;
  bool _isCursorVisible = true;
  Timer? _cursorTimer;
  final ScrollController _scrollController = ScrollController();

  // Max lines to keep in memory to prevent performance issues
  static const int _maxLines = 30;

  late final List<List<String>> _codeBlocks;

  @override
  void initState() {
    super.initState();
    _initCodeBlocks();
    _startCursorBlink();
    _startTyping();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _isCursorVisible = !_isCursorVisible;
        });
      }
    });
  }

  void _scrollToBottom() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _initCodeBlocks() {
    switch (widget.type) {
      case ScreenType.ide:
        _codeBlocks = [
          [
            "import 'package:flutter/material.dart';",
            "import 'package:flutter_riverpod/flutter_riverpod.dart';",
            "",
            "class PortfolioApp extends ConsumerWidget {",
            "  const PortfolioApp({super.key});",
            "",
            "  @override",
            "  Widget build(BuildContext context, WidgetRef ref) {",
            "    final theme = ref.watch(themeProvider);",
            "    return MaterialApp(",
            "      title: 'Supratim Portfolio',",
            "      theme: theme.isDark ? ThemeData.dark() : ThemeData.light(),",
            "      home: const HeroSection(),",
            "    );",
            "  }",
            "}"
          ],
          [
            "// Custom 3D perspective rotation matrix",
            "Matrix4 _build3DTransform(double dx, double dy) {",
            "  return Matrix4.identity()",
            "    ..setEntry(3, 2, 0.001) // perspective",
            "    ..rotateX(-dy * 0.15)",
            "    ..rotateY(dx * 0.15);",
            "}",
            "",
            "Widget buildParallaxLayer(Widget child, double factor) {",
            "  return Transform.translate(",
            "    offset: Offset(dx * factor, dy * factor),",
            "    child: child,",
            "  );",
            "}"
          ]
        ];
        break;

      case ScreenType.terminal:
        _codeBlocks = [
          [
            "supratimz@macbook ~ % git status",
            "On branch main",
            "Your branch is up to date with 'origin/main'.",
            "Changes not staged for commit:",
            "  modified:   lib/screens/home/hero_section.dart",
            "",
            "supratimz@macbook ~ % git add .",
            "supratimz@macbook ~ % git commit -m 'feat: interactive 3D hero scene'",
            "[main a4e73b2] feat: interactive 3D hero scene",
            " 3 files changed, 245 insertions(+), 8 deletions(-)",
            "",
            "supratimz@macbook ~ % git push origin main",
            "Enumerating objects: 12, done.",
            "Counting objects: 100% (12/12), done.",
            "Delta compression using up to 8 threads",
            "Compressing objects: 100% (8/8), done.",
            "Writing objects: 100% (8/8), 754 bytes, done.",
            "To github.com/supratimz/portfolio.git",
            "   5a23f11..a4e73b2  main -> main",
            "supratimz@macbook ~ % _"
          ],
          [
            "supratimz@macbook ~ % npm run build",
            "",
            "> portfolio@1.0.0 build",
            "> next build",
            "",
            "▲ Next.js 14.1.0",
            "- Checking validity of types ...",
            "- Creating an optimized production build ...",
            "✓ Compiled successfully",
            "✓ Collecting page data ...",
            "✓ Generating static pages (5/5) ...",
            "Page                                Size     First Load JS",
            "┌ ○ /                               5.1 kB         84.2 kB",
            "└ ○ /projects                       2.3 kB         81.4 kB",
            "+ First Load JS shared by all       79.1 kB",
            "",
            "supratimz@macbook ~ % docker-compose up -d --build",
            "Building portfolio-web",
            "Container portfolio-web-1  Recreated",
            "Container portfolio-web-1  Started ✓"
          ]
        ];
        break;

      case ScreenType.database:
        _codeBlocks = [
          [
            "SELECT p.id, p.title, COUNT(l.id) AS likes_count",
            "FROM portfolio_projects p",
            "LEFT JOIN project_likes l ON p.id = l.project_id",
            "WHERE p.is_featured = true",
            "GROUP BY p.id",
            "ORDER BY likes_count DESC LIMIT 5;",
            "",
            "Executing query...",
            "-------------------------------------",
            "| id   | title              | likes |",
            "-------------------------------------",
            "| 104  | Sanctuary Social   |  243  |",
            "| 108  | Antigravity Engine |  198  |",
            "| 101  | Smart Home Hub     |  142  |",
            "-------------------------------------",
            "Query completed in 0.042s"
          ],
          [
            "redis-cli -h 127.0.0.1 -p 6379",
            "127.0.0.1:6379> KEYS portfolio:cache:*",
            "1) \"portfolio:cache:github_stats\"",
            "2) \"portfolio:cache:featured_repos\"",
            "",
            "127.0.0.1:6379> GET portfolio:cache:github_stats",
            "\"{ \\\"commits\\\": 1240, \\\"stars\\\": 48, \\\"repos\\\": 34 }\"",
            "",
            "127.0.0.1:6379> TTL portfolio:cache:github_stats",
            "(integer) 3540",
            "127.0.0.1:6379> _"
          ]
        ];
        break;

      case ScreenType.analytics:
        _codeBlocks = [
          [
            "[SYS_MONITOR] ws://localhost:9000/metrics",
            "Connection established. Stream open.",
            "",
            "uptime      : 14 days, 6 hours, 23 minutes",
            "cpu_usage   : [████░░░░░░░░] 34.2%",
            "ram_usage   : [████████░░░░] 67.8% (10.8 GB / 16 GB)",
            "disk_io     : READ 1.4 MB/s | WRITE 0.8 MB/s",
            "network_in  : 142.4 kB/s",
            "network_out : 1.2 MB/s",
            "active_ws   : 412 concurrent connections",
            "",
            "[API] GET /api/v1/github/commits - 200 OK - 84ms",
            "[API] GET /api/v1/projects - 200 OK - 42ms",
            "[API] POST /api/v1/contact - 201 Created - 150ms",
            "[SYS] Garbage collection invoked: freed 45MB"
          ]
        ];
        break;
    }
  }

  void _startTyping() {
    if (!mounted) return;

    final block = _codeBlocks[_blockIndex];
    if (_lineIndex >= block.length) {
      // Completed the block. Wait, then clear and start the next block
      _typingTimer = Timer(widget.pauseBetweenBlocks, () {
        if (mounted) {
          setState(() {
            _visibleLines.clear();
            _currentLineBuffer = "";
            _lineIndex = 0;
            _charIndex = 0;
            _blockIndex = (_blockIndex + 1) % _codeBlocks.length;
          });
          _scrollToBottom();
          _startTyping();
        }
      });
      return;
    }

    final currentLineText = block[_lineIndex];

    _typingTimer = Timer(widget.typingSpeed, () {
      if (!mounted) return;

      setState(() {
        if (_charIndex < currentLineText.length) {
          _currentLineBuffer += currentLineText[_charIndex];
          _charIndex++;
          _startTyping();
        } else {
          // Finished typing the current line
          _visibleLines.add(_currentLineBuffer);
          _currentLineBuffer = "";
          _lineIndex++;
          _charIndex = 0;

          // Slide window check to prevent excessive memory accumulation
          final limit = widget.isBackground ? 45 : _maxLines;
          if (_visibleLines.length > limit) {
            _visibleLines.removeAt(0);
          }

          // Small delay before typing the next line
          _typingTimer = Timer(const Duration(milliseconds: 150), () {
            _startTyping();
          });
        }
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: widget.isBackground ? const EdgeInsets.all(24) : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isBackground ? Colors.transparent : const Color(0xFF0D0E15).withOpacity(0.85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(), // Keeps terminal locked from manual scrolling
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Render older, completed lines
            ..._visibleLines.map((line) => _buildHighlightedLine(line)),

            // Render active line being typed
            if (_currentLineBuffer.isNotEmpty || _lineIndex < _codeBlocks[_blockIndex].length)
              Row(
                children: [
                  Expanded(child: _buildHighlightedLine(_currentLineBuffer)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedLine(String line) {
    if (line.isEmpty) {
      return SizedBox(height: widget.isBackground ? 20 : 16);
    }

    // Apply color highlights based on line content and ScreenType
    final spans = _parseHighlightSpans(line);

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: widget.isBackground ? 12 : 11,
          height: widget.isBackground ? 1.5 : 1.4,
          color: Colors.white70,
        ),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<TextSpan> _parseHighlightSpans(String line) {
    // If it's the active line, append cursor at the end
    final List<TextSpan> spans = [];
    final isCommandLine = line.contains('supratimz@') || line.contains('127.0.0.1:6379>');

    // Check system tags
    if (line.startsWith('[SYS_MONITOR]') || line.startsWith('[API]') || line.startsWith('[SYS]')) {
      final tagEnd = line.indexOf(']') + 1;
      final tag = line.substring(0, tagEnd);
      final rest = line.substring(tagEnd);
      spans.add(TextSpan(
        text: tag,
        style: const TextStyle(color: Color(0xFFE2B0FF), fontWeight: FontWeight.bold),
      ));
      spans.add(TextSpan(text: rest));
      return spans;
    }

    // Split words to highlight keywords
    final List<String> words = [];
    final RegExp regex = RegExp(r'(\s+)|([^\s\w]+)|([\w]+)');
    final matches = regex.allMatches(line);

    for (var match in matches) {
      words.add(match.group(0)!);
    }

    for (var word in words) {
      Color? wordColor;
      FontWeight? weight;

      if (isCommandLine && (word == 'git' || word == 'npm' || word == 'docker-compose' || word == 'redis-cli')) {
        wordColor = const Color(0xFF5FFB7A); // Terminal command green
        weight = FontWeight.bold;
      } else if (widget.type == ScreenType.ide) {
        // Dart keywords
        const keywords = {
          'import', 'class', 'extends', 'Widget', 'BuildContext', 'return',
          'const', 'final', 'override', 'super', 'void', 'async', 'await', 'late'
        };
        if (keywords.contains(word)) {
          wordColor = const Color(0xFFFF79C6); // Pink
          weight = FontWeight.bold;
        } else if (word.startsWith("'") || word.startsWith('"') || word.endsWith("'") || word.endsWith('"')) {
          wordColor = const Color(0xFFF1FA8C); // Yellow string
        } else if (word == 'MaterialApp' || word == 'ThemeData' || word == 'HeroSection' || word == 'PortfolioApp' || word == 'ConsumerWidget') {
          wordColor = const Color(0xFF8BE9FD); // Cyan class names
        }
      } else if (widget.type == ScreenType.database) {
        // SQL keywords
        const sqlKeywords = {
          'SELECT', 'FROM', 'WHERE', 'LEFT', 'JOIN', 'ON', 'GROUP', 'BY', 'ORDER', 'LIMIT', 'COUNT', 'AS', 'KEYS', 'GET', 'TTL'
        };
        if (sqlKeywords.contains(word.toUpperCase())) {
          wordColor = const Color(0xFFBD93F9); // Purple
          weight = FontWeight.bold;
        } else if (word.startsWith("'") || word.startsWith('"')) {
          wordColor = const Color(0xFFF1FA8C);
        } else if (RegExp(r'^\d+$').hasMatch(word)) {
          wordColor = const Color(0xFFFFB86C); // Orange numbers
        }
      }

      if (word.contains('✓') || word.contains('successfully')) {
        wordColor = const Color(0xFF50FA7B); // Success green
      } else if (word.contains('Error') || word.contains('FAILED')) {
        wordColor = const Color(0xFFFF5555); // Error red
      }

      spans.add(TextSpan(
        text: word,
        style: TextStyle(color: wordColor, fontWeight: weight),
      ));
    }

    // Append cursor if it's currently the printing line and blinking is active
    if (line == _currentLineBuffer && _isCursorVisible) {
      spans.add(const TextSpan(
        text: '█',
        style: TextStyle(color: Color(0xFF00FFCC), fontSize: 10),
      ));
    }

    return spans;
  }
}
