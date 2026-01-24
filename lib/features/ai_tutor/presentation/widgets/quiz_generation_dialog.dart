import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Dialog for configuring AI quiz generation
class QuizGenerationDialog extends StatefulWidget {
  const QuizGenerationDialog({
    super.key,
    required this.onGenerate,
    this.isPremium = false,
  });

  final void Function(String topic, String difficulty, int questionCount) onGenerate;
  final bool isPremium;

  @override
  State<QuizGenerationDialog> createState() => _QuizGenerationDialogState();
}

class _QuizGenerationDialogState extends State<QuizGenerationDialog> {
  final _topicController = TextEditingController();
  String _selectedDifficulty = 'Medium';
  int _questionCount = 5;

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard', 'Expert'];
  final List<String> _suggestedTopics = [
    'World Capitals',
    'Mountain Ranges',
    'Rivers and Lakes',
    'World Flags',
    'Continents',
    'Climate Zones',
    'Famous Landmarks',
    'Population Facts',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.quiz,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generate Quiz',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!widget.isPremium)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Premium Feature',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Topic input
              Text(
                'Topic',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  hintText: 'Enter a geography topic...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              ),
              const SizedBox(height: 12),

              // Suggested topics
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedTopics.map((topic) {
                  return ActionChip(
                    label: Text(
                      topic,
                      style: theme.textTheme.labelMedium,
                    ),
                    onPressed: () {
                      _topicController.text = topic;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Difficulty selection
              Text(
                'Difficulty',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _difficulties.map((difficulty) {
                  final isSelected = _selectedDifficulty == difficulty;
                  return ChoiceChip(
                    label: Text(difficulty),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDifficulty = difficulty);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Question count
              Text(
                'Number of Questions: $_questionCount',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _questionCount.toDouble(),
                min: 3,
                max: 20,
                divisions: 17,
                label: _questionCount.toString(),
                onChanged: (value) {
                  setState(() => _questionCount = value.round());
                },
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _topicController.text.trim().isNotEmpty
                        ? () {
                            Navigator.pop(context);
                            widget.onGenerate(
                              _topicController.text.trim(),
                              _selectedDifficulty,
                              _questionCount,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show the quiz generation dialog
Future<void> showQuizGenerationDialog(
  BuildContext context, {
  required void Function(String topic, String difficulty, int questionCount) onGenerate,
  bool isPremium = false,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => QuizGenerationDialog(
      onGenerate: onGenerate,
      isPremium: isPremium,
    ),
  );
}
