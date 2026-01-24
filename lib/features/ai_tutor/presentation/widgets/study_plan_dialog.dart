import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Dialog for configuring AI study plan generation
class StudyPlanDialog extends StatefulWidget {
  const StudyPlanDialog({
    super.key,
    required this.onGenerate,
    this.isPremium = false,
  });

  final void Function(String goal, String duration, int hoursPerDay) onGenerate;
  final bool isPremium;

  @override
  State<StudyPlanDialog> createState() => _StudyPlanDialogState();
}

class _StudyPlanDialogState extends State<StudyPlanDialog> {
  final _goalController = TextEditingController();
  String _selectedDuration = '4 weeks';
  int _hoursPerDay = 1;

  final List<String> _durations = [
    '1 week',
    '2 weeks',
    '4 weeks',
    '8 weeks',
    '12 weeks',
  ];

  final List<String> _suggestedGoals = [
    'Learn all world capitals',
    'Master European geography',
    'Understand climate patterns',
    'Study African countries',
    'Learn about world rivers',
    'Prepare for geography exam',
  ];

  @override
  void dispose() {
    _goalController.dispose();
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
                      Icons.calendar_month,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Study Plan',
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
              const SizedBox(height: 16),

              // Description
              Text(
                'Let AI create a personalized learning path based on your goals.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Goal input
              Text(
                'Learning Goal',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _goalController,
                decoration: InputDecoration(
                  hintText: 'What do you want to learn?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Suggested goals
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedGoals.map((goal) {
                  return ActionChip(
                    label: Text(
                      goal,
                      style: theme.textTheme.labelMedium,
                    ),
                    onPressed: () {
                      _goalController.text = goal;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Duration selection
              Text(
                'Duration',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _durations.map((duration) {
                  final isSelected = _selectedDuration == duration;
                  return ChoiceChip(
                    label: Text(duration),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDuration = duration);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Hours per day
              Text(
                'Study Time: $_hoursPerDay ${_hoursPerDay == 1 ? 'hour' : 'hours'} per day',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _hoursPerDay.toDouble(),
                min: 1,
                max: 8,
                divisions: 7,
                label: '$_hoursPerDay ${_hoursPerDay == 1 ? 'hour' : 'hours'}',
                onChanged: (value) {
                  setState(() => _hoursPerDay = value.round());
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
                    onPressed: _goalController.text.trim().isNotEmpty
                        ? () {
                            Navigator.pop(context);
                            widget.onGenerate(
                              _goalController.text.trim(),
                              _selectedDuration,
                              _hoursPerDay,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Create Plan'),
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

/// Show the study plan dialog
Future<void> showStudyPlanDialog(
  BuildContext context, {
  required void Function(String goal, String duration, int hoursPerDay) onGenerate,
  bool isPremium = false,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => StudyPlanDialog(
      onGenerate: onGenerate,
      isPremium: isPremium,
    ),
  );
}
