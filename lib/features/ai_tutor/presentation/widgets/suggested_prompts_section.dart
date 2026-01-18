import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/chat_message.dart';

/// Suggested prompts section widget
class SuggestedPromptsSection extends StatelessWidget {
  const SuggestedPromptsSection({
    super.key,
    required this.prompts,
    required this.isArabic,
    required this.onPromptTap,
  });

  final List<SuggestedPrompt> prompts;
  final bool isArabic;
  final ValueChanged<SuggestedPrompt> onPromptTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'أسئلة مقترحة' : 'Suggested Questions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMD),
        Wrap(
          spacing: AppDimensions.spacingSM,
          runSpacing: AppDimensions.spacingSM,
          children: prompts.map((prompt) {
            return _SuggestedPromptChip(
              prompt: prompt,
              isArabic: isArabic,
              onTap: () => onPromptTap(prompt),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SuggestedPromptChip extends StatelessWidget {
  const _SuggestedPromptChip({
    required this.prompt,
    required this.isArabic,
    required this.onTap,
  });

  final SuggestedPrompt prompt;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(prompt.category),
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppDimensions.spacingSM),
            Flexible(
              child: Text(
                prompt.getDisplayText(isArabic: isArabic),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'facts':
        return Icons.lightbulb_outline;
      case 'rankings':
        return Icons.leaderboard;
      case 'culture':
        return Icons.theater_comedy;
      case 'languages':
        return Icons.translate;
      case 'comparison':
        return Icons.compare_arrows;
      case 'country':
        return Icons.flag;
      case 'travel':
        return Icons.flight;
      case 'capitals':
        return Icons.location_city;
      case 'flags':
        return Icons.flag;
      case 'population':
        return Icons.people;
      default:
        return Icons.help_outline;
    }
  }
}
