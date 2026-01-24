import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../domain/entities/chat_message.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/ai_tutor_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/essay_input_dialog.dart';
import '../widgets/image_picker_button.dart';
import '../widgets/quiz_generation_dialog.dart';
import '../widgets/reaction_picker.dart';
import '../widgets/study_plan_dialog.dart';
import '../widgets/suggested_prompts_section.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/voice_input_button.dart';
import 'bookmarks_screen.dart';

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
  bool _showVoiceOverlay = false;
  String _voiceTranscription = '';
  Uint8List? _pendingImage;
  String? _pendingImageMimeType;
  String? _speakingMessageId;

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

    // Initialize services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
  }

  Future<void> _initializeServices() async {
    // Initialize speech service
    final speechService = ref.read(speechServiceProvider);
    await speechService.initialize();

    // Initialize TTS service
    final ttsService = ref.read(ttsServiceProvider);
    await ttsService.initialize();

    // Set TTS language based on preferences
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    await ttsService.setLanguageFromCode(isArabic ? 'ar' : 'en');

    // Listen to speech results
    ref.listen(speechResultProvider, (previous, next) {
      next.whenData((result) {
        setState(() {
          _voiceTranscription = result.recognizedWords;
        });
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _onVoiceInputComplete(result.recognizedWords);
        }
      });
    });

    // Listen to TTS status
    ref.listen(ttsStatusProvider, (previous, next) {
      next.whenData((status) {
        if (status == TTSStatus.stopped) {
          setState(() {
            _speakingMessageId = null;
          });
        }
      });
    });
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
    if (message.trim().isEmpty && _pendingImage == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final context = ref.read(tutorContextProvider);

    final imageData = _pendingImage;
    final imageMimeType = _pendingImageMimeType;

    _textController.clear();
    setState(() {
      _isComposing = false;
      _pendingImage = null;
      _pendingImageMimeType = null;
    });

    await ref.read(aiTutorProvider.notifier).sendMessage(
          userId: user.id,
          message: message,
          context: context,
          imageData: imageData,
          imageMimeType: imageMimeType,
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

  void _startVoiceInput() async {
    final speechService = ref.read(speechServiceProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Stop TTS if speaking
    final ttsService = ref.read(ttsServiceProvider);
    if (ttsService.isSpeaking) {
      await ttsService.stop();
    }

    setState(() {
      _showVoiceOverlay = true;
      _voiceTranscription = '';
    });

    final localeId = isArabic
        ? speechService.arabicLocaleId
        : speechService.englishLocaleId;

    await speechService.startListening(localeId: localeId);
  }

  void _stopVoiceInput() async {
    final speechService = ref.read(speechServiceProvider);
    await speechService.stopListening();
  }

  void _cancelVoiceInput() async {
    final speechService = ref.read(speechServiceProvider);
    await speechService.cancel();
    setState(() {
      _showVoiceOverlay = false;
      _voiceTranscription = '';
    });
  }

  void _onVoiceInputComplete(String text) {
    setState(() {
      _showVoiceOverlay = false;
    });
    if (text.isNotEmpty) {
      _sendMessage(text);
    }
  }

  void _onImageSelected(Uint8List imageData, String mimeType) {
    setState(() {
      _pendingImage = imageData;
      _pendingImageMimeType = mimeType;
    });
  }

  void _removeImage() {
    setState(() {
      _pendingImage = null;
      _pendingImageMimeType = null;
    });
  }

  void _onBookmarkTap(ChatMessage message) {
    ref.read(aiTutorProvider.notifier).toggleBookmark(message);
  }

  void _onShareTap(ChatMessage message) {
    Share.share(message.content);
  }

  void _onSpeakTap(ChatMessage message) async {
    final ttsService = ref.read(ttsServiceProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (_speakingMessageId == message.id) {
      await ttsService.stop();
      setState(() {
        _speakingMessageId = null;
      });
    } else {
      // Stop any current speech
      await ttsService.stop();

      // Set language and speak
      await ttsService.setLanguageFromCode(isArabic ? 'ar' : 'en');
      await ttsService.speak(message.content);

      setState(() {
        _speakingMessageId = message.id;
      });
    }
  }

  void _onReactionTap(ChatMessage message) {
    final reactions = ref.read(messageReactionsProvider)[message.id] ?? [];

    showReactionPickerBottomSheet(
      context,
      onReactionSelected: (emoji) {
        ref.read(aiTutorProvider.notifier).toggleReaction(message.id, emoji);
      },
      selectedReactions: reactions,
    );
  }

  void _showPremiumFeatures() {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppDimensions.avatarSM,
                height: AppDimensions.xxs,
                margin: const EdgeInsets.only(bottom: AppDimensions.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.quiz),
                title: const Text('Generate Quiz'),
                subtitle: const Text('Create a personalized geography quiz'),
                trailing: _buildPremiumBadge(),
                onTap: () {
                  Navigator.pop(context);
                  _showQuizGenerationDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Create Study Plan'),
                subtitle: const Text('Get a personalized learning path'),
                trailing: _buildPremiumBadge(),
                onTap: () {
                  Navigator.pop(context);
                  _showStudyPlanDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.rate_review),
                title: const Text('Essay Feedback'),
                subtitle: const Text('Get detailed feedback on your essay'),
                trailing: _buildPremiumBadge(),
                onTap: () {
                  Navigator.pop(context);
                  _showEssayInputDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xs, vertical: AppDimensions.xxs),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
      ),
      child: const Text(
        'Premium',
        style: TextStyle(
          color: AppColors.warning,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showQuizGenerationDialog() {
    showQuizGenerationDialog(
      context,
      isPremium: false, // TODO: Check actual subscription status
      onGenerate: (topic, difficulty, questionCount) {
        // TODO: Generate quiz and navigate to quiz screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generating quiz about $topic...'),
          ),
        );
      },
    );
  }

  void _showStudyPlanDialog() {
    showStudyPlanDialog(
      context,
      isPremium: false, // TODO: Check actual subscription status
      onGenerate: (goal, duration, hoursPerDay) {
        // TODO: Generate study plan and navigate to study plan screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Creating study plan for "$goal"...'),
          ),
        );
      },
    );
  }

  void _showEssayInputDialog() {
    showEssayInputDialog(
      context,
      isPremium: false, // TODO: Check actual subscription status
      onSubmit: (title, content) {
        // TODO: Get essay feedback and show results
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analyzing essay "$title"...'),
          ),
        );
      },
    );
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
    final bookmarkedIds = ref.watch(bookmarkedMessageIdsProvider);
    final messageReactions = ref.watch(messageReactionsProvider);
    final speechService = ref.watch(speechServiceProvider);

    // Scroll to bottom when messages update
    if (messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiTutor),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const BookmarksScreen(),
                ),
              );
            },
            tooltip: 'Bookmarks',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'premium':
                  _showPremiumFeatures();
                  break;
                case 'clear':
                  _clearChat();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'premium',
                child: ListTile(
                  leading: Icon(Icons.auto_awesome),
                  title: Text('Premium Features'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (messages.isNotEmpty)
                PopupMenuItem(
                  value: 'clear',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text(
                      l10n.clearChat,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
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
                        size: AppDimensions.iconXS,
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
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isBookmarked = bookmarkedIds.contains(message.id);
                        final reactions = messageReactions[message.id] ?? [];
                        final isSpeaking = _speakingMessageId == message.id;

                        return ChatMessageBubble(
                          message: message,
                          isArabic: isArabic,
                          isBookmarked: isBookmarked,
                          isSpeaking: isSpeaking,
                          reactions: reactions,
                          onBookmark: message.isAssistant
                              ? () => _onBookmarkTap(message)
                              : null,
                          onShare: message.isAssistant
                              ? () => _onShareTap(message)
                              : null,
                          onSpeak: message.isAssistant
                              ? () => _onSpeakTap(message)
                              : null,
                          onReaction: message.isAssistant
                              ? () => _onReactionTap(message)
                              : null,
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
                          size: AppDimensions.avatarMD,
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

              // Pending image preview
              if (_pendingImage != null)
                ImageAttachment(
                  imageData: _pendingImage!,
                  onRemove: _removeImage,
                ),

              // Input area with voice and image buttons
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSM),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Image picker button
                      ImagePickerButton(
                        onImageSelected: _onImageSelected,
                        isEnabled: !isStreaming && remainingMessages > 0,
                      ),
                      // Text input
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: l10n.typeYourQuestion,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.md,
                              vertical: AppDimensions.sm - 2,
                            ),
                            // Security: Hide counter to avoid UI clutter
                            counterText: '',
                          ),
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          maxLines: 4,
                          minLines: 1,
                          // Security: Enforce max message length at UI level
                          maxLength: 2000,
                          enabled: !isStreaming && remainingMessages > 0,
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      // Voice input or send button
                      if (_isComposing || _pendingImage != null)
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: !isStreaming && remainingMessages > 0
                              ? () => _sendMessage(_textController.text)
                              : null,
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        )
                      else
                        VoiceInputButton(
                          isListening: speechService.isListening,
                          onPressed: !isStreaming && remainingMessages > 0
                              ? () {
                                  if (speechService.isListening) {
                                    _stopVoiceInput();
                                  } else {
                                    _startVoiceInput();
                                  }
                                }
                              : () {},
                          size: AppDimensions.avatarSM,
                          isEnabled: !isStreaming && remainingMessages > 0,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Voice input overlay
          if (_showVoiceOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: _cancelVoiceInput,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: VoiceInputOverlay(
                      transcription: _voiceTranscription,
                      status: speechService.isListening
                          ? SpeechStatus.listening
                          : SpeechStatus.done,
                      onCancel: _cancelVoiceInput,
                      onDone: () => _onVoiceInputComplete(_voiceTranscription),
                      isArabic: isArabic,
                    ),
                  ),
                ),
              ),
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
            width: AppDimensions.iconXXL + 16,
            height: AppDimensions.iconXXL + 16,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: AppDimensions.avatarSM,
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
          const SizedBox(height: AppDimensions.spacingMD),
          // Feature hints
          Wrap(
            spacing: AppDimensions.xs,
            runSpacing: AppDimensions.xs,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureChip(
                theme,
                Icons.mic,
                isArabic ? 'صوت' : 'Voice',
              ),
              _buildFeatureChip(
                theme,
                Icons.image,
                isArabic ? 'صور' : 'Images',
              ),
              _buildFeatureChip(
                theme,
                Icons.bookmark,
                isArabic ? 'حفظ' : 'Save',
              ),
            ],
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

  Widget _buildFeatureChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: AppDimensions.xs - 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconXS,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: AppDimensions.xxs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
