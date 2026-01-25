
import 'package:flutter/foundation.dart';

/// Chat message entity for AI tutor
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.createdAt,
    this.isStreaming = false,
    this.imageData,
    this.imageMimeType,
    this.reactions = const [],
  });

  final String id;
  final String content;
  final MessageRole role;
  final DateTime createdAt;
  final bool isStreaming;
  final Uint8List? imageData;
  final String? imageMimeType;
  final List<String> reactions;

  /// Check if message is from user
  bool get isUser => role == MessageRole.user;

  /// Check if message is from assistant
  bool get isAssistant => role == MessageRole.assistant;

  /// Check if message has an image attachment
  bool get hasImage => imageData != null && imageData!.isNotEmpty;

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? createdAt,
    bool? isStreaming,
    Uint8List? imageData,
    String? imageMimeType,
    List<String>? reactions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
      imageData: imageData ?? this.imageData,
      imageMimeType: imageMimeType ?? this.imageMimeType,
      reactions: reactions ?? this.reactions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Message role
enum MessageRole {
  user,
  assistant,
  system;

  String get value {
    switch (this) {
      case MessageRole.user:
        return 'user';
      case MessageRole.assistant:
        return 'assistant';
      case MessageRole.system:
        return 'system';
    }
  }

  static MessageRole fromString(String value) {
    switch (value) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }
}

/// Context for AI tutor conversations
@immutable
class TutorContext {
  const TutorContext({
    this.currentCountryCode,
    this.currentCountryName,
    this.recentQuizTopics = const [],
    this.userLevel = 1,
    this.userInterests = const [],
    this.preferredLanguage = 'en',
  });

  final String? currentCountryCode;
  final String? currentCountryName;
  final List<String> recentQuizTopics;
  final int userLevel;
  final List<String> userInterests;
  final String preferredLanguage;

  /// Build system prompt for Claude
  String buildSystemPrompt() {
    final buffer = StringBuffer();

    buffer.writeln('''
You are GeoMaster's AI tutor - a friendly, knowledgeable geography expert helping users learn about countries, cultures, and the world. You specialize in making geography fun and engaging.

Guidelines:
- Be encouraging and enthusiastic about geography
- Provide accurate, educational information
- Use simple language appropriate for all ages
- Include interesting facts and cultural insights
- If asked about non-geography topics, gently redirect to geography
- Support both English and Arabic users
''');

    if (currentCountryName != null) {
      buffer.writeln(
        'The user is currently exploring: $currentCountryName ($currentCountryCode)',
      );
    }

    if (recentQuizTopics.isNotEmpty) {
      buffer.writeln(
        'Recent quiz topics: ${recentQuizTopics.join(", ")}',
      );
    }

    buffer.writeln('User level: $userLevel');

    if (userInterests.isNotEmpty) {
      buffer.writeln('User interests: ${userInterests.join(", ")}');
    }

    buffer.writeln('Preferred language: $preferredLanguage');

    return buffer.toString();
  }

  TutorContext copyWith({
    String? currentCountryCode,
    String? currentCountryName,
    List<String>? recentQuizTopics,
    int? userLevel,
    List<String>? userInterests,
    String? preferredLanguage,
  }) {
    return TutorContext(
      currentCountryCode: currentCountryCode ?? this.currentCountryCode,
      currentCountryName: currentCountryName ?? this.currentCountryName,
      recentQuizTopics: recentQuizTopics ?? this.recentQuizTopics,
      userLevel: userLevel ?? this.userLevel,
      userInterests: userInterests ?? this.userInterests,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}

/// Suggested prompts for AI tutor
class SuggestedPrompt {
  const SuggestedPrompt({
    required this.text,
    required this.textArabic,
    required this.category,
  });

  final String text;
  final String textArabic;
  final String category;

  String getDisplayText({required bool isArabic}) {
    return isArabic ? textArabic : text;
  }

  static const List<SuggestedPrompt> defaults = [
    SuggestedPrompt(
      text: 'Tell me an interesting fact about Japan',
      textArabic: 'أخبرني حقيقة مثيرة عن اليابان',
      category: 'facts',
    ),
    SuggestedPrompt(
      text: 'What are the top 5 most populous countries?',
      textArabic: 'ما هي أكثر 5 دول من حيث عدد السكان؟',
      category: 'rankings',
    ),
    SuggestedPrompt(
      text: 'Explain why Africa is called the cradle of humanity',
      textArabic: 'اشرح لماذا تسمى أفريقيا مهد البشرية',
      category: 'culture',
    ),
    SuggestedPrompt(
      text: 'What languages are spoken in Switzerland?',
      textArabic: 'ما هي اللغات المستخدمة في سويسرا؟',
      category: 'languages',
    ),
    SuggestedPrompt(
      text: 'Compare the geography of Norway and Chile',
      textArabic: 'قارن جغرافية النرويج وتشيلي',
      category: 'comparison',
    ),
  ];
}
