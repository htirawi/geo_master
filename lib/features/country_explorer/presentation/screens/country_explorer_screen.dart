import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/providers/country_provider.dart';
import '../widgets/country_grid_view.dart';
import '../widgets/country_list_view.dart';
import '../widgets/explorer_header.dart';
import '../widgets/region_filter_section.dart';
import '../widgets/view_toggle_header.dart';

/// Country explorer screen - World Atlas Theme
/// A beautifully designed explorer with an immersive geography experience
class CountryExplorerScreen extends ConsumerStatefulWidget {
  const CountryExplorerScreen({super.key});

  @override
  ConsumerState<CountryExplorerScreen> createState() =>
      _CountryExplorerScreenState();
}

class _CountryExplorerScreenState extends ConsumerState<CountryExplorerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final searchQuery = ref.watch(countrySearchQueryProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Explorer Header
          SliverToBoxAdapter(
            child: ExplorerHeader(
              isArabic: isArabic,
              searchController: _searchController,
              onSearchChanged: (value) {
                ref.read(countrySearchQueryProvider.notifier).state = value;
              },
              searchQuery: searchQuery,
              onClearSearch: () {
                _searchController.clear();
                ref.read(countrySearchQueryProvider.notifier).state = '';
              },
            ),
          ),
          // Region Filter
          SliverToBoxAdapter(
            child: RegionFilterSection(
              selectedRegion: selectedRegion,
              onRegionSelected: (region) {
                HapticFeedback.selectionClick();
                ref.read(selectedRegionProvider.notifier).state = region;
              },
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ),
          // View Toggle & Count
          SliverToBoxAdapter(
            child: ViewToggleHeader(
              isGridView: _isGridView,
              onViewToggle: () {
                HapticFeedback.lightImpact();
                setState(() => _isGridView = !_isGridView);
              },
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ),
          // Country List/Grid
          _isGridView
              ? CountryGridView(isArabic: isArabic)
              : CountryListView(isArabic: isArabic),
          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}
