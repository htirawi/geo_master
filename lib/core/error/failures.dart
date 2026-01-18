/// Base class for all failures in the app.
/// Uses the Either pattern from dartz for functional error handling.
abstract class Failure {
  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final dynamic details;

  @override
  String toString() => 'Failure: $message (code: $code)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Network-related failures (no internet, timeout, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
    super.details,
  });

  factory NetworkFailure.noConnection() => const NetworkFailure(
        message: 'No internet connection. Please check your network.',
        code: 'NO_CONNECTION',
      );

  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'Connection timed out. Please try again.',
        code: 'TIMEOUT',
      );
}

/// Server-related failures (5xx errors, API errors)
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error. Please try again later.',
    super.code = 'SERVER_ERROR',
    this.statusCode,
    super.details,
  });

  factory ServerFailure.internal() => const ServerFailure(
        message: 'Internal server error. Please try again later.',
        code: 'INTERNAL_ERROR',
        statusCode: 500,
      );

  factory ServerFailure.serviceUnavailable() => const ServerFailure(
        message: 'Service temporarily unavailable.',
        code: 'SERVICE_UNAVAILABLE',
        statusCode: 503,
      );

  factory ServerFailure.badRequest(String? details) => ServerFailure(
        message: details ?? 'Invalid request.',
        code: 'BAD_REQUEST',
        statusCode: 400,
      );

  final int? statusCode;
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed. Please sign in again.',
    super.code = 'AUTH_ERROR',
    super.details,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid email or password.',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'No account found with this email.',
        code: 'USER_NOT_FOUND',
      );

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
        message: 'An account with this email already exists.',
        code: 'EMAIL_ALREADY_IN_USE',
      );

  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password is too weak. Please use a stronger password.',
        code: 'WEAK_PASSWORD',
      );

  factory AuthFailure.userDisabled() => const AuthFailure(
        message: 'This account has been disabled.',
        code: 'USER_DISABLED',
      );

  factory AuthFailure.tooManyRequests() => const AuthFailure(
        message: 'Too many attempts. Please try again later.',
        code: 'TOO_MANY_REQUESTS',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Your session has expired. Please sign in again.',
        code: 'SESSION_EXPIRED',
      );

  factory AuthFailure.googleSignInCancelled() => const AuthFailure(
        message: 'Google sign in was cancelled.',
        code: 'GOOGLE_SIGN_IN_CANCELLED',
      );

  factory AuthFailure.appleSignInCancelled() => const AuthFailure(
        message: 'Apple sign in was cancelled.',
        code: 'APPLE_SIGN_IN_CANCELLED',
      );

  factory AuthFailure.appleSignInNotAvailable() => const AuthFailure(
        message: 'Apple sign in is not available on this device.',
        code: 'APPLE_SIGN_IN_NOT_AVAILABLE',
      );
}

/// Cache/storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load cached data.',
    super.code = 'CACHE_ERROR',
    super.details,
  });

  factory CacheFailure.notFound() => const CacheFailure(
        message: 'No cached data found.',
        code: 'CACHE_NOT_FOUND',
      );

  factory CacheFailure.expired() => const CacheFailure(
        message: 'Cached data has expired.',
        code: 'CACHE_EXPIRED',
      );

  factory CacheFailure.writeError() => const CacheFailure(
        message: 'Failed to save data to cache.',
        code: 'CACHE_WRITE_ERROR',
      );
}

/// Quiz-specific failures
class QuizFailure extends Failure {
  const QuizFailure({
    super.message = 'An error occurred during the quiz.',
    super.code = 'QUIZ_ERROR',
    super.details,
  });

  factory QuizFailure.noQuestionsAvailable() => const QuizFailure(
        message: 'No questions available for this selection.',
        code: 'NO_QUESTIONS',
      );

  factory QuizFailure.invalidAnswer() => const QuizFailure(
        message: 'Invalid answer submitted.',
        code: 'INVALID_ANSWER',
      );

  factory QuizFailure.quizAlreadyCompleted() => const QuizFailure(
        message: 'This quiz has already been completed.',
        code: 'QUIZ_COMPLETED',
      );

  factory QuizFailure.timeExpired() => const QuizFailure(
        message: 'Time has expired for this quiz.',
        code: 'TIME_EXPIRED',
      );
}

/// Country data failures
class CountryFailure extends Failure {
  const CountryFailure({
    super.message = 'Failed to load country data.',
    super.code = 'COUNTRY_ERROR',
    super.details,
  });

  factory CountryFailure.notFound(String countryCode) => CountryFailure(
        message: 'Country not found: $countryCode',
        code: 'COUNTRY_NOT_FOUND',
      );

  factory CountryFailure.apiError() => const CountryFailure(
        message: 'Failed to fetch country data from API.',
        code: 'COUNTRY_API_ERROR',
      );
}

