import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive_utils.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/footer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/pull_to_reload.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loader.dart';
import '../../animations/section_reveal.dart';
import '../../providers/github_provider.dart';
import '../../models/repository.dart';
import 'widgets/contribution_heatmap.dart';
import 'widgets/language_chart.dart';
import 'widgets/activity_timeline.dart';
import 'widgets/repo_list_item.dart';

/// Metrics / GitHub Analytics page.
/// Dynamically fetches and displays:
/// - GitHub profile stats (followers, repos)
/// - Contribution graph / heatmap
/// - Total commits & total contributions
/// - Recent commits (activity timeline)
/// - Repository stats & language usage
class GithubScreen extends ConsumerStatefulWidget {
  const GithubScreen({super.key});

  @override
  ConsumerState<GithubScreen> createState() => _GithubScreenState();
}

class _GithubScreenState extends ConsumerState<GithubScreen> {
  final ScrollController _repoScrollController = ScrollController();

  @override
  void dispose() {
    _repoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final body = PullToReload(
      child: Column(
        children: [
          const NavBar(currentIndex: 3),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 30 : 60),
                  _buildHeader(context, isMobile),
                  SizedBox(height: isMobile ? 20 : 40),
                  _buildStatsRow(context, ref, isMobile),
                  SizedBox(height: isMobile ? 20 : 30),
                  _buildHeatmapAndActivity(context, ref, isMobile),
                  SizedBox(height: isMobile ? 20 : 30),
                  _buildLanguageAndRepos(context, ref, isMobile),
                  SizedBox(height: isMobile ? 30 : 60),
                  const AppFooter(),
                  if (isMobile) const SizedBox(height: AppBottomNavBar.totalHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile
          ? AppBottomNavBar.wrapWithFloatingNav(body: body, currentIndex: 3)
          : body,
    );
  }

  // ── Header ────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return ContentWrapper(
      child: SectionHeader(
        title: AppStrings.metricsTitle,
        subtitle: AppStrings.metricsDescription,
      ),
    );
  }

  // ── Stats Row (profile, contributions, repos) ─────────────────

  Widget _buildStatsRow(
      BuildContext context, WidgetRef ref, bool isMobile) {
    final contribs = ref.watch(contributionsProvider);
    final profile = ref.watch(githubProfileProvider);
    final repos = ref.watch(repositoriesProvider);
    final allCommitsAsync = ref.watch(allCommitsProvider);

    // Extract real values or show defaults while loading
    final totalContribs = contribs.when(
      data: (d) => _formatNumber(d.totalContributions),
      loading: () => '—',
      error: (_, __) => '12,482',
    );
    final repoCount = repos.when(
      data: (d) => '${d.length}',
      loading: () => '—',
      error: (_, __) => '144',
    );
    final commitCount = allCommitsAsync.when(
      data: (total) => total >= 1000
          ? '${(total / 1000).toStringAsFixed(1)}k'
          : '$total',
      loading: () => '—',
      error: (_, __) => AppStrings.statCommits,
    );
    final followers = profile.when(
      data: (d) => _formatNumber(d.followers),
      loading: () => '—',
      error: (_, __) => '3.8k',
    );

    return ContentWrapper(
      child: SectionReveal(
        child: isMobile
            ? Column(
                children: [
                  Row(children: [
                    _metricCard('TOTAL CONTRIBUTIONS', totalContribs,
                        null, Icons.code),
                    const SizedBox(width: 12),
                    _metricCard('REPOSITORIES', repoCount,
                        null, Icons.folder_copy_outlined),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    _metricCard('TOTAL COMMITS', commitCount,
                        null, Icons.history),
                    const SizedBox(width: 12),
                    _metricCard('FOLLOWERS', followers,
                        null, Icons.people_outline),
                  ]),
                ],
              )
            : Row(
                children: [
                  _metricCard('TOTAL CONTRIBUTIONS', totalContribs,
                      null, Icons.code),
                  const SizedBox(width: 16),
                  _metricCard('REPOSITORIES', repoCount,
                      null, Icons.folder_copy_outlined),
                  const SizedBox(width: 16),
                  _metricCard('TOTAL COMMITS', commitCount,
                      null, Icons.history),
                  const SizedBox(width: 16),
                  _metricCard('FOLLOWERS', followers,
                      null, Icons.people_outline),
                ],
              ),
      ),
    );
  }

