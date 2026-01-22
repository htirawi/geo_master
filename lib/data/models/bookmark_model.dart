import '../../domain/entities/bookmark.dart';

/// Bookmark data model for local storage
class BookmarkModel {
  const BookmarkModel({
    required this.id,
    required this.messageId,
    required this.content,
    required this.createdAt,
    this.tags = const [],
    this.note,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String? ?? '',
      messageId: json['messageId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      note: json['note'] as String?,
    );
  }

  factory BookmarkModel.fromEntity(Bookmark entity) {
    return BookmarkModel(
      id: entity.id,
      messageId: entity.messageId,
      content: entity.content,
      createdAt: entity.createdAt,
      tags: entity.tags,
      note: entity.note,
    );
  }

  final String id;
  final String messageId;
  final String content;
  final DateTime createdAt;
  final List<String> tags;
  final String? note;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'note': note,
    };
  }

  Bookmark toEntity() {
    return Bookmark(
      id: id,
      messageId: messageId,
      content: content,
      createdAt: createdAt,
      tags: tags,
      note: note,
    );
  }
}