/// AI Tutor failures
class AiTutorFailure extends Failure {
  const AiTutorFailure({
    super.message = 'AI tutor is temporarily unavailable.',
    super.code = 'AI_TUTOR_ERROR',
    super.details,
  });

  factory AiTutorFailure.rateLimited() => const AiTutorFailure(
        message: 'Too many messages. Please wait a moment.',
        code: 'RATE_LIMITED',
      );

  factory AiTutorFailure.contextTooLong() => const AiTutorFailure(
        message: 'Conversation is too long. Please start a new chat.',
        code: 'CONTEXT_TOO_LONG',
      );

  factory AiTutorFailure.apiKeyInvalid() => const AiTutorFailure(
        message: 'AI service configuration error.',
        code: 'API_KEY_INVALID',
      );

  factory AiTutorFailure.streamingError() => const AiTutorFailure(
        message: 'Error receiving AI response.',
        code: 'STREAMING_ERROR',
      );

  factory AiTutorFailure.messageLimitReached() => const AiTutorFailure(
        message: 'Daily message limit reached. Upgrade for unlimited chat.',
        code: 'MESSAGE_LIMIT_REACHED',
      );
}

/// Purchase failures
class PurchaseFailure extends Failure {
  const PurchaseFailure({
    super.message = 'Purchase failed. Please try again.',
    super.code = 'PURCHASE_ERROR',
    super.details,
  });

  factory PurchaseFailure.cancelled() => const PurchaseFailure(
        message: 'Purchase was cancelled.',
        code: 'PURCHASE_CANCELLED',
      );

  factory PurchaseFailure.paymentDeclined() => const PurchaseFailure(
        message: 'Payment was declined.',
        code: 'PAYMENT_DECLINED',
      );

  factory PurchaseFailure.productNotFound() => const PurchaseFailure(
        message: 'Product not found.',
        code: 'PRODUCT_NOT_FOUND',
      );

  factory PurchaseFailure.alreadyPurchased() => const PurchaseFailure(
        message: 'You have already purchased this item.',
        code: 'ALREADY_PURCHASED',
      );

  factory PurchaseFailure.restoreFailed() => const PurchaseFailure(
        message: 'Failed to restore purchases.',
        code: 'RESTORE_FAILED',
      );
}

/// Subscription failures
class SubscriptionFailure extends Failure {
  const SubscriptionFailure({
    super.message = 'Subscription error occurred.',
    super.code = 'SUBSCRIPTION_ERROR',
    super.details,
  });

  factory SubscriptionFailure.offeringsNotAvailable() => const SubscriptionFailure(
        message: 'Subscription options are not available.',
        code: 'OFFERINGS_NOT_AVAILABLE',
      );

  factory SubscriptionFailure.purchaseFailed() => const SubscriptionFailure(
        message: 'Failed to complete purchase.',
        code: 'PURCHASE_FAILED',
      );

  factory SubscriptionFailure.purchaseCancelled() => const SubscriptionFailure(
        message: 'Purchase was cancelled.',
        code: 'PURCHASE_CANCELLED',
      );

  factory SubscriptionFailure.notSubscribed() => const SubscriptionFailure(
        message: 'No active subscription found.',
        code: 'NOT_SUBSCRIBED',
      );

  factory SubscriptionFailure.syncFailed() => const SubscriptionFailure(
        message: 'Failed to sync subscription status.',
        code: 'SYNC_FAILED',
      );

  factory SubscriptionFailure.featureNotAvailable() => const SubscriptionFailure(
        message: 'This feature requires a premium subscription.',
        code: 'FEATURE_NOT_AVAILABLE',
      );
}

/// Gamification failures
class GamificationFailure extends Failure {
  const GamificationFailure({
    super.message = 'An error occurred with the gamification system.',
    super.code = 'GAMIFICATION_ERROR',
    super.details,
  });

  factory GamificationFailure.achievementNotFound() => const GamificationFailure(
        message: 'Achievement not found.',
        code: 'ACHIEVEMENT_NOT_FOUND',
      );

  factory GamificationFailure.leaderboardError() => const GamificationFailure(
        message: 'Failed to load leaderboard.',
        code: 'LEADERBOARD_ERROR',
      );
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation failed.',
    super.code = 'VALIDATION_ERROR',
    super.details,
  });

  factory ValidationFailure.invalidEmail() => const ValidationFailure(
        message: 'Please enter a valid email address.',
        code: 'INVALID_EMAIL',
      );

  factory ValidationFailure.invalidPassword() => const ValidationFailure(
        message: 'Password must be at least 8 characters.',
        code: 'INVALID_PASSWORD',
      );

  factory ValidationFailure.invalidUsername() => const ValidationFailure(
        message: 'Username must be 3-20 characters.',
        code: 'INVALID_USERNAME',
      );
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNKNOWN_ERROR',
    super.details,
  });
}
