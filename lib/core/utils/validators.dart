/// Centralized input validators for the app
class Validators {
  Validators._();

  /// Email validation regex
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Password requirements
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  /// Username requirements
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  /// Validate email format
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return ValidationResult.invalid('Email is required');
    }

    final trimmed = email.trim().toLowerCase();

    if (trimmed.length > 254) {
      return ValidationResult.invalid('Email is too long');
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      return ValidationResult.invalid('Please enter a valid email address');
    }

    return ValidationResult.valid();
  }

  /// Validate password strength
  static ValidationResult validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationResult.invalid('Password is required');
    }

    if (password.length < minPasswordLength) {
      return ValidationResult.invalid(
        'Password must be at least $minPasswordLength characters',
      );
    }

    if (password.length > maxPasswordLength) {
      return ValidationResult.invalid('Password is too long');
    }

    // Check for at least one letter and one number
    final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    if (!hasLetter || !hasNumber) {
      return ValidationResult.invalid(
        'Password must contain at least one letter and one number',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate password for sign-in (less strict - just check not empty)
  static ValidationResult validatePasswordForSignIn(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationResult.invalid('Password is required');
    }

    if (password.length < 6) {
      return ValidationResult.invalid('Password is too short');
    }

    return ValidationResult.valid();
  }

  /// Validate username
  static ValidationResult validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return ValidationResult.invalid('Username is required');
    }

    final trimmed = username.trim();

    if (trimmed.length < minUsernameLength) {
      return ValidationResult.invalid(
        'Username must be at least $minUsernameLength characters',
      );
    }

    if (trimmed.length > maxUsernameLength) {
      return ValidationResult.invalid(
        'Username must be at most $maxUsernameLength characters',
      );
    }

    // Only allow alphanumeric and underscore
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
      return ValidationResult.invalid(
        'Username can only contain letters, numbers, and underscores',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate display name (more lenient than username)
  static ValidationResult validateDisplayName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult.valid(); // Display name is optional
    }

    final trimmed = name.trim();

    if (trimmed.length > 50) {
      return ValidationResult.invalid('Name is too long');
    }

    // Check for obviously invalid characters
    if (trimmed.contains(RegExp(r'[<>{}\\]'))) {
      return ValidationResult.invalid('Name contains invalid characters');
    }

    return ValidationResult.valid();
  }

  /// Sanitize email (trim, lowercase)
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Sanitize display name
  static String sanitizeDisplayName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

/// Result of a validation check
class ValidationResult {
  const ValidationResult._({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() => const ValidationResult._(isValid: true);

  factory ValidationResult.invalid(String message) => ValidationResult._(
        isValid: false,
        errorMessage: message,
      );

  final bool isValid;
  final String? errorMessage;
}
