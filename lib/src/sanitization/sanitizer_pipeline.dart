// lib/src/sanitization/sanitizer_pipeline.dart

import 'package:flux_form/src/sanitization/sanitizer.dart';

/// Helper to run a list of sanitizers.
class SanitizerPipeline {
  static T sanitize<T>(T value, List<Sanitizer<T>> sanitizers) {
    var sanitized = value;
    for (final sanitizer in sanitizers) {
      sanitized = sanitizer.sanitize(sanitized);
    }

    return sanitized;
  }
}
