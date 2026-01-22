import 'package:flutter/foundation.dart';

/// Bookmark entity for saving important AI tutor responses
@immutable
class Bookmark {
  const Bookmark({
    required this.id,
    required this.messageId,
    required this.content,
    required this.createdAt,
    this.tags = const [],
    this.note,
  });

  final String id;
  final String messageId;
  final String content;
  final DateTime createdAt;
  final List<String> tags;
  final String? note;

  Bookmark copyWith({
    String? id,
    String? messageId,
    String? content,
    DateTime? createdAt,
    List<String>? tags,
    String? note,
  }) {
    return Bookmark(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Bookmark(id: $id, messageId: $messageId, createdAt: $createdAt)';
  }
}
