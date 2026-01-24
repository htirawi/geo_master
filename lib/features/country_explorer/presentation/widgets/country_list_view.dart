import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/country_provider.dart';
import '../../../../presentation/widgets/error_widgets.dart';
import 'country_list_card.dart';

/// Country List View
class CountryListView extends ConsumerWidget {
  const CountryListView({super.key, required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final countryState = ref.watch(countryListProvider);
    final filteredCountries = ref.watch(regionFilteredCountriesProvider);

    return countryState.when(
      data: (state) {
        if (state is CountryListLoading) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(color: AppColors.tertiary),
              ),
            ),
          );
        }

        if (state is CountryListError) {
          return SliverToBoxAdapter(
            child: _buildError(context, ref, state.failure.message, l10n),
          );
        }

        if (filteredCountries.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmpty(context, l10n),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final country = filteredCountries[index];
              return CountryListCard(
                country: country,
                isArabic: isArabic,
                index: index,
              );
            },
            childCount: filteredCountries.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(color: AppColors.tertiary),
          ),
        ),
      ),
      error: (error, _) =>
          SliverToBoxAdapter(child: _buildError(context, ref, error.toString(), l10n)),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCountriesFound,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    String error,
    AppLocalizations l10n,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Create a failure from the error string
    final failure = NetworkFailure(
      message: error,
      code: 'unknown',
    );

    return ErrorStateWidget.fromFailure(
      failure: failure,
      isArabic: isArabic,
      onRetry: () => ref.read(countryListProvider.notifier).loadCountries(
            forceRefresh: true,
          ),
    );
  }
}
