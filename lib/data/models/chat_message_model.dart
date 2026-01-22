import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/chat_message.dart';

/// Chat message data model for local storage
class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.createdAt,
    this.isStreaming = false,
    this.imageData,
    this.imageMimeType,
    this.reactions = const [],
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    Uint8List? imageData;
    if (json['imageData'] != null) {
      try {
        imageData = base64Decode(json['imageData'] as String);
      } catch (_) {
        // Ignore decode errors
      }
    }

    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      role: MessageRole.fromString(json['role'] as String? ?? 'user'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isStreaming: json['isStreaming'] as bool? ?? false,
      imageData: imageData,
      imageMimeType: json['imageMimeType'] as String?,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      content: entity.content,
      role: entity.role,
      createdAt: entity.createdAt,
      isStreaming: entity.isStreaming,
      imageData: entity.imageData,
      imageMimeType: entity.imageMimeType,
      reactions: entity.reactions,
    );
  }

  final String id;
  final String content;
  final MessageRole role;
  final DateTime createdAt;
  final bool isStreaming;
  final Uint8List? imageData;
  final String? imageMimeType;
  final List<String> reactions;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.value,
      'createdAt': createdAt.toIso8601String(),
      'isStreaming': isStreaming,
      if (imageData != null) 'imageData': base64Encode(imageData!),
      if (imageMimeType != null) 'imageMimeType': imageMimeType,
      if (reactions.isNotEmpty) 'reactions': reactions,
    };
  }

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      content: content,
      role: role,
      createdAt: createdAt,
      isStreaming: isStreaming,
      imageData: imageData,
      imageMimeType: imageMimeType,
      reactions: reactions,
    );
  }
}

/// Tutor context data model for API requests
class TutorContextModel {
  const TutorContextModel({
    this.currentCountryCode,
    this.currentCountryName,
    this.recentQuizTopics = const [],
    this.userLevel = 1,
    this.userInterests = const [],
    this.preferredLanguage = 'en',
  });

  factory TutorContextModel.fromJson(Map<String, dynamic> json) {
    return TutorContextModel(
      currentCountryCode: json['currentCountryCode'] as String?,
      currentCountryName: json['currentCountryName'] as String?,
      recentQuizTopics: (json['recentQuizTopics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      userLevel: json['userLevel'] as int? ?? 1,
      userInterests: (json['userInterests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
    );
  }

  factory TutorContextModel.fromEntity(TutorContext entity) {
    return TutorContextModel(
      currentCountryCode: entity.currentCountryCode,
      currentCountryName: entity.currentCountryName,
      recentQuizTopics: entity.recentQuizTopics,
      userLevel: entity.userLevel,
      userInterests: entity.userInterests,
      preferredLanguage: entity.preferredLanguage,
    );
  }

  final String? currentCountryCode;
  final String? currentCountryName;
  final List<String> recentQuizTopics;
  final int userLevel;
  final List<String> userInterests;
  final String preferredLanguage;

  Map<String, dynamic> toJson() {
    return {
      'currentCountryCode': currentCountryCode,
      'currentCountryName': currentCountryName,
      'recentQuizTopics': recentQuizTopics,
      'userLevel': userLevel,
      'userInterests': userInterests,
      'preferredLanguage': preferredLanguage,
    };
  }

  TutorContext toEntity() {
    return TutorContext(
      currentCountryCode: currentCountryCode,
      currentCountryName: currentCountryName,
      recentQuizTopics: recentQuizTopics,
      userLevel: userLevel,
      userInterests: userInterests,
      preferredLanguage: preferredLanguage,
    );
  }
}

/// Chat conversation model for storing chat history
class ChatConversationModel {
  const ChatConversationModel({
    required this.id,
    required this.userId,
    required this.messages,
    required this.context,
    required this.createdAt,
    required this.updatedAt,
    this.title,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) =>
                  ChatMessageModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      context: json['context'] != null
          ? TutorContextModel.fromJson(json['context'] as Map<String, dynamic>)
          : const TutorContextModel(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      title: json['title'] as String?,
    );
  }

  final String id;
  final String userId;
  final List<ChatMessageModel> messages;
  final TutorContextModel context;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? title;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'context': context.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'title': title,
    };
  }
}
