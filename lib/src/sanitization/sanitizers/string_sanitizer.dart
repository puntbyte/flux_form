// lib/src/sanitization/sanitizers/string_sanitizer.dart

import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/validation/validators/string_validator.dart';

/// A namespace for [String] transformation rules.
abstract class StringSanitizer extends Sanitizer<String> {
  const StringSanitizer();

  // ── Whitespace ────────────────────────────────────────────

  /// Removes leading and trailing whitespace.
  const factory StringSanitizer.trim() = _TrimSanitizer;

  /// Collapses every run of internal whitespace to a single space, then trims.
  ///
  /// `"  John   Doe  "` → `"John Doe"`.
  ///
  /// Useful for name fields where extra spaces should be normalised before
  /// storage without losing the single separator between words.
  const factory StringSanitizer.collapseWhitespace() = _CollapseWhitespaceSanitizer;

  /// Removes all whitespace characters (including internal spaces).
  ///
  /// Useful for credit card numbers, phone numbers, or any field where spaces
  /// should be stripped entirely before processing.
  const factory StringSanitizer.removeSpaces() = _RemoveSpaceSanitizer;

  // ── Case ──────────────────────────────────────────────────

  const factory StringSanitizer.toLowerCase() = _ToLowerCaseSanitizer;

  const factory StringSanitizer.toUpperCase() = _ToUpperCaseSanitizer;

  /// Capitalises the first character and lower-cases the rest.
  ///
  /// `"jOHN"` → `"John"`.
  const factory StringSanitizer.capitalize() = _CapitalizeSanitizer;

  // ── Content transformation ────────────────────────────────

  /// Removes all non-digit characters.
  ///
  /// `"(123) 456-7890"` → `"1234567890"`.
  const factory StringSanitizer.digitsOnly() = _DigitsOnlySanitizer;

  /// Replaces every occurrence of [pattern] with [replacement].
  ///
  /// [pattern] can be a [String] for literal replacement or a [RegExp]
  /// for pattern-based replacement.
  ///
  /// Not `const` because [Pattern] is an interface.
  ///
  /// Examples:
  /// ```dart
  /// // Remove all hyphens: "123-456-789" → "123456789"
  /// StringSanitizer.replace('-', '')
  ///
  /// // Replace multiple spaces with a single one:
  /// StringSanitizer.replace(RegExp(r'\s+'), ' ')
  /// ```
  const factory StringSanitizer.replace(Pattern pattern, String replacement) = _ReplaceSanitizer;

  /// Truncates the string to at most [maxLength] characters.
  ///
  /// Returns the string unchanged when its length is already within bounds.
  /// No ellipsis is added — this is a silent cap for storage/display limits,
  /// not a user-facing formatting tool.
  ///
  /// Pair with [StringValidator.maxLength] when you want to report an error
  /// to the user instead of silently truncating.
  const factory StringSanitizer.truncate(int maxLength) = _TruncateSanitizer;
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementations
// ─────────────────────────────────────────────────────────────────────────────

class _TrimSanitizer extends StringSanitizer {
  const _TrimSanitizer();

  @override
  String sanitize(String value) => value.trim();
}

class _CollapseWhitespaceSanitizer extends StringSanitizer {
  static final RegExp _runs = RegExp(r'\s+');

  const _CollapseWhitespaceSanitizer();

  @override
  String sanitize(String value) => value.trim().replaceAll(_runs, ' ');
}

class _RemoveSpaceSanitizer extends StringSanitizer {
  const _RemoveSpaceSanitizer();

  @override
  String sanitize(String value) => value.replaceAll(RegExp(r'\s+'), '');
}

class _ToLowerCaseSanitizer extends StringSanitizer {
  const _ToLowerCaseSanitizer();

  @override
  String sanitize(String value) => value.toLowerCase();
}

class _ToUpperCaseSanitizer extends StringSanitizer {
  const _ToUpperCaseSanitizer();

  @override
  String sanitize(String value) => value.toUpperCase();
}

class _CapitalizeSanitizer extends StringSanitizer {
  const _CapitalizeSanitizer();

  @override
  String sanitize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}

class _DigitsOnlySanitizer extends StringSanitizer {
  const _DigitsOnlySanitizer();

  @override
  String sanitize(String value) => value.replaceAll(RegExp('[^0-9]'), '');
}

class _ReplaceSanitizer extends StringSanitizer {
  final Pattern pattern;
  final String replacement;

  const _ReplaceSanitizer(this.pattern, this.replacement);

  @override
  String sanitize(String value) => value.replaceAll(pattern, replacement);
}

class _TruncateSanitizer extends StringSanitizer {
  final int maxLength;

  const _TruncateSanitizer(this.maxLength) : assert(maxLength >= 0);

  @override
  String sanitize(String value) =>
      value.length <= maxLength ? value : value.substring(0, maxLength);
}
