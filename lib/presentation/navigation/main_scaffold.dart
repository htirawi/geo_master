import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/routes.dart';
import '../../core/extensions/context_extensions.dart';
import '../components/navigation/explorer_bottom_nav.dart';

/// Main scaffold with Explorer's Journey themed bottom navigation
///
/// Wraps the main app screens with a persistent glass-morphism
/// bottom navigation bar following the "Explorer's Compass" design.
class MainScaffold extends ConsumerWidget {
  const MainScaffold({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      extendBody: true, // Allow content to extend behind bottom nav
      bottomNavigationBar: const _ExplorerBottomNavWrapper(),
    );
  }
}

/// Wrapper that provides localized labels and routing to ExplorerBottomNav
class _ExplorerBottomNavWrapper extends ConsumerWidget {
  const _ExplorerBottomNavWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);
    final l10n = context.l10n;

    // Build navigation items with localized labels
    final items = [
      ExplorerNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l10n.home,
      ),
      ExplorerNavItem(
        icon: Icons.public_outlined,
        activeIcon: Icons.public_rounded,
        label: l10n.explore,
      ),
      ExplorerNavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: l10n.quiz,
        isElevated: true, // Center elevated button
      ),
      ExplorerNavItem(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights_rounded,
        label: l10n.stats,
      ),
      ExplorerNavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: l10n.profile,
      ),
    ];

    return ExplorerBottomNav(
      currentIndex: currentIndex,
      items: items,
      onTap: (index) => _onItemTapped(context, index),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(Routes.home)) return 0;
    if (location.startsWith(Routes.explore)) return 1;
    if (location.startsWith(Routes.quiz)) return 2;
    if (location.startsWith(Routes.stats)) return 3;
    if (location.startsWith(Routes.profile)) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
      case 1:
        context.go(Routes.explore);
      case 2:
        context.go(Routes.quiz);
      case 3:
        context.go(Routes.stats);
      case 4:
        context.go(Routes.profile);
    }
  }
}
