import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
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
    final size = MediaQuery.of(context).size;
    final flagWidth = size.width * 0.7;
    final flagHeight = flagWidth * 2 / 3; // 3:2 aspect ratio

    return Center(
      child: Container(
        width: flagWidth,
        height: flagHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: AppDimensions.lg,
              offset: const Offset(0, AppDimensions.xs),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: CountryFlag.fromCountryCode(
            country.code,
            height: flagHeight,
            width: flagWidth,
          ),
        ),
      ),
    );
  }
}
