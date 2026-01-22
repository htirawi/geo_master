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
  /// Use this when displaying user content that might contain HTML.
  /// This provides comprehensive XSS protection by encoding all potentially
  /// dangerous characters and removing event handlers.
  static String sanitizeForHtml(String input) {
    if (input.isEmpty) return '';

    var sanitized = input
        // First, encode the main special characters
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;')
        .replaceAll('`', '&#x60;')
        .replaceAll('=', '&#x3D;');

    // Remove null bytes and other dangerous characters
    sanitized = sanitized.replaceAll(RegExp(r'[\x00]'), '');

    // Remove Unicode direction override characters (used in visual attacks)
    sanitized = sanitized.replaceAll(
      RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060-\u206F]'),
      '',
    );

    return sanitized;
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
  /// This is an aggressive sanitization for high-security contexts.
  /// Use this as defense-in-depth, not as the primary security measure.
  static String removeInjectionPatterns(String input) {
    if (input.isEmpty) return '';

    var sanitized = input;

    // Remove null bytes and control characters first
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // Remove Unicode special characters used in attacks
    sanitized = sanitized.replaceAll(
      RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060-\u206F\uFEFF]'),
      '',
    );

    // SQL injection patterns
    sanitized = sanitized
        .replaceAll('--', '')
        .replaceAll(';', '')
        .replaceAll('/*', '')
        .replaceAll('*/', '')
        .replaceAll(RegExp(r"'\s*or\s*'", caseSensitive: false), '')
        .replaceAll(RegExp(r"'\s*and\s*'", caseSensitive: false), '')
        .replaceAll(RegExp(r'union\s+select', caseSensitive: false), '')
        .replaceAll(RegExp(r'drop\s+table', caseSensitive: false), '')
        .replaceAll(RegExp(r'insert\s+into', caseSensitive: false), '')
        .replaceAll(RegExp(r'delete\s+from', caseSensitive: false), '');

    // XSS patterns - comprehensive HTML/JavaScript removal
    // Script tags (including variations)
    sanitized = sanitized.replaceAll(
      RegExp(r'<\s*script[^>]*>.*?<\s*/\s*script\s*>', caseSensitive: false, dotAll: true),
      '',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'<\s*script[^>]*/?>', caseSensitive: false),
      '',
    );

    // Event handlers (on*)
    sanitized = sanitized.replaceAll(
      RegExp(r'\bon\w+\s*=\s*["\x27]?[^"\x27>\s]*["\x27]?', caseSensitive: false),
      '',
    );

    // JavaScript protocol (including encoded versions)
    sanitized = sanitized.replaceAll(
      RegExp(r'javascript\s*:', caseSensitive: false),
      '',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:', caseSensitive: false),
      '',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'&#\d+;?', caseSensitive: false), // HTML entities that could spell javascript
      '',
    );

    // VBScript protocol
    sanitized = sanitized.replaceAll(
      RegExp(r'vbscript\s*:', caseSensitive: false),
      '',
    );

    // Data URLs that could contain scripts
    sanitized = sanitized.replaceAll(
      RegExp(r'data\s*:\s*text/html', caseSensitive: false),
      '',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'data\s*:\s*[^;,]*;base64', caseSensitive: false),
      '',
    );

    // Style expressions (IE)
    sanitized = sanitized.replaceAll(
      RegExp(r'expression\s*\(', caseSensitive: false),
      '',
    );

    // iframe, object, embed, form tags
    sanitized = sanitized.replaceAll(
      RegExp(r'<\s*(iframe|object|embed|form|meta|link)[^>]*>?', caseSensitive: false),
      '',
    );

    // SVG with scripts
    sanitized = sanitized.replaceAll(
      RegExp(r'<\s*svg[^>]*>.*?<\s*/\s*svg\s*>', caseSensitive: false, dotAll: true),
      '',
    );

    // img onerror, body onload, etc. (additional catch)
    sanitized = sanitized.replaceAll(
      RegExp(r'<[^>]+\s+on\w+\s*=', caseSensitive: false),
      '<',
    );

    return sanitized;
  }

  /// Sanitize a string for use in URLs (path segments)
  /// Prevents path traversal and injection attacks
  static String sanitizeForUrlPath(String input) {
    if (input.isEmpty) return '';

    return input
        // Remove path traversal attempts
        .replaceAll(RegExp(r'\.\.+'), '')
        .replaceAll(RegExp(r'[\/\\]+'), '')
        // Remove null bytes
        .replaceAll('\x00', '')
        // Remove query string characters
        .replaceAll('?', '')
        .replaceAll('#', '')
        .replaceAll('&', '')
        // URL encode the result
        .split('')
        .map((c) {
          // Allow alphanumeric, hyphen, underscore, dot
          if (RegExp(r'[a-zA-Z0-9\-_.]').hasMatch(c)) {
            return c;
          }
          return Uri.encodeComponent(c);
        })
        .join();
  }

  /// Validate and sanitize a file name
  /// Prevents path traversal and special character issues
  static String sanitizeFileName(String input) {
    if (input.isEmpty) return 'unnamed';

    var sanitized = input
        // Remove path separators
        .replaceAll(RegExp(r'[\/\\]'), '')
        // Remove path traversal
        .replaceAll(RegExp(r'\.\.+'), '')
        // Remove null bytes and control characters
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        // Remove potentially dangerous characters
        .replaceAll(RegExp(r'[<>:"|?*]'), '')
        .trim();

    // Limit length
    if (sanitized.length > 255) {
      sanitized = sanitized.substring(0, 255);
    }

    // Ensure it's not empty after sanitization
    if (sanitized.isEmpty) {
      return 'unnamed';
    }

    return sanitized;
  }
}
