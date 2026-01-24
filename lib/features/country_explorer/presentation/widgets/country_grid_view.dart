import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/country_provider.dart';
import 'country_grid_card.dart';

/// Country Grid View
class CountryGridView extends ConsumerWidget {
  const CountryGridView({super.key, required this.isArabic});

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

        if (filteredCountries.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(l10n.noCountriesFound),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final country = filteredCountries[index];
                return CountryGridCard(
                  country: country,
                  isArabic: isArabic,
                  index: index,
                );
              },
              childCount: filteredCountries.length,
            ),
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
      error: (_, __) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              children: [
                const Icon(Icons.error, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(l10n.error),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
