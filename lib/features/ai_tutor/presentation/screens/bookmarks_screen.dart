import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/entities/bookmark.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/ai_tutor_provider.dart';

/// Screen displaying bookmarked AI tutor responses
class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          bookmarksAsync.when(
            data: (bookmarks) => bookmarks.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () => _confirmClearAll(context),
                    tooltip: 'Clear all',
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          // Filter bookmarks based on search query
          final filteredBookmarks = _searchQuery.isEmpty
              ? bookmarks
              : bookmarks.where((b) {
                  final lowerQuery = _searchQuery.toLowerCase();
                  return b.content.toLowerCase().contains(lowerQuery) ||
                      (b.note?.toLowerCase().contains(lowerQuery) ?? false) ||
                      b.tags.any((t) => t.toLowerCase().contains(lowerQuery));
                }).toList();

          return Column(
            children: [
              // Search bar
              if (bookmarks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search bookmarks...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      // Security: Hide counter
                      counterText: '',
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    // Security: Limit search query length
                    maxLength: 100,
                  ),
                ),

              // Bookmarks list
              Expanded(
                child: filteredBookmarks.isEmpty
                    ? _buildEmptyState(theme, l10n, bookmarks.isEmpty)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMD,
                        ),
                        itemCount: filteredBookmarks.length,
                        itemBuilder: (context, index) {
                          final bookmark = filteredBookmarks[index];
                          return _BookmarkCard(
                            bookmark: bookmark,
                            isArabic: isArabic,
                            onShare: () => _shareBookmark(bookmark),
                            onCopy: () => _copyBookmark(context, bookmark),
                            onDelete: () => _deleteBookmark(context, bookmark),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading bookmarks: $error'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    AppLocalizations l10n,
    bool noBookmarks,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              noBookmarks ? Icons.bookmark_border : Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            Text(
              noBookmarks ? 'No bookmarks yet' : 'No matches found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              noBookmarks
                  ? 'Save helpful AI responses by tapping the bookmark icon'
                  : 'Try a different search term',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all bookmarks?'),
        content: const Text(
          'This will permanently delete all your saved bookmarks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(aiTutorProvider.notifier).clearBookmarks();
    }
  }

  Future<void> _shareBookmark(Bookmark bookmark) async {
    final text = '''
${bookmark.content}

---
Saved from GeoMaster AI Tutor
''';
    await Share.share(text);
  }

  void _copyBookmark(BuildContext context, Bookmark bookmark) {
    Clipboard.setData(ClipboardData(text: bookmark.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _deleteBookmark(BuildContext context, Bookmark bookmark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete bookmark?'),
        content: const Text('This bookmark will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(aiTutorProvider.notifier).removeBookmark(bookmark.id);
    }
  }
}

/// Card widget for displaying a single bookmark
class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({
    required this.bookmark,
    required this.isArabic,
    required this.onShare,
    required this.onCopy,
    required this.onDelete,
  });

  final Bookmark bookmark;
  final bool isArabic;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content preview
              Text(
                bookmark.content,
                style: theme.textTheme.bodyMedium,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              ),
              const SizedBox(height: AppDimensions.spacingSM),

              // Tags
              if (bookmark.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: bookmark.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (bookmark.tags.isNotEmpty)
                const SizedBox(height: AppDimensions.spacingSM),

              // Note
              if (bookmark.note != null && bookmark.note!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bookmark.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (bookmark.note != null && bookmark.note!.isNotEmpty)
                const SizedBox(height: AppDimensions.spacingSM),

              // Footer with date and actions
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(bookmark.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    iconSize: 20,
                    onPressed: onShare,
                    tooltip: 'Share',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 20,
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
