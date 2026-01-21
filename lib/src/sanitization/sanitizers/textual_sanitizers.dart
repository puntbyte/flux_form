// lib/src/sanitizers/textual_sanitizers.dart

import 'package:flux_form/src/sanitization/sanitizer.dart';

/// Trims whitespace from both ends.
class TrimSanitizer implements Sanitizer<String> {
  const TrimSanitizer();

  @override
  String sanitize(String value) => value.trim();
}

/// Converts string to lower case.
class ToLowerCaseSanitizer implements Sanitizer<String> {
  const ToLowerCaseSanitizer();

  @override
  String sanitize(String value) => value.toLowerCase();
}

/// Converts string to upper case.
class ToUpperCaseSanitizer implements Sanitizer<String> {
  const ToUpperCaseSanitizer();

  @override
  String sanitize(String value) => value.toUpperCase();
}

/// Removes all whitespace (including internal spaces).
class RemoveSpaceSanitizer implements Sanitizer<String> {
  const RemoveSpaceSanitizer();

  @override
  String sanitize(String value) => value.replaceAll(RegExp(r'\s+'), '');
}
