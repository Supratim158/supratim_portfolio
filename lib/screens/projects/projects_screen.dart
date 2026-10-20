import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/footer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/pull_to_reload.dart';
import '../../widgets/page_navigation.dart';
import '../../widgets/stacked_projects_showcase.dart';
import '../../widgets/desk_scenery_panel.dart';
import '../../models/project_data.dart';

/// Projects page — displays portfolio projects with scroll-driven stacking cards,
/// realistic left/right desk scenery panels (lamp + glow + laptop, and studio corner).
/// The side scenery panels are 100% FIXED on screen (placed in an overlay Stack
/// outside the scrollable) so they never jitter or move during scrolling.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _panelEntrance;

  @override
  void initState() {
    super.initState();
    _panelEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _panelEntrance.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _panelEntrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final showSideScenery = screenWidth >= 1150;

    final scrollContent = PullToReload(
      child: Column(
        children: [
          const NavBar(currentIndex: 4),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 12 : 20),
                  StackedProjectsShowcase(
                    projects: projectList,
                    scrollController: _scrollController,
                  ),
                  SizedBox(height: isMobile ? 20 : 40),
                  const AppFooter(currentPageIndex: 4),
                  if (isMobile) const SizedBox(height: AppBottomNavBar.totalHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // If no side scenery needed, just return the scroll content
    if (!showSideScenery) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: isMobile
            ? AppBottomNavBar.wrapWithFloatingNav(body: scrollContent, currentIndex: 4)
            : scrollContent,
      );
    }

    // Desktop: Side panels overlaid on top of the scrollable content
    // so they are 100% FIXED and never move during scrolling
    final body = Stack(
      children: [
        // The scrollable content
        scrollContent,

        // LEFT DESK SCENERY — FIXED, overlaid
        AnimatedBuilder(
          animation: _panelEntrance,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_panelEntrance.value);
            return Positioned(
              left: screenWidth > 1550 ? 28 : 10,
              top: 75, // Below the navbar
              width: 280,
              height: 520,
              child: IgnorePointer(
                child: Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(-300 * (1 - t), 0),
                    child: const DeskSceneryPanel(isLeft: true),
                  ),
                ),
              ),
            );
          },
        ),

        // RIGHT DESK SCENERY — FIXED, overlaid
        AnimatedBuilder(
          animation: _panelEntrance,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_panelEntrance.value);
            return Positioned(
              right: screenWidth > 1550 ? 28 : 10,
              top: 75,
              width: 280,
              height: 520,
              child: IgnorePointer(
                child: Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(300 * (1 - t), 0),
                    child: const DeskSceneryPanel(isLeft: false),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: body,
    );
  }
}
