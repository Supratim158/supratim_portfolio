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
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../animations/section_reveal.dart';
import '../../animations/hover_scale.dart';

/// Tech Stack page showing all technologies organized by category.
class StackScreen extends StatelessWidget {
  const StackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final body = PullToReload(
      child: Column(
        children: [
          const NavBar(currentIndex: 2),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 30 : 60),
                  _buildHeader(context, isMobile),
                  SizedBox(height: isMobile ? 30 : 50),
                  _buildStackGrid(context, isMobile),
                  SizedBox(height: isMobile ? 30 : 50),
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
          ? AppBottomNavBar.wrapWithFloatingNav(body: body, currentIndex: 2)
          : body,
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return ContentWrapper(
      child: SectionReveal(
        child: SectionHeader(
          label: AppStrings.stackLabel,
          title: AppStrings.stackTitle,
          subtitle: AppStrings.stackDescription,
        ),
      ),
    );
  }

  Widget _buildStackGrid(BuildContext context, bool isMobile) {
    return ContentWrapper(
      child: SectionReveal(
        child: isMobile ? _buildMobileStack() : _buildDesktopStack(),
      ),
    );
  }

  Widget _buildDesktopStack() {
    return Column(
      children: [
        // Row 1: Frontend + AI
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildFrontendSection(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildBackendSection(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2: Backend + Blockchain + DevOps
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildAISection(),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                children: [
                  _buildBlockchainCard(),

                  const SizedBox(height: 16),

                  _buildDevOpsCard(),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMobileStack() {
    return Column(
      children: [
        _buildFrontendSection(),
        const SizedBox(height: 16),
        _buildBackendSection(),
        const SizedBox(height: 16),
        _buildAISection(),
        const SizedBox(height: 16),
        _buildBlockchainCard(),
        const SizedBox(height: 16),
        _buildDevOpsCard(),
      ],
    );
  }

  Widget _buildFrontendSection() {
    return HoverScale(
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.web, size: 20, color: AppColors.primaryLight),
                const SizedBox(width: 10),
                Text('Frontend Architecture', style: AppTextStyles.cardTitle),
              ],
            ),
            const SizedBox(height: 20),
            TechSectionScrollable(
              items: [
                _techRowItem(Icons.web_outlined, 'Flutter', 'Crafting responsive and high-performance mobile applications.', 'Advanced'),
                _techRowItem(Icons.web_outlined, 'HTML5', 'Structuring web content with semantic and accessible markup.', 'Intermediate'),
                _techRowItem(Icons.web_outlined, 'CSS3', 'Designing visually appealing and responsive user interfaces.', 'Intermediate'),
                _techRowItem(Icons.web_outlined, 'JavaScript', 'Powering both frontend interfaces and backend services for full-stack development.', 'Advanced'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISection() {
    return HoverScale(
      child: GlassCard(
        padding: const EdgeInsets.only(top: 28, left: 28, right: 28, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, size: 20, color: AppColors.primaryLight),
                const SizedBox(width: 10),
                Text('AI & Intelligence', style: AppTextStyles.cardTitle),
              ],
            ),
            const SizedBox(height: 20),
            TechSectionScrollable(
              useDivider: false,
              items: [
                _aiItem('OpenCV', 'Intermediate', Icons.auto_awesome),
                _aiItem('YOLO', 'Beginner', Icons.auto_awesome),
                _aiItem('MediaPipe', 'Beginner', Icons.auto_awesome),
                _aiItem('Face Recognition', 'Intermediate', Icons.auto_awesome),
                _aiItem('TensorFlow', 'Beginner', Icons.auto_awesome),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackendSection() {
    return HoverScale(
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, size: 20, color: AppColors.primaryLight),
                const SizedBox(width: 10),
                Text('Backend & Core', style: AppTextStyles.cardTitle),
              ],
            ),
            const SizedBox(height: 20),
            TechSectionScrollable(
              items: [
                _techRowItem(Icons.code, 'Node.js / Express', 'Scalable microservices architecture', 'Advanced'),
                _techRowItem(Icons.code, 'REST APIs', 'Enabling seamless communication between applications.', 'Advanced'),
                _techRowItem(Icons.code, 'Flask', 'Creating lightweight APIs and AI-powered backend solutions.', 'Intermediate'),
                _techRowItem(Icons.code, 'MongoDB', 'Managing flexible and scalable NoSQL databases.', 'Advanced'),
                _techRowItem(Icons.code, 'Firebase Firestore', 'Implementing real-time cloud database solutions.', 'Intermediate'),
                _techRowItem(Icons.code, 'PostgreSQL', 'Relational modeling & optimization', 'Expert'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockchainCard() {
    return HoverScale(
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.currency_bitcoin, size: 24, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            Text('Blockchain', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text('Solidity, Aptos Move.', style: AppTextStyles.cardDescription),
            const SizedBox(height: 24),
            Text('Beginner', style: AppTextStyles.mono(size: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildDevOpsCard() {
    return HoverScale(
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud_outlined, size: 24, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            Text('DevOps', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text('Docker, K8s, CI/CD.', style: AppTextStyles.cardDescription),
            const SizedBox(height: 24),
            Text('Beginner', style: AppTextStyles.mono(size: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _aiItem(String name, String years, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryLight),
          const SizedBox(width: 10),
          Text(name, style: AppTextStyles.mono(size: 13, color: AppColors.textPrimary)),
          const Spacer(),
          Text(years, style: AppTextStyles.mono(size: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _techRowItem(IconData icon, String name, String desc, String level) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text(desc, style: AppTextStyles.mono(size: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
        Text(level, style: AppTextStyles.mono(size: 11, color: AppColors.primaryLight)),
      ],
    );
  }

  Widget _buildCTA(BuildContext context, bool isMobile) {
    return ContentWrapper(
      child: SectionReveal(
        child: GlassCard(
          padding: EdgeInsets.all(isMobile ? 28 : 48),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Interested in my process?',
                        style: AppTextStyles.sectionTitle.copyWith(fontSize: 24)),
                    const SizedBox(height: 12),
                    Text(
                      'I follow a rigorous documentation and testing methodology to ensure code quality and long-term maintainability.',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 20),
                    _ctaButtons(context),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Interested in my process?',
                              style: AppTextStyles.sectionTitle.copyWith(fontSize: 28)),
                          const SizedBox(height: 12),
                          Text(
                            'I follow a rigorous documentation and testing methodology\nto ensure code quality and long-term maintainability.',
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                    _ctaButtons(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _ctaButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () => context.go('/metrics'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text('View Metrics', style: AppTextStyles.button),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () => context.go('/work'),
          child: Text('My Work', style: AppTextStyles.button.copyWith(decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}

/// A widget that displays a scrollable list of tech stack items when more than 4 are present,
/// showing a premium scrollbar on the right.
class TechSectionScrollable extends StatefulWidget {
  final List<Widget> items;
  final bool useDivider;
  final double height;

  const TechSectionScrollable({
    super.key,
    required this.items,
    this.useDivider = true,
    this.height = 300,
  });

  @override
  State<TechSectionScrollable> createState() => _TechSectionScrollableState();
}

class _TechSectionScrollableState extends State<TechSectionScrollable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.length <= 4) {
      final List<Widget> children = [];
      for (int i = 0; i < widget.items.length; i++) {
        children.add(widget.items[i]);
        if (i < widget.items.length - 1) {
          children.add(
            widget.useDivider
                ? const Divider(color: AppColors.border, height: 24)
                : const SizedBox(height: 12),
          );
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    final List<Widget> children = [];
    for (int i = 0; i < widget.items.length; i++) {
      children.add(widget.items[i]);
      if (i < widget.items.length - 1) {
        children.add(
          widget.useDivider
              ? const Divider(color: AppColors.border, height: 24)
              : const SizedBox(height: 12),
        );
      }
    }

    return SizedBox(
      height: widget.height,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
