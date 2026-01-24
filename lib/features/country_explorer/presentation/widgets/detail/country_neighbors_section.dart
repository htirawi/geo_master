import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/routes/routes.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../domain/entities/country.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../presentation/providers/country_provider.dart';

/// Neighboring countries section
class CountryNeighborsSection extends ConsumerWidget {
  const CountryNeighborsSection({
    super.key,
    required this.country,
    required this.isArabic,
  });

  final Country country;
  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (country.borders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg - 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG + 4),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.xs),
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.xs + 2),
                ),
                child: const Icon(Icons.handshake_rounded,
                    size: AppDimensions.iconSM - 2, color: AppColors.forest),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                l10n.borders,
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppDimensions.xs + 2, vertical: AppDimensions.xxs),
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Text(
                  '${country.borders.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: country.borders.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
              itemBuilder: (context, index) {
                final borderCode = country.borders[index];
                final neighborAsync =
                    ref.watch(countryByCodeProvider(borderCode));

                return neighborAsync.when(
                  data: (neighbor) => NeighborCard(
                    code: borderCode,
                    flagEmoji: neighbor?.flagEmoji,
                    name: neighbor?.getDisplayName(isArabic: isArabic),
                    isArabic: isArabic,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(
                          Routes.countryDetail.replaceFirst(':code', borderCode));
                    },
                  ),
                  loading: () => NeighborCard(
                    code: borderCode,
                    isArabic: isArabic,
                    onTap: () {},
                  ),
                  error: (_, __) => NeighborCard(
                    code: borderCode,
                    isArabic: isArabic,
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Neighbor Country Card
class NeighborCard extends StatelessWidget {
  const NeighborCard({
    super.key,
    required this.code,
    this.flagEmoji,
    this.name,
    required this.isArabic,
    required this.onTap,
  });

  final String code;
  final String? flagEmoji;
  final String? name;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.flagWidthLG,
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flagEmoji ?? '🏳️',
              style: const TextStyle(fontSize: AppDimensions.avatarSM),
            ),
            const SizedBox(height: AppDimensions.xxs + 2),
            Text(
              name ?? code,
              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
