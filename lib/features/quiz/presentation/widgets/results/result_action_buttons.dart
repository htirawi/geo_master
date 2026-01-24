import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routes/routes.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../presentation/providers/quiz_provider.dart';

/// Action buttons for quiz results
class ResultActionButtons extends ConsumerWidget {
  const ResultActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightL,
          child: FilledButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(quizStateProvider.notifier).reset();
              context.go(Routes.quiz);
            },
            icon: const Icon(Icons.replay),
            label: Text(l10n.playAgain),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMD),
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightL,
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(quizStateProvider.notifier).reset();
              context.go(Routes.home);
            },
            icon: const Icon(Icons.home),
            label: Text(l10n.backToHome),
          ),
        ),
      ],
    );
  }
}
