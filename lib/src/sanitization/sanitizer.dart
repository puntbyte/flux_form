// lib/src/sanitizers/sanitizer.dart

/// Interface for transforming/cleaning data.
abstract interface class Sanitizer<T> {
  /// Transforms the [value] into a sanitized format.
  T sanitize(T value);
}
