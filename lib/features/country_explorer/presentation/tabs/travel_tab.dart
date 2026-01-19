import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/phrase.dart';
import '../../../../domain/entities/place_of_interest.dart';
import '../../../../domain/repositories/i_country_content_repository.dart';
import '../../../../presentation/providers/country_content_provider.dart';

/// Travel tab showing places, essentials, phrases, and tips
class TravelTab extends ConsumerWidget {
  const TravelTab({
    super.key,
    required this.countryCode,
    required this.countryName,
  });

  final String countryCode;
  final String countryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final placesAsync = ref.watch(placesOfInterestProvider(countryCode));
    final essentialsAsync = ref.watch(travelEssentialsProvider(countryCode));
    final phrasesAsync = ref.watch(essentialPhrasesProvider(countryCode));
    final tipsAsync = ref.watch(travelTipsProvider(countryCode));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top places to visit
          placesAsync.when(
            data: (places) => places.isNotEmpty
                ? _PlacesSection(places: places, isArabic: isArabic)
                : const SizedBox.shrink(),
            loading: () => const _SectionLoading(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // Travel essentials
          essentialsAsync.when(
            data: (essentials) => essentials != null
                ? _EssentialsSection(essentials: essentials, isArabic: isArabic)
                : const SizedBox.shrink(),
            loading: () => const _SectionLoading(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // Essential phrases
          phrasesAsync.when(
            data: (phrases) => phrases.isNotEmpty
                ? _PhrasesSection(phrases: phrases, isArabic: isArabic)
                : const SizedBox.shrink(),
            loading: () => const _SectionLoading(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // Travel tips
          tipsAsync.when(
            data: (tips) => tips.isNotEmpty
                ? _TipsSection(tips: tips, isArabic: isArabic)
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
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Places to visit section
class _PlacesSection extends StatelessWidget {
  const _PlacesSection({
    required this.places,
    required this.isArabic,
  });

  final List<PlaceOfInterest> places;
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
              Icons.place,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'أماكن تستحق الزيارة' : 'Top Places to Visit',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _PlaceCard(place: place, isArabic: isArabic);
            },
          ),
        ),
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.isArabic,
  });

  final PlaceOfInterest place;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsetsDirectional.only(end: 12),
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  place.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: place.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.photo, size: 40),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.photo, size: 40),
                          ),
                        ),
                  // Type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(place.type).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTypeName(place.type, isArabic),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.getDisplayName(isArabic: isArabic),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (place.description != null)
                      Expanded(
                        child: Text(
                          place.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (place.rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            place.rating!.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(PlaceType type) {
    switch (type) {
      case PlaceType.landmark:
        return const Color(0xFF1976D2);
      case PlaceType.naturalWonder:
        return const Color(0xFF4CAF50);
      case PlaceType.museum:
        return const Color(0xFF9C27B0);
      case PlaceType.historicalSite:
        return const Color(0xFF795548);
      case PlaceType.religiousSite:
        return const Color(0xFFFF9800);
      case PlaceType.park:
        return const Color(0xFF2E7D32);
      case PlaceType.beach:
        return const Color(0xFF00BCD4);
      case PlaceType.mountain:
        return const Color(0xFF607D8B);
      case PlaceType.lake:
        return const Color(0xFF0288D1);
      case PlaceType.waterfall:
        return const Color(0xFF26C6DA);
      case PlaceType.castle:
        return const Color(0xFF5D4037);
      case PlaceType.palace:
        return const Color(0xFFE91E63);
      case PlaceType.temple:
        return const Color(0xFFFF5722);
      case PlaceType.monument:
        return const Color(0xFF3F51B5);
      case PlaceType.bridge:
        return const Color(0xFF455A64);
      case PlaceType.tower:
        return const Color(0xFF546E7A);
      case PlaceType.market:
        return const Color(0xFFFF7043);
      case PlaceType.neighborhood:
        return const Color(0xFF78909C);
      case PlaceType.other:
        return const Color(0xFF757575);
    }
  }

  String _getTypeName(PlaceType type, bool isArabic) {
    switch (type) {
      case PlaceType.landmark:
        return isArabic ? 'معلم' : 'Landmark';
      case PlaceType.naturalWonder:
        return isArabic ? 'طبيعة' : 'Nature';
      case PlaceType.museum:
        return isArabic ? 'متحف' : 'Museum';
      case PlaceType.historicalSite:
        return isArabic ? 'تاريخي' : 'Historic';
      case PlaceType.religiousSite:
        return isArabic ? 'ديني' : 'Religious';
      case PlaceType.park:
        return isArabic ? 'حديقة' : 'Park';
      case PlaceType.beach:
        return isArabic ? 'شاطئ' : 'Beach';
      case PlaceType.mountain:
        return isArabic ? 'جبل' : 'Mountain';
      case PlaceType.lake:
        return isArabic ? 'بحيرة' : 'Lake';
      case PlaceType.waterfall:
        return isArabic ? 'شلال' : 'Waterfall';
      case PlaceType.castle:
        return isArabic ? 'قلعة' : 'Castle';
      case PlaceType.palace:
        return isArabic ? 'قصر' : 'Palace';
      case PlaceType.temple:
        return isArabic ? 'معبد' : 'Temple';
      case PlaceType.monument:
        return isArabic ? 'نصب' : 'Monument';
      case PlaceType.bridge:
        return isArabic ? 'جسر' : 'Bridge';
      case PlaceType.tower:
        return isArabic ? 'برج' : 'Tower';
      case PlaceType.market:
        return isArabic ? 'سوق' : 'Market';
      case PlaceType.neighborhood:
        return isArabic ? 'حي' : 'District';
      case PlaceType.other:
        return isArabic ? 'أخرى' : 'Other';
    }
  }
}

/// Travel essentials section
class _EssentialsSection extends StatelessWidget {
  const _EssentialsSection({
    required this.essentials,
    required this.isArabic,
  });

  final TravelEssentials essentials;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.luggage,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'أساسيات السفر' : 'Travel Essentials',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Grid of essentials
            Row(
              children: [
                Expanded(
                  child: _EssentialItem(
                    icon: Icons.flight,
                    label: isArabic ? 'التأشيرة' : 'Visa',
                    value: (essentials.visaRequired ?? false)
                        ? (isArabic ? 'مطلوبة' : 'Required')
                        : (isArabic ? 'غير مطلوبة' : 'Not Required'),
                    color: (essentials.visaRequired ?? false) ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EssentialItem(
                    icon: Icons.electrical_services,
                    label: isArabic ? 'الكهرباء' : 'Plug Type',
                    value: essentials.electricityPlugTypes.isNotEmpty
                        ? essentials.electricityPlugTypes.first
                        : '-',
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _EssentialItem(
                    icon: Icons.drive_eta,
                    label: isArabic ? 'القيادة' : 'Driving',
                    value: essentials.drivingSide == 'left'
                        ? (isArabic ? 'يسار' : 'Left')
                        : (isArabic ? 'يمين' : 'Right'),
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EssentialItem(
                    icon: Icons.bolt,
                    label: isArabic ? 'الفولت' : 'Voltage',
                    value: essentials.voltage != null
                        ? '${essentials.voltage}V'
                        : '-',
                    color: const Color(0xFF00BCD4),
                  ),
                ),
              ],
            ),
            if (essentials.bestTimeToVisit != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'أفضل وقت للزيارة' : 'Best Time to Visit',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          essentials.bestTimeToVisit!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EssentialItem extends StatelessWidget {
  const _EssentialItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Essential phrases section
class _PhrasesSection extends StatelessWidget {
  const _PhrasesSection({
    required this.phrases,
    required this.isArabic,
  });

  final List<Phrase> phrases;
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
              Icons.record_voice_over,
              size: 20,
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'عبارات أساسية' : 'Essential Phrases',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...phrases.take(8).map((phrase) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.translate,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                title: Text(
                  phrase.original,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(phrase.getTranslation(isArabic: isArabic)),
                    if (phrase.pronunciation != null)
                      Text(
                        phrase.pronunciation!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                trailing: phrase.audioUrl != null
                    ? IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () {
                          // Play audio
                        },
                      )
                    : null,
              ),
            )),
      ],
    );
  }
}

/// Travel tips section
class _TipsSection extends StatelessWidget {
  const _TipsSection({
    required this.tips,
    required this.isArabic,
  });

  final List<String> tips;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.tips_and_updates,
                  size: 20,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'نصائح السفر' : 'Travel Tips',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.take(5).toList().asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
