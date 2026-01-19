/// Input sanitization utilities for security
///
/// These utilities help prevent injection attacks, XSS,
/// and other security issues related to user input.
class InputSanitizer {
  InputSanitizer._();

  /// Maximum lengths for different input types
  static const int maxSearchQueryLength = 100;
  static const int maxMessageLength = 2000;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 254;

  /// Sanitize a search query for use in API calls
  ///
  /// - Trims whitespace
  /// - Limits length
  /// - Removes dangerous characters
  /// - URL encodes special characters
  static String sanitizeSearchQuery(String input) {
    if (input.isEmpty) return '';

    var sanitized = input
        .trim()
        // Remove null bytes and control characters
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        // Remove potential path traversal patterns
        .replaceAll(RegExp(r'\.\.+'), '.')
        .replaceAll(RegExp(r'[\/\\]+'), ' ')
        // Collapse multiple spaces
        .replaceAll(RegExp(r'\s+'), ' ');

    // Limit length
    if (sanitized.length > maxSearchQueryLength) {
      sanitized = sanitized.substring(0, maxSearchQueryLength);
    }

    return sanitized;
  }

  /// URL-encode a string for safe use in API paths
  static String urlEncode(String input) {
    return Uri.encodeComponent(input);
  }

  /// Sanitize user message for chat/AI interactions
  ///
  /// - Limits length
  /// - Removes control characters
  /// - Preserves newlines but removes excessive ones
  /// - Does NOT filter content (that's done by the AI service)
  static String sanitizeMessage(String input) {
    if (input.isEmpty) return '';

    var sanitized = input
        .trim()
        // Remove null bytes and most control characters (preserve newlines/tabs)
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        // Collapse multiple newlines
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        // Collapse multiple spaces (but not newlines)
        .replaceAll(RegExp(r'[^\S\n]+'), ' ');

    // Limit length
    if (sanitized.length > maxMessageLength) {
      sanitized = sanitized.substring(0, maxMessageLength);
    }

    return sanitized;
  }

  /// Sanitize display name for storage
  static String sanitizeDisplayName(String input) {
    if (input.isEmpty) return '';

    var sanitized = input
        .trim()
        // Remove all control characters
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        // Remove HTML-like tags
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Collapse multiple spaces
        .replaceAll(RegExp(r'\s+'), ' ');

    // Limit length
    if (sanitized.length > maxNameLength) {
      sanitized = sanitized.substring(0, maxNameLength);
    }

    return sanitized;
  }

  /// Sanitize email address
  static String sanitizeEmail(String input) {
    if (input.isEmpty) return '';

    var sanitized = input
        .trim()
        .toLowerCase()
        // Remove all control characters
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        // Remove spaces
        .replaceAll(RegExp(r'\s'), '');

    // Limit length (RFC 5321)
    if (sanitized.length > maxEmailLength) {
      sanitized = sanitized.substring(0, maxEmailLength);
    }

    return sanitized;
  }

  /// Sanitize for HTML display (prevent XSS)
  ///
  /// Use this when displaying user content that might contain HTML
  static String sanitizeForHtml(String input) {
    if (input.isEmpty) return '';

    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// Sanitize for SQL (basic protection)
  ///
  /// Note: Always use parameterized queries - this is just defense in depth
  static String sanitizeForSql(String input) {
    if (input.isEmpty) return '';

    return input
        .replaceAll("'", "''")
        .replaceAll(';', '')
        .replaceAll('--', '')
        .replaceAll('/*', '')
        .replaceAll('*/', '');
  }

  /// Check if input is within acceptable length
  static bool isValidLength(String input, int maxLength) {
    return input.length <= maxLength;
  }

  /// Check if input contains only safe characters for search
  static bool isSafeSearchInput(String input) {
    // Allow letters, numbers, spaces, and common punctuation
    final safePattern = RegExp(r'^[\w\s\-.,]+$', unicode: true);
    return safePattern.hasMatch(input);
  }

  /// Remove potential injection patterns from strings
  /// This is an aggressive sanitization for high-security contexts
  static String removeInjectionPatterns(String input) {
    if (input.isEmpty) return '';

    return input
        // Remove SQL injection patterns
        .replaceAll('--', '')
        .replaceAll(';', '')
        .replaceAll('/*', '')
        .replaceAll('*/', '')
        // Remove script tags
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '')
        // Remove event handlers
        .replaceAll(RegExp(r'on\w+=', caseSensitive: false), '')
        // Remove javascript: protocol
        .replaceAll(RegExp('javascript:', caseSensitive: false), '')
        // Remove data: URLs that could contain scripts
        .replaceAll(RegExp(r'data:text/html', caseSensitive: false), '')
        // Remove null bytes
        .replaceAll('\x00', '');
  }
}
