import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Atlas mascot states
enum AtlasState {
  idle,
  wave,
  celebrate,
  thinking,
  encourage,
  sleeping,
}

/// Atlas mood based on user performance
enum AtlasMood {
  happy, // Good performance
  excited, // Great performance
  thoughtful, // Learning mode
  encouraging, // After mistakes
  proud, // Achievements
}

/// Atlas mascot state notifier
class AtlasStateNotifier extends StateNotifier<AtlasState> {
  AtlasStateNotifier() : super(AtlasState.idle);

  /// Set Atlas to wave (greeting)
  void wave() {
    state = AtlasState.wave;
    _resetAfterDelay();
  }

  /// Set Atlas to celebrate
  void celebrate() {
    state = AtlasState.celebrate;
    _resetAfterDelay(duration: const Duration(seconds: 3));
  }

  /// Set Atlas to thinking
  void think() {
    state = AtlasState.thinking;
  }

  /// Set Atlas to encourage
  void encourage() {
    state = AtlasState.encourage;
    _resetAfterDelay();
  }

  /// Set Atlas to idle
  void idle() {
    state = AtlasState.idle;
  }

  /// Set Atlas to sleeping
  void sleep() {
    state = AtlasState.sleeping;
  }

  /// Reset to idle after a delay
  void _resetAfterDelay({Duration duration = const Duration(seconds: 2)}) {
    Future.delayed(duration, () {
      if (mounted) {
        state = AtlasState.idle;
      }
    });
  }
}

/// Atlas state provider
final atlasStateProvider =
    StateNotifierProvider<AtlasStateNotifier, AtlasState>((ref) {
  return AtlasStateNotifier();
});

/// Atlas mood based on recent user activity
final atlasMoodProvider = Provider<AtlasMood>((ref) {
  // This could be enhanced to track actual user performance
  return AtlasMood.happy;
});

/// Atlas greeting messages
class AtlasGreetings {
  static const Map<String, List<String>> _greetingsEn = {
    'morning': [
      'Good morning, explorer!',
      'Ready for a new adventure?',
      "Let's discover something new today!",
    ],
    'afternoon': [
      'Good afternoon! Time to explore!',
      'Adventure awaits, explorer!',
      "Let's learn about the world!",
    ],
    'evening': [
      'Good evening, traveler!',
      'Perfect time for a geography adventure!',
      "Let's explore before the day ends!",
    ],
    'quiz_start': [
      "You've got this!",
      "Show me what you've learned!",
      'Ready, set, explore!',
    ],
    'quiz_correct': [
      'Excellent!',
      "You're amazing!",
      'Perfect!',
      "That's right!",
    ],
    'quiz_incorrect': [
      "Don't worry, you'll get it next time!",
      'Learning is a journey!',
      "Keep going, you're doing great!",
    ],
    'achievement': [
      'You earned it! Congratulations!',
      'What an achievement!',
      "You're making great progress!",
    ],
    'streak': [
      'Your dedication is inspiring!',
      'Keep the streak alive!',
      'Consistency is key!',
    ],
    'level_up': [
      "You've leveled up! Amazing!",
      'A new explorer rank! Well done!',
      'Your knowledge is growing!',
    ],
  };

  static const Map<String, List<String>> _greetingsAr = {
    'morning': [
      'صباح الخير يا مستكشف!',
      'مستعد لمغامرة جديدة؟',
      'هيا نكتشف شيئًا جديدًا اليوم!',
    ],
    'afternoon': [
      'مساء الخير! وقت الاستكشاف!',
      'المغامرة في انتظارك!',
      'هيا نتعلم عن العالم!',
    ],
    'evening': [
      'مساء الخير يا رحّال!',
      'وقت مثالي لمغامرة جغرافية!',
      'هيا نستكشف قبل نهاية اليوم!',
    ],
    'quiz_start': [
      'يمكنك فعلها!',
      'أرني ما تعلمته!',
      'جاهز، انطلق، استكشف!',
    ],
    'quiz_correct': [
      'ممتاز!',
      'أنت رائع!',
      'مثالي!',
      'هذا صحيح!',
    ],
    'quiz_incorrect': [
      'لا تقلق، ستحصل عليها في المرة القادمة!',
      'التعلم رحلة!',
      'استمر، أنت تبلي بلاءً حسنًا!',
    ],
    'achievement': [
      'لقد استحققته! تهانينا!',
      'يا لهذا الإنجاز!',
      'أنت تحرز تقدمًا رائعًا!',
    ],
    'streak': [
      'تفانيك ملهم!',
      'حافظ على السلسلة!',
      'الاستمرارية هي المفتاح!',
    ],
    'level_up': [
      'لقد ارتقيت! مذهل!',
      'رتبة مستكشف جديدة! أحسنت!',
      'معرفتك تنمو!',
    ],
  };

  /// Get a random greeting for the given context
  static String getGreeting({
    required String context,
    required bool isArabic,
  }) {
    final greetings = isArabic ? _greetingsAr : _greetingsEn;
    final contextGreetings = greetings[context] ?? greetings['morning']!;
    return contextGreetings[DateTime.now().millisecond % contextGreetings.length];
  }

  /// Get time-based greeting
  static String getTimeBasedGreeting({required bool isArabic}) {
    final hour = DateTime.now().hour;
    String context;
    if (hour < 12) {
      context = 'morning';
    } else if (hour < 17) {
      context = 'afternoon';
    } else {
      context = 'evening';
    }
    return getGreeting(context: context, isArabic: isArabic);
  }
}
