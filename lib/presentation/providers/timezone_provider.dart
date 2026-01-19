import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/service_locator.dart';
import '../../data/datasources/remote/timezone_datasource.dart';
import '../../domain/repositories/i_media_repository.dart';

/// Timezone info provider
final timezoneInfoProvider = FutureProvider.family<TimezoneInfo?, String>(
  (ref, timezone) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getTimezoneInfo(timezone);
    return result.fold(
      (_) => null,
      (info) => info,
    );
  },
);

/// Country time provider (based on timezone)
final countryTimeProvider = FutureProvider.family<TimezoneInfo?, String>(
  (ref, timezone) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getCountryTime(timezone);
    return result.fold(
      (_) => null,
      (info) => info,
    );
  },
);

/// Time difference provider
final timeDifferenceProvider = FutureProvider.family<Duration?, (String, String)>(
  (ref, params) async {
    final (fromTimezone, toTimezone) = params;
    final repository = sl<IMediaRepository>();

    final result = await repository.getTimeDifference(fromTimezone, toTimezone);
    return result.fold(
      (_) => null,
      (diff) => diff,
    );
  },
);

/// World clock state
class WorldClockState {
  const WorldClockState({
    this.localTime,
    this.targetTime,
    this.difference,
    this.isLoading = false,
  });

  final DateTime? localTime;
  final TimezoneInfo? targetTime;
  final Duration? difference;
  final bool isLoading;

  WorldClockState copyWith({
    DateTime? localTime,
    TimezoneInfo? targetTime,
    Duration? difference,
    bool? isLoading,
  }) {
    return WorldClockState(
      localTime: localTime ?? this.localTime,
      targetTime: targetTime ?? this.targetTime,
      difference: difference ?? this.difference,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Get formatted time difference string
  String get formattedDifference {
    if (difference == null) return '';

    final hours = difference!.inHours.abs();
    final minutes = difference!.inMinutes.abs() % 60;

    final sign = difference!.isNegative ? '-' : '+';

    if (minutes == 0) {
      return '$sign${hours}h';
    }
    return '$sign${hours}h ${minutes}m';
  }
}

/// World clock notifier
class WorldClockNotifier extends StateNotifier<WorldClockState> {
  WorldClockNotifier(this._repository) : super(const WorldClockState());

  final IMediaRepository _repository;
  Timer? _timer;

  /// Load time for a timezone
  Future<void> loadTime(String timezone) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.getTimezoneInfo(timezone);

    result.fold(
      (_) => state = state.copyWith(isLoading: false),
      (info) {
        state = state.copyWith(
          localTime: DateTime.now(),
          targetTime: info,
          difference: Duration(seconds: info.utcOffsetSeconds),
          isLoading: false,
        );
      },
    );

    // Start timer to update every second
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.targetTime != null) {
        state = state.copyWith(
          localTime: DateTime.now(),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// World clock provider
final worldClockProvider =
    StateNotifierProvider.family<WorldClockNotifier, WorldClockState, String>(
  (ref, timezone) {
    final repository = sl<IMediaRepository>();
    final notifier = WorldClockNotifier(repository);
    notifier.loadTime(timezone);
    return notifier;
  },
);

/// Current local time provider (updates every second)
final localTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});

/// Common timezones
final commonTimezonesProvider = Provider<List<String>>((ref) {
  return [
    'America/New_York',
    'America/Los_Angeles',
    'America/Chicago',
    'Europe/London',
    'Europe/Paris',
    'Europe/Berlin',
    'Asia/Tokyo',
    'Asia/Shanghai',
    'Asia/Dubai',
    'Asia/Kolkata',
    'Asia/Singapore',
    'Australia/Sydney',
    'Pacific/Auckland',
    'Africa/Cairo',
    'Africa/Johannesburg',
  ];
});

/// Get timezone display name
String getTimezoneDisplayName(String timezone) {
  // Extract city name from timezone string
  final parts = timezone.split('/');
  if (parts.length >= 2) {
    return parts.last.replaceAll('_', ' ');
  }
  return timezone;
}

/// Time of day category
enum TimeOfDay {
  morning,
  afternoon,
  evening,
  night,
}

/// Get time of day for a given hour
TimeOfDay getTimeOfDay(int hour) {
  if (hour >= 5 && hour < 12) return TimeOfDay.morning;
  if (hour >= 12 && hour < 17) return TimeOfDay.afternoon;
  if (hour >= 17 && hour < 21) return TimeOfDay.evening;
  return TimeOfDay.night;
}

/// Get greeting for time of day
String getGreetingForTimeOfDay(TimeOfDay tod, {bool isArabic = false}) {
  switch (tod) {
    case TimeOfDay.morning:
      return isArabic ? 'صباح الخير' : 'Good morning';
    case TimeOfDay.afternoon:
      return isArabic ? 'مساء الخير' : 'Good afternoon';
    case TimeOfDay.evening:
      return isArabic ? 'مساء الخير' : 'Good evening';
    case TimeOfDay.night:
      return isArabic ? 'مساء الخير' : 'Good night';
  }
}
