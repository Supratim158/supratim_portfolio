import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive_utils.dart';
import '../models/project.dart';
import 'stacked_project_card.dart';

/// Stacking Projects Showcase:
/// - Responsive: Mobile and Web view have distinct, optimized presentations.
///   * Mobile: Clean, vertical flow where each card scrolls up naturally through the middle of the screen.
///   * Web (Desktop): Interactive stacked deck where cards scroll UP with the current active card in the MIDDLE.
/// - Lag-free: 100% pure hardware-accelerated vector glassmorphism without heavy BackdropFilters.
/// - Pinned title: Clean 'PROJECTS' title remains constant at the top.
class StackedProjectsShowcase extends StatefulWidget {
  final List<Project> projects;
  final ScrollController scrollController;

  const StackedProjectsShowcase({
    super.key,
    required this.projects,
    required this.scrollController,
  });

  @override
  State<StackedProjectsShowcase> createState() => _StackedProjectsShowcaseState();
}

class _StackedProjectsShowcaseState extends State<StackedProjectsShowcase>
    with SingleTickerProviderStateMixin {
  final GlobalKey _sectionKey = GlobalKey();

  double _localScroll = 0.0;
  bool _isMounted = false;

  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    widget.scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
      if (_isMounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _entranceController.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!_isMounted) return;
    final box = _sectionKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final globalPos = box.localToGlobal(Offset.zero);
      const navOffset = 60.0;
      final maxScroll = _getMaxScroll();
      final currentLocal = (navOffset - globalPos.dy).clamp(0.0, maxScroll);
      if ((currentLocal - _localScroll).abs() >= 1.0) {
        setState(() {
          _localScroll = currentLocal;
        });
      }
    }
  }

  double _getCardHeight() => 420.0;
  double _getScrollPerCard() => 380.0;

  int get _totalStackCount => widget.projects.length + 1;

  double _getMaxScroll() {
    final count = _totalStackCount;
    if (count <= 1) return 0.0;
    return (count - 1) * _getScrollPerCard();
  }

  void _jumpToItem(int index) {
    final box = _sectionKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final globalPos = box.localToGlobal(Offset.zero);
      const navOffset = 60.0;
      final maxScroll = _getMaxScroll();
      final currentLocal = (navOffset - globalPos.dy).clamp(0.0, maxScroll);
      final targetLocal = (index * _getScrollPerCard()).clamp(0.0, maxScroll);
      final delta = targetLocal - currentLocal;

      final targetOffset = (widget.scrollController.offset + delta).clamp(
        0.0,
        widget.scrollController.position.maxScrollExtent,
      );

      widget.scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    // MOBILE VIEW: Distinct clean vertical card flow
    if (isMobile) {
      return _buildMobileShowcase(context);
    }

    // WEB / DESKTOP VIEW: Stacked deck scrolling up with current item in the middle
    final count = _totalStackCount;
    final cardHeight = _getCardHeight();
    final scrollPerCard = _getScrollPerCard();
    final maxScroll = _getMaxScroll();

    const titleHeaderHeight = 65.0;
    const viewportHeight = 620.0;
    final totalContainerHeight = viewportHeight + maxScroll;

    final activeIndex = (count <= 1)
        ? 0
        : (_localScroll / scrollPerCard).floor().clamp(0, count - 1);

    return Container(
      key: _sectionKey,
      height: totalContainerHeight,
      width: double.infinity,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: _localScroll,
            left: 0,
            right: 0,
            height: viewportHeight,
            child: _buildDesktopShowcaseViewport(
              context: context,
              viewportHeight: viewportHeight,
              titleHeaderHeight: titleHeaderHeight,
              cardHeight: cardHeight,
              scrollPerCard: scrollPerCard,
              activeIndex: activeIndex,
            ),
          ),
        ],
      ),
    );
  }

  // ── MOBILE SHOWCASE (Distinct, clean, lag-free vertical flow) ─────
  Widget _buildMobileShowcase(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          _buildConstantTitle(context, true),
          const SizedBox(height: 20),

          // Project Cards Flow
          for (int i = 0; i < widget.projects.length; i++) ...[
            StackedProjectCard(
              index: i,
              project: widget.projects[i],
              isMobile: true,
            ),
            const SizedBox(height: 20),
          ],

          // Finale CTA Card
          _buildCtaGlassCard(
            context: context,
            isMobile: true,
            indexStr: (widget.projects.length + 1).toString().padLeft(2, '0'),
            onHeaderTap: () {},
          ),
        ],
      ),
    );
  }

  // ── DESKTOP SHOWCASE VIEWPORT ───────────────────────────────────
  Widget _buildDesktopShowcaseViewport({
    required BuildContext context,
    required double viewportHeight,
    required double titleHeaderHeight,
    required double cardHeight,
    required double scrollPerCard,
    required int activeIndex,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final centerCardWidth = screenWidth > 1400 ? 1040.0 : math.min(screenWidth - 48, 960.0);

    final safeIndex = activeIndex.clamp(0, widget.projects.length - 1);
    final activeProject = widget.projects.isNotEmpty ? widget.projects[safeIndex] : null;
    final bgImagePath = activeProject?.imagePath ?? 'assets/project/sanctuary.png';

    final availableStackHeight = viewportHeight - titleHeaderHeight;

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        final entrance = _entranceController.value;
        final curvedEntrance = Curves.easeOutCubic.transform(entrance);

        return Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Ambient theme gradient background (fast, NO heavy BackdropFilter)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.18 * curvedEntrance,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          bgImagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              radius: 1.15,
                              colors: [
                                Colors.transparent,
                                AppColors.background.withOpacity(0.92),
                                AppColors.background,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Center Column: Title + Middle-Centered Stacking Cards
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: centerCardWidth,
                height: viewportHeight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Constant Section Title: PROJECTS
                    SizedBox(
                      height: titleHeaderHeight,
                      child: _buildConstantTitle(context, false),
                    ),

                    // Cards Stack Container
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Project Cards
                          for (int i = 0; i < widget.projects.length; i++)
                            _buildAnimatedProjectCard(
                              index: i,
                              project: widget.projects[i],
                              cardHeight: cardHeight,
                              scrollPerCard: scrollPerCard,
                              availableStackHeight: availableStackHeight,
                            ),

                          // The Finale: 'Have a project in mind?' CTA Card
                          _buildAnimatedCtaCard(
                            index: widget.projects.length,
                            cardHeight: cardHeight,
                            scrollPerCard: scrollPerCard,
                            availableStackHeight: availableStackHeight,
                          ),

                          // Floating progress controls (bottom-right)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: _buildProgressControls(activeIndex),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── CONSTANT TITLE: ONLY 'PROJECTS' ─────────────────────────────
  Widget _buildConstantTitle(BuildContext context, bool isMobile) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'PROJECTS',
        style: isMobile
            ? AppTextStyles.sectionTitleMobile.copyWith(
                fontSize: 24,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w800,
              )
            : AppTextStyles.sectionTitle.copyWith(
                fontSize: 32,
                letterSpacing: 3.5,
                fontWeight: FontWeight.w800,
              ),
      ),
    );
  }

  // ── ANIMATED PROJECT CARD: SCROLLS UP WITH CURRENT ITEM IN MIDDLE ─
  Widget _buildAnimatedProjectCard({
    required int index,
    required Project project,
    required double cardHeight,
    required double scrollPerCard,
    required double availableStackHeight,
  }) {
    final count = _totalStackCount;
    // The middle position inside the card stack
    final centerTop = math.max(16.0, (availableStackHeight - cardHeight) / 2);
    // Shelf position at the top for past cards
    final topShelf = math.min(centerTop - 20.0, index * 32.0);

    double cardTop;
    double cardOpacity = 1.0;
    double cardScale = 1.0;

    final arrivalStart = (index - 1) * scrollPerCard;
    final arrivalEnd = index * scrollPerCard;
    final departureStart = index * scrollPerCard;
    final departureEnd = (index + 1) * scrollPerCard;

    if (index == 0) {
      if (_localScroll <= 0) {
        cardTop = centerTop;
        cardScale = 1.0;
        cardOpacity = 1.0;
      } else if (_localScroll < departureEnd) {
        // First card scrolling UP towards top shelf as next card enters middle
        final t = (_localScroll / scrollPerCard).clamp(0.0, 1.0);
        final curvedT = Curves.easeOutCubic.transform(t);
        cardTop = lerpDouble(centerTop, topShelf, curvedT)!;
        cardScale = lerpDouble(1.0, 0.97, curvedT)!;
        cardOpacity = 1.0;
      } else {
        cardTop = topShelf;
        cardScale = 0.97;
        cardOpacity = 1.0;
      }
    } else {
      if (_localScroll < arrivalStart) {
        // Below the view
        cardTop = availableStackHeight + 40.0;
        cardOpacity = 0.0;
      } else if (_localScroll < arrivalEnd) {
        // Scrolling UP from bottom into the MIDDLE
        final t = ((_localScroll - arrivalStart) / scrollPerCard).clamp(0.0, 1.0);
        final curvedT = Curves.easeOutCubic.transform(t);
        cardTop = lerpDouble(availableStackHeight + 40.0, centerTop, curvedT)!;
        cardOpacity = (t * 1.5).clamp(0.0, 1.0);
        cardScale = 1.0;
      } else if (index < count - 1 && _localScroll < departureEnd) {
        // Scrolling UP from MIDDLE towards the top shelf as the next card enters middle
        final t = ((_localScroll - departureStart) / scrollPerCard).clamp(0.0, 1.0);
        final curvedT = Curves.easeOutCubic.transform(t);
        cardTop = lerpDouble(centerTop, topShelf, curvedT)!;
        cardScale = lerpDouble(1.0, 0.97, curvedT)!;
        cardOpacity = 1.0;
      } else if (index < count - 1) {
        cardTop = topShelf;
        cardScale = 0.97;
        cardOpacity = 1.0;
      } else {
        // Settled in the middle
        cardTop = centerTop;
        cardOpacity = 1.0;
        cardScale = 1.0;
      }
    }

    return Positioned(
      top: cardTop,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: cardOpacity,
        child: Transform.scale(
          scale: cardScale,
          alignment: Alignment.topCenter,
          child: StackedProjectCard(
            index: index,
            project: project,
            isMobile: false,
            onHeaderTap: () => _jumpToItem(index),
          ),
        ),
      ),
    );
  }

  // ── ANIMATED CTA CARD: SCROLLS UP INTO THE MIDDLE AS FINALE ─────
  Widget _buildAnimatedCtaCard({
    required int index,
    required double cardHeight,
    required double scrollPerCard,
    required double availableStackHeight,
  }) {
    final centerTop = math.max(16.0, (availableStackHeight - cardHeight) / 2);

    double cardTop;
    double cardOpacity = 1.0;

    final arrivalStart = (index - 1) * scrollPerCard;
    final arrivalEnd = index * scrollPerCard;

    if (_localScroll < arrivalStart) {
      cardTop = availableStackHeight + 40.0;
      cardOpacity = 0.0;
    } else if (_localScroll < arrivalEnd) {
      final t = ((_localScroll - arrivalStart) / scrollPerCard).clamp(0.0, 1.0);
      final curvedT = Curves.easeOutCubic.transform(t);
      cardTop = lerpDouble(availableStackHeight + 40.0, centerTop, curvedT)!;
      cardOpacity = (t * 1.5).clamp(0.0, 1.0);
    } else {
      cardTop = centerTop;
      cardOpacity = 1.0;
    }

    return Positioned(
      top: cardTop,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: cardOpacity,
        child: _buildCtaGlassCard(
          context: context,
          isMobile: false,
          indexStr: (index + 1).toString().padLeft(2, '0'),
          onHeaderTap: () => _jumpToItem(index),
        ),
      ),
    );
  }

  Widget _buildCtaGlassCard({
    required BuildContext context,
    required bool isMobile,
    required String indexStr,
    required VoidCallback onHeaderTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.24),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Glass gradient base (hardware-accelerated, NO BackdropFilter)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E2642).withOpacity(0.92),
                      const Color(0xFF101528).withOpacity(0.95),
                      const Color(0xFF090D18).withOpacity(0.98),
                    ],
                  ),
                ),
              ),
            ),
            // Inner radial glow
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.8, -0.8),
                    radius: 1.1,
                    colors: [
                      AppColors.primaryLight.withOpacity(0.24),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header matching the card deck style
                InkWell(
                  onTap: onHeaderTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 18 : 24,
                      vertical: isMobile ? 12 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          indexStr,
                          style: AppTextStyles.mono(
                            size: isMobile ? 24 : 32,
                            color: AppColors.primaryLight,
                            weight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'GET IN TOUCH',
                              style: AppTextStyles.mono(
                                size: 9,
                                color: AppColors.textMuted,
                                letterSpacing: 2,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Let's Collaborate",
                              style: AppTextStyles.mono(
                                size: isMobile ? 12 : 14,
                                color: Colors.white,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryLight, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.rocket_launch_rounded, size: 12, color: AppColors.primaryLight),
                              const SizedBox(width: 6),
                              Text(
                                'COLLABORATE',
                                style: AppTextStyles.mono(
                                  size: 9,
                                  color: Colors.white,
                                  weight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Body
                Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have a project in mind?',
                        style: isMobile
                            ? AppTextStyles.sectionTitleMobile.copyWith(fontSize: 20)
                            : AppTextStyles.sectionTitle.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Let's build something extraordinary together.\n"
                        "I'm always open to new software collaborations, high-impact Flutter applications, and full-stack solutions.",
                        style: AppTextStyles.body.copyWith(
                          fontSize: isMobile ? 13 : 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () => context.go('/contact'),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 18 : 28,
                            vertical: isMobile ? 12 : 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryLight, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.mail_outline_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                'START A CONVERSATION',
                                style: AppTextStyles.mono(
                                  size: isMobile ? 10.5 : 12,
                                  color: Colors.white,
                                  weight: FontWeight.w700,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── PROGRESS CONTROLS (PILL NAVIGATOR) ─────────────────────────
  Widget _buildProgressControls(int activeIndex) {
    final count = _totalStackCount;
    final isCta = activeIndex == count - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navBg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: activeIndex > 0 ? () => _jumpToItem(activeIndex - 1) : null,
            child: Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: activeIndex > 0 ? Colors.white : AppColors.textMuted.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isCta ? 'CTA / END' : '${(activeIndex + 1).toString().padLeft(2, '0')} / ${(count - 1).toString().padLeft(2, '0')}',
            style: AppTextStyles.mono(
              size: 11,
              color: isCta ? AppColors.accent : AppColors.primaryLight,
              weight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: activeIndex < count - 1 ? () => _jumpToItem(activeIndex + 1) : null,
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: activeIndex < count - 1 ? Colors.white : AppColors.textMuted.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
