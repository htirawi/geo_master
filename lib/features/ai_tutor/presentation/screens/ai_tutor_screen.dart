import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/chat_message.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/ai_tutor_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/suggested_prompts_section.dart';
import '../widgets/typing_indicator.dart';

/// AI Tutor chat screen with streaming responses
class AiTutorScreen extends ConsumerStatefulWidget {
  const AiTutorScreen({
    super.key,
    this.initialCountryCode,
  });

  final String? initialCountryCode;

  @override
  ConsumerState<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends ConsumerState<AiTutorScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);

    // Update suggested prompts if we have a country context
    if (widget.initialCountryCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(aiTutorProvider.notifier).updateSuggestedPrompts(
              currentCountryCode: widget.initialCountryCode,
            );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isComposing = _textController.text.trim().isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() => _isComposing = isComposing);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final context = ref.read(tutorContextProvider);

    _textController.clear();
    setState(() => _isComposing = false);

    await ref.read(aiTutorProvider.notifier).sendMessage(
          userId: user.id,
          message: message,
          context: context,
        );

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _onSuggestedPromptTap(SuggestedPrompt prompt) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    _sendMessage(prompt.getDisplayText(isArabic: isArabic));
  }

  Future<void> _clearChat() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearChat),
        content: const Text('Are you sure you want to clear the chat history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(aiTutorProvider.notifier).clearHistory(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final aiTutorState = ref.watch(aiTutorProvider);
    final messages = ref.watch(chatMessagesProvider);
    final isStreaming = ref.watch(isStreamingProvider);
    final remainingMessages = ref.watch(remainingMessagesProvider);
    final suggestedPrompts = ref.watch(suggestedPromptsProvider);

    // Scroll to bottom when messages update
    if (messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiTutor),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearChat,
              tooltip: l10n.clearChat,
            ),
        ],
      ),
      body: Column(
        children: [
          // Remaining messages indicator
          if (remainingMessages <= 5)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD,
                vertical: AppDimensions.paddingSM,
              ),
              color: remainingMessages == 0
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    remainingMessages == 0 ? Icons.warning : Icons.info_outline,
                    size: 16,
                    color:
                        remainingMessages == 0 ? AppColors.error : AppColors.warning,
                  ),
                  const SizedBox(width: AppDimensions.spacingSM),
                  Expanded(
                    child: Text(
                      remainingMessages == 0
                          ? 'Daily message limit reached. Upgrade for unlimited chats!'
                          : '$remainingMessages messages remaining today',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: remainingMessages == 0
                            ? AppColors.error
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: aiTutorState.when(
              data: (state) {
                if (messages.isEmpty && state is! AiTutorStreaming) {
                  return _buildEmptyState(
                    theme,
                    l10n,
                    isArabic,
                    suggestedPrompts,
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  itemCount: messages.length + (isStreaming ? 0 : 0),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatMessageBubble(
                      message: message,
                      isArabic: isArabic,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppDimensions.spacingMD),
                    Text(
                      l10n.error,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.spacingSM),
                    Text(error.toString()),
                  ],
                ),
              ),
            ),
          ),

          // Typing indicator
          if (isStreaming)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD,
              ),
              child: TypingIndicator(),
            ),

          // Input field
          ChatInputField(
            controller: _textController,
            isComposing: _isComposing,
            isEnabled: !isStreaming && remainingMessages > 0,
            onSend: _sendMessage,
            hintText: l10n.typeYourQuestion,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
    List<SuggestedPrompt> suggestedPrompts,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingXL),
          // Welcome icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          // Welcome text
          Text(
            l10n.aiTutor,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            isArabic
                ? 'أنا هنا لمساعدتك في تعلم الجغرافيا!'
                : 'I\'m here to help you learn geography!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          // Suggested prompts
          SuggestedPromptsSection(
            prompts: suggestedPrompts,
            isArabic: isArabic,
            onPromptTap: _onSuggestedPromptTap,
          ),
        ],
      ),
    );
  }
}
