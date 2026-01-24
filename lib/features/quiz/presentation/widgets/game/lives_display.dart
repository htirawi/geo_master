import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

/// Lives display widget for marathon mode
class LivesDisplay extends StatelessWidget {
  const LivesDisplay({
    super.key,
    required this.lives,
  });

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final hasLife = index < lives;
          return Icon(
            hasLife ? Icons.favorite : Icons.favorite_border,
            color: hasLife ? AppColors.error : Colors.grey,
            size: 20,
          );
        }),
      ),
    );
  }
}