  Widget _metricCard(
      String label, String value, String? suffix, IconData icon) {
    final isLoading = value == '—';
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.mono(
                      size: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 16, color: AppColors.primaryLight),
              ],
            ),
            const SizedBox(height: 12),
            isLoading
                ? const ShimmerLoader(width: 80, height: 28)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: AppTextStyles.statNumber
                              .copyWith(fontSize: 28),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (suffix != null) ...[
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            suffix,
                            style: AppTextStyles.mono(
                              size: 11,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // ── Heatmap + Activity Timeline ───────────────────────────────

  Widget _buildHeatmapAndActivity(
      BuildContext context, WidgetRef ref, bool isMobile) {
    final graphData = ref.watch(contributionGraphProvider);

    return ContentWrapper(
      child: SectionReveal(
        child: isMobile
            ? Column(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: ContributionHeatmap(
                      graphData:
                          graphData.whenOrNull(data: (d) => d),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const GlassCard(
                    padding: EdgeInsets.all(24),
                    child: ActivityTimeline(),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: ContributionHeatmap(
                        graphData:
                            graphData.whenOrNull(data: (d) => d),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 2,
                    child: GlassCard(
                      padding: EdgeInsets.all(24),
                      child: ActivityTimeline(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Language Chart + Repos List ────────────────────────────────

  Widget _buildLanguageAndRepos(
      BuildContext context, WidgetRef ref, bool isMobile) {
    return ContentWrapper(
      child: SectionReveal(
        child: isMobile
            ? Column(
                children: [
                  const GlassCard(
                    padding: EdgeInsets.all(24),
                    child: LanguageChart(),
                  ),
                  const SizedBox(height: 16),
                  _buildReposList(ref),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: GlassCard(
                      padding: EdgeInsets.all(24),
                      child: LanguageChart(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildReposList(ref),
                  ),
                ],
              ),
      ),
    );
  }

  /// Builds the "Most Active Repositories" card from real API data.
  Widget _buildReposScrollContainer(List<Widget> items) {
    if (items.length <= 2.8) {
      return Column(children: items);
    }

    return SizedBox(
      height: 140, // fits roughly 3 items; others are scrollable
      child: RawScrollbar(
        controller: _repoScrollController,
        thumbVisibility: true,
        thickness: 4.0,
        radius: const Radius.circular(8),
        thumbColor: AppColors.primaryLight.withOpacity(0.5),
        trackVisibility: true,
        trackColor: AppColors.textMuted.withOpacity(0.05),
        trackRadius: const Radius.circular(8),
        child: SingleChildScrollView(
          controller: _repoScrollController,
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

  Widget _buildReposList(WidgetRef ref) {
    final reposAsync = ref.watch(repositoriesProvider);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Most Active Repositories', style: AppTextStyles.cardTitle),
          const SizedBox(height: 16),
          reposAsync.when(
            data: (repos) {
              if (repos.isEmpty) return _fallbackReposList();
              // Sort by stars descending, show top 5
              final sorted = List<Repository>.from(repos)
                ..sort((a, b) => b.stars.compareTo(a.stars));
              final itemsList = sorted.map((repo) {
                return RepoListItem(
                  name: repo.name,
                  description: repo.description,
                  stars: repo.stars,
                  forks: repo.forks,
                );
              }).toList();
              return _buildReposScrollContainer(itemsList);
            },
            loading: () => Column(
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ShimmerLoader(height: 48),
                ),
              ),
            ),
            error: (_, __) => _fallbackReposList(),
          ),
        ],
      ),
    );
  }

  /// Placeholder repos when the API is down.
  Widget _fallbackReposList() {
    final items = const [
      RepoListItem(
        name: 'neuro-kernel-core',
        description: 'Next-gen distributed runtime',
        version: 'v 1.2s',
        stars: 25,
      ),
      RepoListItem(
        name: 'quantum-ui-kit',
        description: 'Atomic design system for R&D',
        version: 'v 0/2',
        stars: 67,
      ),
      RepoListItem(
        name: 'oxide-engine',
        description: 'High-performance Rust graphics library',
        version: 'v 3.1s',
        stars: 61,
      ),
    ];
    return _buildReposScrollContainer(items);
  }



  // ── Helpers ────────────────────────────────────────────────────

  /// Format large numbers (e.g. 12482 → 12,482 or 3800 → 3.8k).
  String _formatNumber(int n) {
    if (n >= 10000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    if (n >= 1000) {
      // Add comma separator
      final s = n.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return '$n';
  }
}

// ═══════════════════════════════════════════════════════════════
//  Bar Chart — animated repository activity visualization
// ═══════════════════════════════════════════════════════════════

class _BarChart extends StatefulWidget {
  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = math.Random(7);
  late final List<double> _values;

  @override
  void initState() {
    super.initState();
    _values = List.generate(30, (_) => 0.2 + _random.nextDouble() * 0.8);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final barWidth =
                (constraints.maxWidth - (_values.length - 1) * 3) /
                    _values.length;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_values.length, (i) {
                final height = _values[i] * 100 * _controller.value;
                return Padding(
                  padding: EdgeInsets.only(
                      right: i < _values.length - 1 ? 3 : 0),
                  child: Container(
                    width: barWidth,
                    height: height,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight
                          .withOpacity(0.4 + _values[i] * 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }
}
