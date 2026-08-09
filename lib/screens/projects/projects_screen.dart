import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive_utils.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/footer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/pull_to_reload.dart';
import '../../widgets/project_card.dart';
import '../../models/project_data.dart';
import '../../animations/section_reveal.dart';

/// Projects page — displays all portfolio projects in a responsive grid.
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final body = PullToReload(
      child: Column(
        children: [
          const NavBar(currentIndex: 4),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 40 : 60),
                  _buildHeader(context, isMobile),
                  SizedBox(height: isMobile ? 30 : 48),
                  _buildProjectGrid(context, isMobile),
                  SizedBox(height: isMobile ? 40 : 80),
                  _buildCTA(context, isMobile),
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
          ? AppBottomNavBar.wrapWithFloatingNav(body: body, currentIndex: 4)
          : body,
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return ContentWrapper(
      child: SectionReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.portfolioStackTitle,
              style: isMobile
                  ? AppTextStyles.sectionTitleMobile
                  : AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.portfolioStackSubtitle,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary.withOpacity(0.25)),
              ),
              child: Text(
                '${projectList.length} PROJECTS',
                style: AppTextStyles.mono(
                  size: 11,
                  color: AppColors.primaryLight,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectGrid(BuildContext context, bool isMobile) {
    return ContentWrapper(
      child: isMobile
          ? Column(
              children: projectList
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ProjectCard(project: p),
                      ))
                  .toList(),
            )
          : _buildDesktopGrid(),
    );
  }

  Widget _buildDesktopGrid() {
    final rows = <Widget>[];
    for (var i = 0; i < projectList.length; i += 3) {
      final rowItems = projectList.skip(i).take(3).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...rowItems.asMap().entries.map(
                    (e) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: e.key < rowItems.length - 1 ? 20 : 0,
                        ),
                        child: ProjectCard(project: e.value),
                      ),
                    ),
                  ),
              // Fill remaining columns with empty space
              ...List.generate(
                3 - rowItems.length,
                (_) => const Expanded(child: SizedBox()),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildCTA(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.contentPadding(context),
        vertical: 40,
      ),
      child: Column(
        children: [
          Text(
            'Have a project in mind?',
            style: AppTextStyles.sectionTitle.copyWith(
              fontSize: isMobile ? 22 : 32,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "Let's build something extraordinary together.\n"
            "I'm always open to new collaborations and ideas.",
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          InkWell(
            onTap: () => context.go('/contact'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: Text(
                'START  A  CONVERSATION',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primaryLight,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
