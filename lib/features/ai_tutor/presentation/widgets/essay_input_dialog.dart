import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Dialog for submitting an essay for AI feedback
class EssayInputDialog extends StatefulWidget {
  const EssayInputDialog({
    super.key,
    required this.onSubmit,
    this.isPremium = false,
  });

  final void Function(String title, String content) onSubmit;
  final bool isPremium;

  @override
  State<EssayInputDialog> createState() => _EssayInputDialogState();
}

class _EssayInputDialogState extends State<EssayInputDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _wordCount = 0;

  static const int _minWords = 50;
  static const int _maxWords = 2000;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _contentController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    setState(() => _wordCount = words);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final isValidLength = _wordCount >= _minWords && _wordCount <= _maxWords;
    final hasTitle = _titleController.text.trim().isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                        Icons.rate_review,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Essay Feedback',
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
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Submit your geography essay for detailed AI feedback on accuracy, structure, depth, and clarity.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Title input
                Text(
                  'Essay Title',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter your essay title...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // Content input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Essay Content',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_wordCount words',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _wordCount < _minWords
                            ? AppColors.error
                            : _wordCount > _maxWords
                                ? AppColors.error
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'Paste or type your essay here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    helperText: 'Minimum $_minWords words, maximum $_maxWords words',
                  ),
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  maxLines: 10,
                  minLines: 6,
                ),
                const SizedBox(height: 8),

                // Word count indicator
                LinearProgressIndicator(
                  value: (_wordCount / _maxWords).clamp(0.0, 1.0),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: _wordCount < _minWords
                      ? AppColors.warning
                      : _wordCount > _maxWords
                          ? AppColors.error
                          : AppColors.success,
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
                      onPressed: hasTitle && isValidLength
                          ? () {
                              Navigator.pop(context);
                              widget.onSubmit(
                                _titleController.text.trim(),
                                _contentController.text.trim(),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Get Feedback'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Show the essay input dialog
Future<void> showEssayInputDialog(
  BuildContext context, {
  required void Function(String title, String content) onSubmit,
  bool isPremium = false,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => EssayInputDialog(
      onSubmit: onSubmit,
      isPremium: isPremium,
    ),
  );
}
