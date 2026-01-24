import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/cultural_item.dart';
import '../../../../domain/entities/place_of_interest.dart';
import '../../../../presentation/providers/country_content_provider.dart';

/// Culture tab showing foods, arts, festivals, UNESCO sites, and famous people
class CultureTab extends ConsumerWidget {
  const CultureTab({
    super.key,
    required this.countryCode,
    required this.countryName,
  });

  final String countryCode;
  final String countryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final foodsAsync = ref.watch(famousFoodsProvider(countryCode));
    final festivalsAsync = ref.watch(festivalsProvider(countryCode));
    final peopleAsync = ref.watch(famousPeopleProvider(countryCode));
    final unescoAsync = ref.watch(unescoSitesProvider(countryCode));
    final funFactsAsync = ref.watch(funFactsProvider(countryCode));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Famous foods
          foodsAsync.when(
            data: (foods) => foods.isNotEmpty
                ? _FoodSection(foods: foods, isArabic: isArabic)
                : const SizedBox.shrink(),
            loading: () => const _SectionLoading(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppDimensions.md),

          // Festivals
          festivalsAsync.when(
            data: (festivals) => festivals.isNotEmpty
                ? _FestivalsSection(festivals: festivals, isArabic: isArabic)
                : const SizedBox.shrink(),
            loading: () => const _SectionLoading(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppDimensions.md),

          // UNESCO sites
          unescoAsync.when(
            data: (sites) => sites.isNotEmpty
                ? _UnescoSection(sites: sites, isArabic: isArabic)
                : const SizedBox.shrink(),
            loading: () => const _SectionLoading(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppDimensions.md),

          // Famous people
          peopleAsync.when(
            data: (people) => people.isNotEmpty
                ? _FamousPeopleSection(people: people, isArabic: isArabic)
                : const SizedBox.shrink(),
            loading: () => const _SectionLoading(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppDimensions.md),

          // Fun facts
          funFactsAsync.when(
            data: (facts) => facts.isNotEmpty
                ? _FunFactsSection(facts: facts, isArabic: isArabic)
                : const SizedBox.shrink(),
            loading: () => const _SectionLoading(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Famous foods section
class _FoodSection extends StatelessWidget {
  const _FoodSection({
    required this.foods,
    required this.isArabic,
  });

  final List<FoodItem> foods;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.restaurant,
              size: AppDimensions.iconSM,
              color: Colors.orange,
            ),
            const SizedBox(width: AppDimensions.xs),
            Text(
              isArabic ? 'الأطباق الشهيرة' : 'Famous Foods',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return _FoodCard(food: food, isArabic: isArabic);
            },
          ),
        ),
      ],
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({
    required this.food,
    required this.isArabic,
  });

  final FoodItem food;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsetsDirectional.only(end: AppDimensions.sm),
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: food.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: food.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.restaurant, size: AppDimensions.iconXL),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.restaurant, size: AppDimensions.iconXL),
                      ),
                    ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppDimensions.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.getDisplayName(isArabic: isArabic),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (food.description != null)
                    Text(
                      food.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Festivals section
class _FestivalsSection extends StatelessWidget {
  const _FestivalsSection({
    required this.festivals,
    required this.isArabic,
  });

  final List<FestivalItem> festivals;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.celebration,
              size: AppDimensions.iconSM,
              color: Colors.purple,
            ),
            const SizedBox(width: AppDimensions.xs),
            Text(
              isArabic ? 'المهرجانات والأعياد' : 'Festivals & Holidays',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        ...festivals.take(5).map((festival) => Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.xs),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.2),
                  child: const Icon(Icons.event, color: Colors.purple),
                ),
                title: Text(
                  festival.getDisplayName(isArabic: isArabic),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: festival.dateRange != null
                    ? Text(festival.dateRange!)
                    : (festival.description != null
                        ? Text(
                            festival.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null),
                trailing: festival.isNationalHoliday
                    ? const Chip(
                        label: Text('National'),
                        labelStyle: TextStyle(fontSize: 10),
                        padding: EdgeInsets.zero,
                      )
                    : null,
              ),
            )),
      ],
    );
  }
}

/// UNESCO World Heritage Sites section
class _UnescoSection extends StatelessWidget {
  const _UnescoSection({
    required this.sites,
    required this.isArabic,
  });

  final List<PlaceOfInterest> sites;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.account_balance,
              size: AppDimensions.iconSM,
              color: Color(0xFF1976D2),
            ),
            const SizedBox(width: AppDimensions.xs),
            Text(
              isArabic ? 'مواقع التراث العالمي' : 'UNESCO Heritage Sites',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppDimensions.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Text(
                '${sites.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        ...sites.take(5).map((site) => Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.xs),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: site.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: site.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.account_balance),
                            ),
                          )
                        : Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.account_balance),
                          ),
                  ),
                ),
                title: Text(
                  site.getDisplayName(isArabic: isArabic),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: site.description != null
                    ? Text(
                        site.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
              ),
            )),
      ],
    );
  }
}

/// Famous people section
class _FamousPeopleSection extends StatelessWidget {
  const _FamousPeopleSection({
    required this.people,
    required this.isArabic,
  });

  final List<FamousPerson> people;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person,
              size: AppDimensions.iconSM,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppDimensions.xs),
            Text(
              isArabic ? 'شخصيات مشهورة' : 'Famous People',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              return _PersonCard(person: person, isArabic: isArabic);
            },
          ),
        ),
      ],
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.person,
    required this.isArabic,
  });

  final FamousPerson person;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsetsDirectional.only(end: AppDimensions.sm),
      child: SizedBox(
        width: 120,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: AppDimensions.iconLG,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: person.imageUrl != null
                    ? CachedNetworkImageProvider(person.imageUrl!)
                    : null,
                child: person.imageUrl == null
                    ? Icon(
                        Icons.person,
                        size: AppDimensions.iconLG,
                        color: theme.colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                person.getDisplayName(isArabic: isArabic),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (person.getProfession(isArabic: isArabic) != null)
                Text(
                  person.getProfession(isArabic: isArabic)!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fun facts section
class _FunFactsSection extends StatelessWidget {
  const _FunFactsSection({
    required this.facts,
    required this.isArabic,
  });

  final List<FunFact> facts;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lightbulb,
              size: AppDimensions.iconSM,
              color: Colors.amber,
            ),
            const SizedBox(width: AppDimensions.xs),
            Text(
              isArabic ? 'حقائق ممتعة' : 'Fun Facts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        ...facts.take(5).map((fact) => Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.xs),
              color: Colors.amber.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: AppDimensions.iconSM,
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        fact.getFact(isArabic: isArabic),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
