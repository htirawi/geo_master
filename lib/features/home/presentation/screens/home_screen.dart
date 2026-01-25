import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../widgets/compass_actions.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/expedition_progress_card.dart';
import '../widgets/explorer_header.dart';
import '../widgets/todays_destination_card.dart';
import '../widgets/world_progress_preview.dart';

/// Home screen - Explorer's Dashboard
/// An immersive geography-themed home screen that makes users feel like world explorers
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final sectionSpacing = responsive.sp(AppDimensions.spacingLG);
    final bottomPadding = responsive.sp(AppDimensions.bottomNavHeight);

    return Scaffold(
      body: CustomScrollView(
        cacheExtent: 500,
        slivers: [
          // Immersive Hero Header
          SliverToBoxAdapter(
            child: ExplorerHeader(
              userName: user?.displayName,
              isAnonymous: user?.isAnonymous ?? true,
              isArabic: isArabic,
            ),
          ),
          // Main Content - Wrapped in ResponsiveCenter for tablet/desktop
          SliverToBoxAdapter(
            child: ResponsiveCenter(
              child: Padding(
                padding: responsive.insetsSymmetric(horizontal: AppDimensions.md),
                child: Column(
                  children: [
                    SizedBox(height: sectionSpacing),
                    // Today's Destination (Country of the Day) - Most prominent
                    TodaysDestinationCard(isArabic: isArabic)
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: sectionSpacing),
                    // Quick Actions - Compass Style
                    const CompassActions()
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: sectionSpacing),
                    // Daily Challenge Card
                    const DailyChallengeCard()
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: sectionSpacing),
                    // Expedition Progress (Streak + Stats)
                    const ExpeditionProgressCard()
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: sectionSpacing),
                    // World Progress Map Preview
                    const WorldProgressPreview()
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: bottomPadding), // Bottom padding for nav bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
