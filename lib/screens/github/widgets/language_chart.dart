import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/repository.dart';
import '../../../providers/github_provider.dart';
import '../../../widgets/shimmer_loader.dart';

/// Donut chart showing language usage — derived from real repository data.
class LanguageChart extends ConsumerStatefulWidget {
  const LanguageChart({super.key});

  @override
  ConsumerState<LanguageChart> createState() => _LanguageChartState();
}

class _LanguageChartState extends ConsumerState<LanguageChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _defaultData = {
    'TypeScript': 42.4,
    'Rust': 20.3,
    'Go': 14.8,
    'Python': 12.5,
    'Dart': 10.0,
  };

  static const _colors = [
    Color(0xFF3178C6), // TypeScript
    Color(0xFFDEA584), // Rust
    Color(0xFF00ADD8), // Go
    Color(0xFF3776AB), // Python
    Color(0xFF0175C2), // Dart
    Color(0xFFF1E05A), // JavaScript
    Color(0xFFE34C26), // HTML
    Color(0xFF563D7C), // CSS
    AppColors.primaryLight,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Derive language percentages from real repo data.
  Map<String, double> _deriveLanguageData(List<Repository> repos) {
    final counts = <String, int>{};
    for (final repo in repos) {
      if (repo.language.isNotEmpty && repo.language != 'Unknown') {
        counts[repo.language] = (counts[repo.language] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return _defaultData;

    final total = counts.values.fold<int>(0, (a, b) => a + b);
    // Sort by count descending, take top 5
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5);

    final result = <String, double>{};
    for (final entry in top) {
      result[entry.key] = double.parse(
        ((entry.value / total) * 100).toStringAsFixed(1),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final reposAsync = ref.watch(repositoriesProvider);

    return reposAsync.when(
      data: (repos) => _buildChart(_deriveLanguageData(repos)),
      loading: () => _buildLoading(),
      error: (_, __) => _buildChart(_defaultData),
    );
  }

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Language Usage', style: AppTextStyles.cardTitle),
        const SizedBox(height: 24),
        const Center(child: ShimmerLoader(width: 140, height: 140, borderRadius: 70)),
      ],
    );
  }

  Widget _buildChart(Map<String, double> data) {
    // Find the top language for center label
    final topEntry = data.entries.first;
    final topShort = topEntry.key.length > 4
        ? topEntry.key.substring(0, 2).toUpperCase()
        : topEntry.key.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Language Usage', style: AppTextStyles.cardTitle),
        const SizedBox(height: 24),
        Row(
          children: [
            // Donut chart
            SizedBox(
              width: 140,
              height: 140,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _DonutPainter(
                      data: data,
                      colors: _colors,
                      progress: _controller.value,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            topShort,
                            style: AppTextStyles.mono(
                              size: 20,
                              weight: FontWeight.w700,
                              color: _colors[0],
                            ),
                          ),
                          Text(
                            '${topEntry.value.toInt()}%',
                            style: AppTextStyles.mono(
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 24),
            // Legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(data.length, (i) {
                  final entry = data.entries.elementAt(i);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _colors[i % _colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: AppTextStyles.mono(
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${entry.value}%',
                          style: AppTextStyles.mono(
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;
  final double progress;

  _DonutPainter({
    required this.data,
    required this.colors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 16.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    double startAngle = -math.pi / 2;
    final total = data.values.fold<double>(0, (a, b) => a + b);

    int i = 0;
    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * math.pi * progress;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
