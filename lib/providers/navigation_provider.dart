import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently active navigation index for the top nav / bottom nav.
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Tracks whether the loader has completed.
final loaderCompleteProvider = StateProvider<bool>((ref) => false);
