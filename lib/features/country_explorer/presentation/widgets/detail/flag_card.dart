import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/entities/country.dart';

/// Hero flag card for country detail screen
class FlagCard extends StatelessWidget {
  const FlagCard({
    super.key,
    required this.country,
    required this.accentColor,
  });

  final Country country;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Center(
      child: Container(
        width: size.width * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: country.flagUrl,
            fit: BoxFit.contain,
            placeholder: (_, __) => AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(country.flagEmoji, style: const TextStyle(fontSize: 48)),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(country.flagEmoji, style: const TextStyle(fontSize: 64)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
