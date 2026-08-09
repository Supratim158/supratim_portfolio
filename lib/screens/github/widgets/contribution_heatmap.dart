import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// GitHub-style contribution heatmap calendar with animated cells.
class ContributionHeatmap extends StatefulWidget {
  final Map<String, dynamic>? graphData;

  const ContributionHeatmap({super.key, this.graphData});

  @override
  State<ContributionHeatmap> createState() => _ContributionHeatmapState();
}

class _ContributionHeatmapState extends State<ContributionHeatmap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = math.Random(42);

  bool get isLoading => widget.graphData == null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Activity Heatmap', style: AppTextStyles.cardTitle),
            const Spacer(),
            _legendDot(AppColors.contribNone, 'Less'),
            _legendDot(AppColors.contribLow, ''),
            _legendDot(AppColors.contribMed, ''),
            _legendDot(AppColors.contribHigh, ''),
            _legendDot(AppColors.contribMax, 'More'),
          ],
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return _buildGrid();
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonGrid() {
    return SizedBox(
      height: 120,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = math.min(12.0, (constraints.maxWidth - 51 * 3) / 52);
          final gap = 3.0;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(52, (week) {
                return Padding(
                  padding: EdgeInsets.only(right: gap),
                  child: Column(
                    children: List.generate(7, (day) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: gap),
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: AppColors.cardBg,
        highlightColor: AppColors.cardBgLight,
        child: _buildSkeletonGrid(),
      );
    }

    // Generate 52 weeks x 7 days grid
    return SizedBox(
      height: 120,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = math.min(12.0, (constraints.maxWidth - 51 * 3) / 52);
          final gap = 3.0;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(52, (week) {
                return Padding(
                  padding: EdgeInsets.only(right: gap),
                  child: Column(
                    children: List.generate(7, (day) {
                      final index = week * 7 + day;
                      final level = _getLevel(index);
                      final animProgress = _controller.value;
                      final cellDelay = (week * 7 + day) / (52 * 7);
                      final opacity = (animProgress - cellDelay * 0.5).clamp(0.0, 1.0);

                      return Padding(
                        padding: EdgeInsets.only(bottom: gap),
                        child: Tooltip(
                          message: '${_getCount(index)} contributions',
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: _getColor(level),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  /// Resolve the weeks list from various possible API structures.
  List? _getWeeks() {
    if (widget.graphData == null) return null;
    final data = widget.graphData!;

    // Structure 1: {graph: [{contributionDays: [...]}]}
    if (data.containsKey('graph')) {
      return data['graph'] as List?;
    }

    // Structure 2: {user: {contributionsCollection: {contributionCalendar: {weeks: [...]}}}}
    if (data.containsKey('user')) {
      final user = data['user'] as Map<String, dynamic>?;
      final collection = user?['contributionsCollection'] as Map<String, dynamic>?;
      final calendar = collection?['contributionCalendar'] as Map<String, dynamic>?;
      return calendar?['weeks'] as List?;
    }

    // Structure 3: {weeks: [...]}
    if (data.containsKey('weeks')) {
      return data['weeks'] as List?;
    }

    return null;
  }

  int _getLevel(int index) {
    final weeks = _getWeeks();
    if (weeks != null) {
      final weekIdx = index ~/ 7;
      final dayIdx = index % 7;
      if (weekIdx < weeks.length) {
        final days = weeks[weekIdx]['contributionDays'] as List?;
        if (days != null && dayIdx < days.length) {
          final count = days[dayIdx]['count'] ??
              days[dayIdx]['contributionCount'] ?? 0;
          return _countToLevel(count);
        }
      }
    }
    // Placeholder data when no real data
    return _random.nextInt(5);
  }

  /// Convert contribution count to a 0-4 level for heatmap coloring.
  int _countToLevel(int count) {
    if (count == 0) return 0;
    if (count <= 1) return 1;
    if (count <= 3) return 2;
    if (count <= 5) return 3;
    return 4;
  }

  int _getCount(int index) {
    final weeks = _getWeeks();
    if (weeks != null) {
      final weekIdx = index ~/ 7;
      final dayIdx = index % 7;
      if (weekIdx < weeks.length) {
        final days = weeks[weekIdx]['contributionDays'] as List?;
        if (days != null && dayIdx < days.length) {
          return days[dayIdx]['count'] ??
              days[dayIdx]['contributionCount'] ?? 0;
        }
      }
    }
    return 0;
  }

  Color _getColor(int level) {
    switch (level) {
      case 0: return AppColors.contribNone;
      case 1: return AppColors.contribLow;
      case 2: return AppColors.contribMed;
      case 3: return AppColors.contribHigh;
      case 4: return AppColors.contribMax;
      default: return AppColors.contribNone;
    }
  }

  Widget _legendDot(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.mono(size: 9, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}
