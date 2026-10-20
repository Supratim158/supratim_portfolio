import 'package:flutter/material.dart';

/// Legacy PageNavigation placeholder.
/// Page navigation is now cleanly integrated directly into [AppFooter] in the bottom right corner.
class PageNavigation extends StatelessWidget {
  final int currentIndex;

  const PageNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
