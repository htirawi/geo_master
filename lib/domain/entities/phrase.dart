import 'package:flutter/foundation.dart';

/// Essential phrase entity with audio support
@immutable
class Phrase {
  const Phrase({
    required this.id,
    required this.countryCode,
    required this.languageCode,
    required this.category,
    required this.original,
    required this.transliteration,
    required this.englishTranslation,
    this.arabicTranslation,
    this.audioUrl,
    this.pronunciation,
    this.usageNotes,
    this.usageNotesArabic,
    this.isFormal = false,
    this.difficulty = PhraseDifficulty.beginner,
  });

  final String id;
  final String countryCode;
  final String languageCode; // e.g., "ja" for Japanese, "fr" for French
  final PhraseCategory category;
  final String original; // Phrase in original language/script
  final String transliteration; // Latin alphabet pronunciation
  final String englishTranslation;
  final String? arabicTranslation;
  final String? audioUrl;
  final String? pronunciation; // IPA or simplified pronunciation guide
  final String? usageNotes;
  final String? usageNotesArabic;
  final bool isFormal;
  final PhraseDifficulty difficulty;

  /// Get translation based on locale
  String getTranslation({required bool isArabic}) {
    return isArabic ? (arabicTranslation ?? englishTranslation) : englishTranslation;
  }

  /// Get usage notes based on locale
  String? getUsageNotes({required bool isArabic}) {
    return isArabic ? usageNotesArabic : usageNotes;
  }

  /// Check if phrase has audio
  bool get hasAudio => audioUrl != null;

  Phrase copyWith({
    String? id,
    String? countryCode,
    String? languageCode,
    PhraseCategory? category,
    String? original,
    String? transliteration,
    String? englishTranslation,
    String? arabicTranslation,
    String? audioUrl,
    String? pronunciation,
    String? usageNotes,
    String? usageNotesArabic,
    bool? isFormal,
    PhraseDifficulty? difficulty,
  }) {
    return Phrase(
      id: id ?? this.id,
      countryCode: countryCode ?? this.countryCode,
      languageCode: languageCode ?? this.languageCode,
      category: category ?? this.category,
      original: original ?? this.original,
      transliteration: transliteration ?? this.transliteration,
      englishTranslation: englishTranslation ?? this.englishTranslation,
      arabicTranslation: arabicTranslation ?? this.arabicTranslation,
      audioUrl: audioUrl ?? this.audioUrl,
      pronunciation: pronunciation ?? this.pronunciation,
      usageNotes: usageNotes ?? this.usageNotes,
      usageNotesArabic: usageNotesArabic ?? this.usageNotesArabic,
      isFormal: isFormal ?? this.isFormal,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Phrase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Phrase category enum
enum PhraseCategory {
  greetings,
  basics,
  numbers,
  directions,
  food,
  shopping,
  transportation,
  emergency,
  accommodation,
  socializing,
  business,
  customs;

  String get displayName {
    switch (this) {
      case PhraseCategory.greetings:
        return 'Greetings';
      case PhraseCategory.basics:
        return 'Basics';
      case PhraseCategory.numbers:
        return 'Numbers';
      case PhraseCategory.directions:
        return 'Directions';
      case PhraseCategory.food:
        return 'Food & Dining';
      case PhraseCategory.shopping:
        return 'Shopping';
      case PhraseCategory.transportation:
        return 'Transportation';
      case PhraseCategory.emergency:
        return 'Emergency';
      case PhraseCategory.accommodation:
        return 'Accommodation';
      case PhraseCategory.socializing:
        return 'Socializing';
      case PhraseCategory.business:
        return 'Business';
      case PhraseCategory.customs:
        return 'Customs & Culture';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case PhraseCategory.greetings:
        return 'التحيات';
      case PhraseCategory.basics:
        return 'الأساسيات';
      case PhraseCategory.numbers:
        return 'الأرقام';
      case PhraseCategory.directions:
        return 'الاتجاهات';
      case PhraseCategory.food:
        return 'الطعام';
      case PhraseCategory.shopping:
        return 'التسوق';
      case PhraseCategory.transportation:
        return 'المواصلات';
      case PhraseCategory.emergency:
        return 'الطوارئ';
      case PhraseCategory.accommodation:
        return 'الإقامة';
      case PhraseCategory.socializing:
        return 'التواصل';
      case PhraseCategory.business:
        return 'الأعمال';
      case PhraseCategory.customs:
        return 'العادات والثقافة';
    }
  }

  /// Get icon name for this category
  String get iconName {
    switch (this) {
      case PhraseCategory.greetings:
        return 'waving_hand';
      case PhraseCategory.basics:
        return 'abc';
      case PhraseCategory.numbers:
        return 'pin';
      case PhraseCategory.directions:
        return 'directions';
      case PhraseCategory.food:
        return 'restaurant';
      case PhraseCategory.shopping:
        return 'shopping_bag';
      case PhraseCategory.transportation:
        return 'directions_bus';
      case PhraseCategory.emergency:
        return 'emergency';
      case PhraseCategory.accommodation:
        return 'hotel';
      case PhraseCategory.socializing:
        return 'groups';
      case PhraseCategory.business:
        return 'business_center';
      case PhraseCategory.customs:
        return 'diversity_3';
    }
  }
}

/// Phrase difficulty level
enum PhraseDifficulty {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case PhraseDifficulty.beginner:
        return 'Beginner';
      case PhraseDifficulty.intermediate:
        return 'Intermediate';
      case PhraseDifficulty.advanced:
        return 'Advanced';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case PhraseDifficulty.beginner:
        return 'مبتدئ';
      case PhraseDifficulty.intermediate:
        return 'متوسط';
      case PhraseDifficulty.advanced:
        return 'متقدم';
    }
  }
}
