import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/commit.dart';
import '../../../providers/github_provider.dart';
import '../../../widgets/shimmer_loader.dart';

/// Recent activity timeline — fetches real commit data from the backend.
class ActivityTimeline extends ConsumerStatefulWidget {
  const ActivityTimeline({super.key});

  @override
  ConsumerState<ActivityTimeline> createState() => _ActivityTimelineState();
}

class _ActivityTimelineState extends ConsumerState<ActivityTimeline> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commitsAsync = ref.watch(commitsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: AppTextStyles.cardTitle),
        const SizedBox(height: 20),
        commitsAsync.when(
          data: (commits) => _buildCommitList(commits),
          loading: () => _buildLoadingState(),
          error: (_, __) => _buildFallbackList(),
        ),
      ],
    );
  }

  Widget _buildActivityScrollContainer(List<Widget> items) {
    if (items.length <= 2) {
      return Column(children: items);
    }

    return SizedBox(
      height: 125, // fits roughly 3 items; others are scrollable
      child: RawScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 4.0,
        radius: const Radius.circular(8),
        thumbColor: AppColors.primaryLight.withOpacity(0.5),
        trackVisibility: true,
        trackColor: AppColors.textMuted.withOpacity(0.05),
        trackRadius: const Radius.circular(8),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: items,
            ),
          ),
        ),
      ),
    );
  }

  /// Renders real commit data from the API.
  Widget _buildCommitList(List<CommitData> commits) {
    if (commits.isEmpty) return _buildFallbackList();

    final recent = commits.take(10).toList();
    final items = recent.map((commit) {
      return _activityItem(
        Icons.commit,
        _formatCommitMessage(commit),
        _formatTimeAgo(commit.date),
        _getCommitColor(recent.indexOf(commit)),
      );
    }).toList();

    return _buildActivityScrollContainer(items);
  }

  /// Shimmer skeleton while loading.
  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const ShimmerLoader(width: 28, height: 28, borderRadius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerLoader(height: 12),
                    SizedBox(height: 6),
                    ShimmerLoader(width: 80, height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Fallback placeholder when API is unreachable.
  Widget _buildFallbackList() {
    final items = [
      _activityItem(
        Icons.commit,
        'Pushed 4 commits to core-engine-v2',
        '2 HOURS AGO',
        AppColors.success,
      ),
      _activityItem(
        Icons.merge,
        'Merged PR #124 "Auth Refactor"',
        '5 HOURS AGO',
        AppColors.primaryLight,
      ),
      _activityItem(
        Icons.bug_report_outlined,
        'Opened issue: "Optimistic UI Lag"',
        'YESTERDAY',
        AppColors.warning,
      ),
      _activityItem(
        Icons.new_releases_outlined,
        'Released version v1.4.8-alpha',
        'OCT 24, 2024',
        AppColors.accent,
      ),
    ];

    return _buildActivityScrollContainer(items);
  }

  Widget _activityItem(IconData icon, String text, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextStyles.mono(
                    size: 10,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format commit message: "Commit to <repo>: <message>"
  String _formatCommitMessage(CommitData commit) {
    final msg = commit.message.split('\n').first; // first line only
    if (commit.repoName.isNotEmpty) {
      return 'Pushed to ${commit.repoName}: $msg';
    }
    return msg;
  }

  /// Produce a human-readable time-ago string.
  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} MIN AGO';
    if (diff.inHours < 24) return '${diff.inHours} HOURS AGO';
    if (diff.inDays < 7) return '${diff.inDays} DAYS AGO';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} WEEKS AGO';
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
                     'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Cycle through accent colors for visual variety.
  Color _getCommitColor(int index) {
    const colors = [
      AppColors.success,
      AppColors.primaryLight,
      AppColors.warning,
      AppColors.accent,
      AppColors.primary,
    ];
    return colors[index % colors.length];
  }
}
