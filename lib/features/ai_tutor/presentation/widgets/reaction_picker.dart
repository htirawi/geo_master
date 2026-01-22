import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';

/// Geography-themed emoji reactions for AI tutor messages
class ReactionPicker extends StatelessWidget {
  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
    this.selectedReactions = const [],
  });

  final void Function(String emoji) onReactionSelected;
  final List<String> selectedReactions;

  /// Geography-themed emoji options
  static const List<String> reactions = [
    '🌍', // Globe
    '🗺️', // Map
    '📍', // Pin
    '🏔️', // Mountain
    '🌊', // Ocean
    '⭐', // Star (favorite)
    '👍', // Thumbs up
    '💡', // Idea/lightbulb
    '🎓', // Graduation (learned something)
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.map((emoji) {
          final isSelected = selectedReactions.contains(emoji);
          return GestureDetector(
            onTap: () => onReactionSelected(emoji),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Shows the reaction picker as a popup
Future<String?> showReactionPicker(
  BuildContext context, {
  List<String> selectedReactions = const [],
}) async {
  final renderBox = context.findRenderObject() as RenderBox?;
  if (renderBox == null) return null;

  final position = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  return showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy - 60,
      position.dx + size.width,
      position.dy,
    ),
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
    ),
    items: [
      PopupMenuItem<String>(
        enabled: false,
        child: ReactionPicker(
          onReactionSelected: (emoji) {
            Navigator.pop(context, emoji);
          },
          selectedReactions: selectedReactions,
        ),
      ),
    ],
  );
}

/// Bottom sheet version of the reaction picker
void showReactionPickerBottomSheet(
  BuildContext context, {
  required void Function(String emoji) onReactionSelected,
  List<String> selectedReactions = const [],
}) {
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Add Reaction',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ReactionPicker.reactions.map((emoji) {
                final isSelected = selectedReactions.contains(emoji);
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onReactionSelected(emoji);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
