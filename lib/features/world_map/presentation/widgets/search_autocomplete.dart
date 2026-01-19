import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/country.dart';
import '../../../../presentation/providers/world_map_provider.dart';

/// Search autocomplete widget for finding countries on the map
class CountrySearchAutocomplete extends ConsumerStatefulWidget {
  const CountrySearchAutocomplete({
    super.key,
    required this.onCountrySelected,
    this.onSearchFocusChanged,
  });

  final void Function(Country country) onCountrySelected;
  final void Function(bool hasFocus)? onSearchFocusChanged;

  @override
  ConsumerState<CountrySearchAutocomplete> createState() =>
      _CountrySearchAutocompleteState();
}

class _CountrySearchAutocompleteState
    extends ConsumerState<CountrySearchAutocomplete> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    widget.onSearchFocusChanged?.call(_focusNode.hasFocus);
    if (!_focusNode.hasFocus) {
      setState(() => _showSuggestions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final searchQuery = ref.watch(mapSearchQueryProvider);
    final searchResults = ref.watch(mapSearchResultsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: isArabic ? 'ابحث عن دولة...' : 'Search countries...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        ref.read(mapSearchQueryProvider.notifier).state = '';
                        setState(() => _showSuggestions = false);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
            onChanged: (value) {
              ref.read(mapSearchQueryProvider.notifier).state = value;
              setState(() => _showSuggestions = value.isNotEmpty);
            },
            onSubmitted: (value) {
              if (searchResults.isNotEmpty) {
                _selectCountry(searchResults.first);
              }
            },
          ),
        ),

        // Suggestions dropdown
        if (_showSuggestions && searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final country = searchResults[index];
                  return _CountrySearchItem(
                    country: country,
                    searchQuery: searchQuery,
                    isArabic: isArabic,
                    onTap: () => _selectCountry(country),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  void _selectCountry(Country country) {
    _controller.clear();
    ref.read(mapSearchQueryProvider.notifier).state = '';
    setState(() => _showSuggestions = false);
    _focusNode.unfocus();
    widget.onCountrySelected(country);
  }
}

class _CountrySearchItem extends StatelessWidget {
  const _CountrySearchItem({
    required this.country,
    required this.searchQuery,
    required this.isArabic,
    required this.onTap,
  });

  final Country country;
  final String searchQuery;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countryName = country.getDisplayName(isArabic: isArabic);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Flag
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 32,
                  height: 22,
                  child: CachedNetworkImage(
                    imageUrl: country.flagUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.flag,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Country info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(
                      text: countryName,
                      highlight: searchQuery,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      highlightStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (country.capital != null)
                      Text(
                        country.capital!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),

              // Continent badge
              if (country.continents.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    country.continents.first,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to highlight search matches in text
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.highlight,
    this.style,
    this.highlightStyle,
  });

  final String text;
  final String highlight;
  final TextStyle? style;
  final TextStyle? highlightStyle;

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final index = lowerText.indexOf(lowerHighlight);

    if (index < 0) {
      return Text(text, style: style);
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + highlight.length),
            style: highlightStyle,
          ),
          TextSpan(text: text.substring(index + highlight.length)),
        ],
      ),
    );
  }
}

/// Compact search bar that expands on tap
class CompactSearchBar extends StatefulWidget {
  const CompactSearchBar({
    super.key,
    required this.onExpand,
  });

  final VoidCallback onExpand;

  @override
  State<CompactSearchBar> createState() => _CompactSearchBarState();
}

class _CompactSearchBarState extends State<CompactSearchBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(28),
      elevation: 2,
      child: InkWell(
        onTap: widget.onExpand,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'بحث...' : 'Search...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full screen search overlay
class FullScreenSearch extends ConsumerStatefulWidget {
  const FullScreenSearch({
    super.key,
    required this.onCountrySelected,
    required this.onClose,
  });

  final void Function(Country country) onCountrySelected;
  final VoidCallback onClose;

  @override
  ConsumerState<FullScreenSearch> createState() => _FullScreenSearchState();
}

class _FullScreenSearchState extends ConsumerState<FullScreenSearch> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final searchQuery = ref.watch(mapSearchQueryProvider);
    final searchResults = ref.watch(mapSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(mapSearchQueryProvider.notifier).state = '';
            widget.onClose();
          },
        ),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isArabic ? 'ابحث عن دولة...' : 'Search countries...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            ref.read(mapSearchQueryProvider.notifier).state = value;
          },
        ),
        actions: [
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                ref.read(mapSearchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: searchResults.isEmpty && searchQuery.isNotEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'لا توجد نتائج' : 'No results found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : searchQuery.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.public,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isArabic
                            ? 'ابحث عن أي دولة في العالم'
                            : 'Search for any country in the world',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final country = searchResults[index];
                    return _CountrySearchItem(
                      country: country,
                      searchQuery: searchQuery,
                      isArabic: isArabic,
                      onTap: () {
                        ref.read(mapSearchQueryProvider.notifier).state = '';
                        widget.onCountrySelected(country);
                        widget.onClose();
                      },
                    );
                  },
                ),
    );
  }
}
