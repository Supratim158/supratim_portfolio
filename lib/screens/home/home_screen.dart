import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/footer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/pull_to_reload.dart';
import 'sections/hero_section.dart';
import 'sections/tech_marquee_section.dart';
import 'sections/current_status_section.dart';

/// Home page — scrollable view with hero, tech marquee, and current status sections.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final body = PullToReload(
      child: Column(
        children: [
          const NavBar(currentIndex: 0),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const HeroSection(),
                  const TechMarqueeSection(),
                  const CurrentStatusSection(),
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
          ? AppBottomNavBar.wrapWithFloatingNav(body: body, currentIndex: 0)
          : body,
    );
  }
}
