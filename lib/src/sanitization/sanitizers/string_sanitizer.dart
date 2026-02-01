// lib/src/sanitization/sanitizers/string_sanitizer.dart

import 'package:flux_form/src/sanitization/sanitizer.dart';

/// A namespace for String transformation rules.
abstract class StringSanitizer implements Sanitizer<String> {
  const StringSanitizer();

  /// Trims whitespace from both ends.
  const factory StringSanitizer.trim() = _TrimSanitizer;

  /// Converts string to lower case.
  const factory StringSanitizer.toLowerCase() = _ToLowerCaseSanitizer;

  /// Converts string to upper case.
  const factory StringSanitizer.toUpperCase() = _ToUpperCaseSanitizer;

  /// Capitalizes the first letter and lowercases the rest (e.g., "jOHN" -> "John").
  const factory StringSanitizer.capitalize() = _CapitalizeSanitizer;

  /// Removes all whitespace (including internal spaces).
  /// Useful for credit cards or phone numbers.
  const factory StringSanitizer.removeSpaces() = _RemoveSpaceSanitizer;

  /// Removes all non-digit characters.
  /// Useful for phone numbers (e.g. "(123) 456" -> "123456").
  const factory StringSanitizer.digitsOnly() = _DigitsOnlySanitizer;
}

// ================= Implementation =================

class _TrimSanitizer extends StringSanitizer {
  const _TrimSanitizer();

  @override
  String sanitize(String value) => value.trim();
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

class _RemoveSpaceSanitizer extends StringSanitizer {
  const _RemoveSpaceSanitizer();

  @override
  String sanitize(String value) => value.replaceAll(RegExp(r'\s+'), '');
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
