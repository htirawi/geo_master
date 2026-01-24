import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/chat_message.dart';

/// Chat message bubble widget with markdown support
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isArabic,
    this.onBookmark,
    this.onShare,
    this.onReaction,
    this.onSpeak,
    this.isBookmarked = false,
    this.isSpeaking = false,
    this.reactions = const [],
  });

  final ChatMessage message;
  final bool isArabic;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onReaction;
  final VoidCallback? onSpeak;
  final bool isBookmarked;
  final bool isSpeaking;
  final List<String> reactions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppDimensions.spacingMD,
        left: isUser ? AppDimensions.spacingXL : 0,
        right: isUser ? 0 : AppDimensions.spacingXL,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                _buildAvatar(theme, isUser),
                const SizedBox(width: AppDimensions.spacingSM),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showMessageOptions(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMD,
                      vertical: AppDimensions.paddingSM,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppDimensions.radiusMD),
                        topRight: const Radius.circular(AppDimensions.radiusMD),
                        bottomLeft: Radius.circular(
                          isUser ? AppDimensions.radiusMD : 4,
                        ),
                        bottomRight: Radius.circular(
                          isUser ? 4 : AppDimensions.radiusMD,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.isStreaming && message.content.isEmpty)
                          _buildTypingDots(theme)
                        else if (isUser)
                          SelectableText(
                            message.content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                            textDirection:
                                isArabic ? TextDirection.rtl : TextDirection.ltr,
                          )
                        else
                          _buildMarkdownContent(context, theme),
                        if (message.isStreaming && message.content.isNotEmpty)
                          _buildStreamingCursor(theme, isUser),
                      ],
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: AppDimensions.spacingSM),
                _buildAvatar(theme, isUser),
              ],
            ],
          ),
          // Action buttons for assistant messages
          if (!isUser && !message.isStreaming && message.content.isNotEmpty)
            _buildActionButtons(context, theme),
          // Reactions display
          if (reactions.isNotEmpty) _buildReactionsDisplay(theme),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return MarkdownBody(
      data: message.content,
      selectable: true,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.5,
        ),
        h1: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        h2: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        h3: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        h4: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        strong: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        em: TextStyle(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurface,
        ),
        code: TextStyle(
          fontFamily: 'monospace',
          backgroundColor: isDark
              ? Colors.grey.shade800
              : Colors.grey.shade200,
          color: isDark ? Colors.green.shade300 : Colors.green.shade800,
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquote: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.primary,
              width: 4,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        listBullet: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        listIndent: 16,
        tableHead: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        tableBody: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        tableBorder: TableBorder.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
        tableColumnWidth: const IntrinsicColumnWidth(),
        tableCellsPadding: const EdgeInsets.all(8),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        a: TextStyle(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          _launchUrl(href);
        }
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4, // Small spacing between message and action buttons
        left: 40, // Align with message bubble
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionIconButton(
            icon: Icons.copy_outlined,
            tooltip: 'Copy',
            onPressed: () => _copyToClipboard(context),
          ),
          if (onBookmark != null)
            _ActionIconButton(
              icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
              onPressed: onBookmark!,
              isActive: isBookmarked,
            ),
          if (onShare != null)
            _ActionIconButton(
              icon: Icons.share_outlined,
              tooltip: 'Share',
              onPressed: onShare!,
            ),
          if (onSpeak != null)
            _ActionIconButton(
              icon: isSpeaking ? Icons.stop : Icons.volume_up_outlined,
              tooltip: isSpeaking ? 'Stop' : 'Read aloud',
              onPressed: onSpeak!,
              isActive: isSpeaking,
            ),
          if (onReaction != null)
            _ActionIconButton(
              icon: Icons.add_reaction_outlined,
              tooltip: 'Add reaction',
              onPressed: onReaction!,
            ),
        ],
      ),
    );
  }

  Widget _buildReactionsDisplay(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4, // Small spacing between message and reactions
        left: 40,
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: reactions.map((emoji) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(context);
                },
              ),
              if (!message.isUser) ...[
                if (onBookmark != null)
                  ListTile(
                    leading: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    title: Text(isBookmarked ? 'Remove bookmark' : 'Bookmark'),
                    onTap: () {
                      Navigator.pop(context);
                      onBookmark!();
                    },
                  ),
                if (onShare != null)
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text('Share'),
                    onTap: () {
                      Navigator.pop(context);
                      onShare!();
                    },
                  ),
                if (onSpeak != null)
                  ListTile(
                    leading: Icon(
                      isSpeaking ? Icons.stop : Icons.volume_up_outlined,
                    ),
                    title: Text(isSpeaking ? 'Stop reading' : 'Read aloud'),
                    onTap: () {
                      Navigator.pop(context);
                      onSpeak!();
                    },
                  ),
                if (onReaction != null)
                  ListTile(
                    leading: const Icon(Icons.add_reaction_outlined),
                    title: const Text('Add reaction'),
                    onTap: () {
                      Navigator.pop(context);
                      onReaction!();
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser
          ? theme.colorScheme.primaryContainer
          : AppColors.secondary.withValues(alpha: 0.2),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 18,
        color: isUser ? theme.colorScheme.primary : AppColors.secondary,
      ),
    );
  }

  Widget _buildTypingDots(ThemeData theme) {
    return const TypingDotsAnimation();
  }

  Widget _buildStreamingCursor(ThemeData theme, bool isUser) {
    return const StreamingCursor();
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

/// Action icon button for message actions
class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Typing dots animation for loading state
class TypingDotsAnimation extends StatefulWidget {
  const TypingDotsAnimation({super.key});

  @override
  State<TypingDotsAnimation> createState() => _TypingDotsAnimationState();
}

class _TypingDotsAnimationState extends State<TypingDotsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.33;
            final value = (_controller.value + delay) % 1.0;
            final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Streaming cursor animation
class StreamingCursor extends StatefulWidget {
  const StreamingCursor({super.key});

  @override
  State<StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<StreamingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 2,
            height: 16,
            margin: const EdgeInsetsDirectional.only(start: 2),
            color: theme.colorScheme.onSurface,
          ),
        );
      },
    );
  }
}
