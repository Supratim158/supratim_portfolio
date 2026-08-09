import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Responsive breakpoint utilities.
class Responsive {
  Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= AppConstants.mobileBreakpoint && w < AppConstants.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;

  static double contentPadding(BuildContext context) {
    if (isMobile(context)) return 20.0;
    if (isTablet(context)) return 40.0;
    return 80.0;
  }

  static double contentMaxWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    return AppConstants.maxContentWidth;
  }

  /// Returns a value based on the current breakpoint.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? desktop;
    return desktop;
  }
}

/// A widget that rebuilds based on screen size breakpoints.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context) desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) return mobile(context);
    if (Responsive.isTablet(context)) return (tablet ?? desktop)(context);
    return desktop(context);
  }
}

/// Constrained content wrapper that centers content with max width.
class ContentWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ContentWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.contentMaxWidth(context),
        ),
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: Responsive.contentPadding(context),
            ),
        child: child,
      ),
    );
  }
}
