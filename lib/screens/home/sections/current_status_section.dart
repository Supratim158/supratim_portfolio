import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../widgets/glass_card.dart';
import '../../../animations/section_reveal.dart';
import '../../../animations/hover_scale.dart';

/// "Current Status" section with heading and 3 feature cards.
class CurrentStatusSection extends StatelessWidget {
  const CurrentStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SectionReveal(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.contentPadding(context),
          vertical: isMobile ? 60 : 100,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppStrings.statusLabel, style: AppTextStyles.sectionLabel),
                const SizedBox(height: 20),
                Text(
                  AppStrings.statusTitle,
                  style: isMobile
                      ? AppTextStyles.sectionTitleMobile
                      : AppTextStyles.sectionTitle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 40 : 60),
                // Feature cards
                isMobile
                    ? Column(
                        children: [
                          _featureCard(
                            Icons.psychology_outlined,
                            'AI Integration',
                            'Implementing LLM agents into cross-platform Flutter applications for seamless user experiences.',
                          ),
                          const SizedBox(height: 16),
                          _featureCard(
                            Icons.dns_outlined,
                            'Scalable Backends',
                            'Designing distributed systems that handle millions of requests with sub-millisecond latency.',
                          ),
                          const SizedBox(height: 16),
                          _featureCard(
                            Icons.shield_outlined,
                            'Innovative Digital Products',
                            'Creating practical and impactful software solutions focused on performance, usability, and modern user experiences.',
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _featureCard(
                              Icons.psychology_outlined,
                              'AI Integration',
                              'Implementing LLM agents into cross-platform Flutter applications for seamless user experiences.',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _featureCard(
                              Icons.dns_outlined,
                              'Scalable Backends',
                              'Designing distributed systems that handle millions of requests with sub-millisecond latency.',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _featureCard(
                              Icons.shield_outlined,
                              'Secure Protocols',
                              'Auditing smart contracts and building resilient cryptographic layers for modern finance.',
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String description) {
    return HoverScale(
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 24),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.cardTitle),
            const SizedBox(height: 10),
            Text(description, style: AppTextStyles.cardDescription),
          ],
        ),
      ),
    );
  }
}
