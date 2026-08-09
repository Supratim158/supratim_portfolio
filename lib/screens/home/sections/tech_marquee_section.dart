import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

/// Horizontally scrolling tech name marquee.
class TechMarqueeSection extends StatefulWidget {
  const TechMarqueeSection({super.key});

  @override
  State<TechMarqueeSection> createState() => _TechMarqueeSectionState();
}

class _TechMarqueeSectionState extends State<TechMarqueeSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: SizedBox(
        height: 40,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRect(
              child: OverflowBox(
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: Offset(-_controller.value * 800, 0),
                  child: Row(
                    children: [
                      ...AppStrings.techMarquee.map((tech) => _techItem(tech)),
                      ...AppStrings.techMarquee.map((tech) => _techItem(tech)),
                      ...AppStrings.techMarquee.map((tech) => _techItem(tech)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _techItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(text, style: AppTextStyles.marquee),
    );
  }
}
