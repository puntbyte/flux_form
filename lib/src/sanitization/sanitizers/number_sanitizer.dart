// lib/src/sanitization/sanitizers/number_sanitizer.dart

import 'package:flux_form/src/sanitization/sanitizer.dart';

/// A namespace for Number transformation rules.
abstract class NumberSanitizer implements Sanitizer<num> {
  const NumberSanitizer();

  /// Converts negative numbers to positive.
  const factory NumberSanitizer.abs() = _AbsSanitizer;

  /// Rounds the number to the nearest integer (returns as num/double).
  const factory NumberSanitizer.round() = _RoundSanitizer;

  /// Clamps the number between [min] and [max].
  const factory NumberSanitizer.clamp(num min, num max) = _ClampSanitizer;

  /// Rounds up to the nearest integer.
  const factory NumberSanitizer.ceil() = _CeilSanitizer;

  /// Rounds down to the nearest integer.
  const factory NumberSanitizer.floor() = _FloorSanitizer;
}

// ================= Implementation =================

class _AbsSanitizer extends NumberSanitizer {
  const _AbsSanitizer();

  @override
  num sanitize(num value) => value.abs();
}

class _RoundSanitizer extends NumberSanitizer {
  const _RoundSanitizer();

  @override
  num sanitize(num value) => value.roundToDouble();
}

class _CeilSanitizer extends NumberSanitizer {
  const _CeilSanitizer();

  @override
  num sanitize(num value) => value.ceilToDouble();
}

class _FloorSanitizer extends NumberSanitizer {
  const _FloorSanitizer();

  @override
  num sanitize(num value) => value.floorToDouble();
}

class _ClampSanitizer extends NumberSanitizer {
  final num min;
  final num max;

  const _ClampSanitizer(this.min, this.max);

  @override
  num sanitize(num value) => value.clamp(min, max);
}
