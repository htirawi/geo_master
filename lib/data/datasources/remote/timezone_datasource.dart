import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';

/// Timezone API data source interface
abstract class ITimezoneDataSource {
  /// Get current time for a timezone
  Future<TimezoneInfo> getTimezone(String timezone);

  /// Get timezone by coordinates
  Future<TimezoneInfo> getTimezoneByCoordinates(double lat, double lon);

  /// Get list of available timezones
  Future<List<String>> getAvailableTimezones();

  /// Get time difference between two timezones
  Future<Duration> getTimeDifference(String fromTimezone, String toTimezone);
}

/// WorldTime API data source implementation
class TimezoneDataSource implements ITimezoneDataSource {
  TimezoneDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<TimezoneInfo> getTimezone(String timezone) async {
    try {
      // Format timezone for API (e.g., "America/New_York")
      final formattedTimezone = timezone.replaceAll(' ', '_');

      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.worldTimeTimezone}/$formattedTimezone',
      );

      if (response.statusCode == 200 && response.data != null) {
        return TimezoneInfo.fromJson(response.data!);
      }

      throw ServerException(
        message: 'Failed to fetch timezone data',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Timezone API error');
    }
  }

  @override
  Future<TimezoneInfo> getTimezoneByCoordinates(double lat, double lon) async {
    // WorldTimeAPI doesn't support coordinates directly
    // We'll use the IP endpoint as a fallback or return based on the offset
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.worldTimeIp,
      );

      if (response.statusCode == 200 && response.data != null) {
        return TimezoneInfo.fromJson(response.data!);
      }

      throw ServerException(
        message: 'Failed to fetch timezone by location',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Timezone API error');
    }
  }

  @override
  Future<List<String>> getAvailableTimezones() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiEndpoints.worldTimeTimezone,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!.map((e) => e.toString()).toList();
      }

      throw ServerException(
        message: 'Failed to fetch timezone list',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Timezone API error');
    }
  }

  @override
  Future<Duration> getTimeDifference(String fromTimezone, String toTimezone) async {
    final fromInfo = await getTimezone(fromTimezone);
    final toInfo = await getTimezone(toTimezone);

    // Calculate difference in seconds
    final fromOffset = fromInfo.utcOffsetSeconds;
    final toOffset = toInfo.utcOffsetSeconds;

    return Duration(seconds: toOffset - fromOffset);
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return const ServerException(
            message: 'Timezone not found',
            code: 'TIMEZONE_NOT_FOUND',
            statusCode: 404,
          );
        }
        return ServerException(
          message: 'Timezone server error',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: e.message ?? 'Timezone API error',
        );
    }
  }
}

/// Timezone information model
class TimezoneInfo {
  const TimezoneInfo({
    required this.timezone,
    required this.datetime,
    required this.utcOffset,
    required this.utcOffsetSeconds,
    this.abbreviation,
    this.dayOfWeek,
    this.dayOfYear,
    this.weekNumber,
    this.isDst = false,
  });

  factory TimezoneInfo.fromJson(Map<String, dynamic> json) {
    // Parse UTC offset string (e.g., "+05:30") to seconds
    int parseOffsetToSeconds(String? offset) {
      if (offset == null || offset.isEmpty) return 0;

      final isNegative = offset.startsWith('-');
      final cleanOffset = offset.replaceAll(RegExp(r'[+-]'), '');
      final parts = cleanOffset.split(':');

      if (parts.isEmpty) return 0;

      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      final totalSeconds = (hours * 3600) + (minutes * 60);
      return isNegative ? -totalSeconds : totalSeconds;
    }

    final utcOffset = json['utc_offset'] as String? ?? '+00:00';

    return TimezoneInfo(
      timezone: json['timezone'] as String? ?? '',
      datetime: DateTime.tryParse(json['datetime'] as String? ?? '') ?? DateTime.now(),
      utcOffset: utcOffset,
      utcOffsetSeconds: parseOffsetToSeconds(utcOffset),
      abbreviation: json['abbreviation'] as String?,
      dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
      dayOfYear: (json['day_of_year'] as num?)?.toInt(),
      weekNumber: (json['week_number'] as num?)?.toInt(),
      isDst: json['dst'] as bool? ?? false,
    );
  }

  final String timezone;
  final DateTime datetime;
  final String utcOffset;
  final int utcOffsetSeconds;
  final String? abbreviation;
  final int? dayOfWeek;
  final int? dayOfYear;
  final int? weekNumber;
  final bool isDst;

  Map<String, dynamic> toJson() {
    return {
      'timezone': timezone,
      'datetime': datetime.toIso8601String(),
      'utc_offset': utcOffset,
      'abbreviation': abbreviation,
      'day_of_week': dayOfWeek,
      'day_of_year': dayOfYear,
      'week_number': weekNumber,
      'dst': isDst,
    };
  }

  /// Get formatted time (HH:mm)
  String get formattedTime {
    return '${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted date (MMM dd, yyyy)
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[datetime.month - 1]} ${datetime.day}, ${datetime.year}';
  }

  /// Get formatted UTC offset (e.g., "UTC+5:30")
  String get formattedUtcOffset {
    return 'UTC$utcOffset';
  }
}
