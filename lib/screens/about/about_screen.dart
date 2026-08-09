import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive_utils.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/footer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/pull_to_reload.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/tech_chip.dart';
import '../../animations/section_reveal.dart';
import '../../providers/github_provider.dart';

/// About page — profile card, philosophy, skills, goals, stats.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);
    final body = PullToReload(
      child: Column(
        children: [
          const NavBar(currentIndex: 1),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 30 : 60),
                  _buildMainCard(context, isMobile),
                  SizedBox(height: isMobile ? 30 : 50),
                  _buildStatsRow(context, isMobile, ref),
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
          ? AppBottomNavBar.wrapWithFloatingNav(body: body, currentIndex: 1)
          : body,
    );
  }

  Widget _buildMainCard(BuildContext context, bool isMobile) {
    return ContentWrapper(
      child: SectionReveal(
        child: GlassCard(
          padding: EdgeInsets.all(isMobile ? 24 : 48),
          child: isMobile ? _buildMainCardMobile() : _buildMainCardDesktop(),
        ),
      ),
    );
  }

  Widget _buildMainCardDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Profile
        SizedBox(
          width: 260,
          child: _buildProfile(),
        ),
        const SizedBox(width: 48),
        // Right: Philosophy, Skills, Goals
        Expanded(child: _buildDetails()),
      ],
    );
  }

  Widget _buildMainCardMobile() {
    return Column(
      children: [
        _buildProfile(),
        const SizedBox(height: 32),
        _buildDetails(),
      ],
    );
  }

  Widget _buildProfile() {
    return Column(
      children: [
        // Profile image placeholder
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            image: const DecorationImage(
              image: AssetImage('assets/images/profile.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Online indicator
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          AppStrings.aboutName,
          style: AppTextStyles.cardTitle.copyWith(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Role
        Text(
          AppStrings.aboutRole,
          style: AppTextStyles.mono(
            size: 13,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rocket_launch, size: 16, color: AppColors.primaryLight),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  AppStrings.aboutStatus,
                  style: AppTextStyles.mono(size: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Developer Philosophy
        _sectionLabel(AppStrings.aboutPhilosophyLabel),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: AppTextStyles.body,
            children: [
              TextSpan(
                text: AppStrings.aboutPhilosophy,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Skills Summary
        _sectionLabel(AppStrings.aboutSkillsLabel),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppStrings.aboutSkills.map((s) => TechChip(label: s)).toList(),
        ),
        const SizedBox(height: 32),
        // Career Goals
        _sectionLabel(AppStrings.aboutGoalsLabel),
        const SizedBox(height: 16),
        ...AppStrings.aboutGoals.map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(goal, style: AppTextStyles.body)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(width: 32, height: 1, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppTextStyles.mono(
            size: 12,
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isMobile, WidgetRef ref) {
    final contributionsAsync = ref.watch(contributionsProvider);

    // Format actual contribution count from GitHub
    final contributionValue = contributionsAsync.when(
      data: (data) {
        final total = data.totalContributions;
        if (total >= 1000) {
          return '${(total / 1000).toStringAsFixed(1)}k+';
        }
        return '$total+';
      },
      loading: () => '...',
      error: (_, __) => '—',
    );

    return ContentWrapper(
      child: SectionReveal(
        child: isMobile
            ? Column(
                children: [
                  Row(children: [
                    StatCard(icon: Icons.hub, label: 'GITHUB', value: contributionValue, description: 'Contributions'),
                    const SizedBox(width: 12),
                    const StatCard(icon: Icons.terminal, label: 'PROJECTS', value: '10+', description: 'Projects Build'),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: const [
                    StatCard(icon: Icons.emoji_events, label: 'HACKATHONS', value: '5+', description: 'Hackathons Participated'),
                    ]),
                ],
              )
            : Row(
                children: [
                  StatCard(icon: Icons.hub, label: 'GITHUB', value: contributionValue, description: 'Contributions'),
                  const SizedBox(width: 16),
                  const StatCard(icon: Icons.terminal, label: 'PROJECTS', value: '10+', description: 'Projects Build'),
                  const SizedBox(width: 16),
                  const StatCard(icon: Icons.emoji_events, label: 'HACKATHONS', value: '5+', description: 'Hackathons Participated'),
                ],
              ),
      ),
    );
  }
}
