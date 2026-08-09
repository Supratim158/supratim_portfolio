import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Floating bottom navigation bar for mobile viewports.
/// Use [AppBottomNavBar.wrapWithFloatingNav] to overlay this on top of content.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  static const _routes = ['/home', '/about', '/stack', '/metrics', '/work', '/contact'];
  static const _labels = ['Intro', 'About', 'Stack', 'Metrics', 'Work', 'Contact'];
  static const _icons = [
    Icons.home_outlined,
    Icons.person_outline,
    Icons.layers_outlined,
    Icons.bar_chart_outlined,
    Icons.work_outline,
    Icons.email_outlined,
  ];
  static const _activeIcons = [
    Icons.home_rounded,
    Icons.person_rounded,
    Icons.layers_rounded,
    Icons.bar_chart_rounded,
    Icons.work_rounded,
    Icons.email_rounded,
  ];

  /// Height consumed by the floating nav bar + its bottom padding.
  /// Screens can use this to add bottom padding to their scroll content.
  static const double totalHeight = 80;

  /// Wraps [body] in a Stack with this floating nav bar overlaid at the bottom.
  /// The [body] extends behind the nav bar for a seamless effect.
  static Widget wrapWithFloatingNav({
    required Widget body,
    required int currentIndex,
  }) {
    return Stack(
      children: [
        body,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AppBottomNavBar(currentIndex: currentIndex),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.navBg.withOpacity(0.85),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.borderLight.withOpacity(0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_labels.length, (i) {
                final isActive = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(_routes[i]),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isActive ? _activeIcons[i] : _icons[i],
                            size: 20,
                            color: isActive
                                ? AppColors.primaryLight
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _labels[i],
                          style: AppTextStyles.mono(
                            size: 8,
                            color: isActive
                                ? AppColors.primaryLight
                                : AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
