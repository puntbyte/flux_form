// lib/src/sanitizers/sanitizer.dart

/// Interface for transforming/cleaning data.
abstract interface class Sanitizer<T> {
  const Sanitizer();

  /// Transforms the [value] into a sanitized format.
  T sanitize(T value);
}
