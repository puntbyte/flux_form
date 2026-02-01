// lib/src/validation/validators/comparable_validator.dart

import 'package:flux_form/src/validation/validator.dart';

/// A namespace for Comparable validation rules (Dates, Durations, etc).
abstract class ComparableValidator<T extends Comparable<T>, E> extends Validator<T, E> {
  const ComparableValidator(super.error);

  /// Validates value > [other].
  const factory ComparableValidator.greaterThan(T other, E error) = _GreaterThanValidator;

  /// Validates value < [other].
  const factory ComparableValidator.lessThan(T other, E error) = _LessThanValidator;

  /// Validates value >= [min].
  const factory ComparableValidator.min(T min, E error) = _MinValueValidator;

  /// Validates value <= [max].
  const factory ComparableValidator.max(T max, E error) = _MaxValueValidator;

  /// Validates that value is inside the inclusive/exclusive range [min, max].
  /// If `inclusive` is true (default) uses `min <= value <= max` semantics.
  const factory ComparableValidator.between(T min, T max, E error, {bool inclusive}) =
      _BetweenValidator;

  /// Validates that value is NOT inside the range [min, max].
  const factory ComparableValidator.notBetween(T min, T max, E error, {bool inclusive}) =
      _NotBetweenValidator;

  /// Validates that value exists in a provided set of candidates.
  const factory ComparableValidator.oneOf(List<T> candidates, E error) = _OneOfValidator;

  /// Validates that value does NOT exist in a provided set of candidates.
  const factory ComparableValidator.notOneOf(List<T> candidates, E error) = _NotOneOfValidator;
}

class _GreaterThanValidator<T extends Comparable<T>, E> extends ComparableValidator<T, E> {
  final T other;

  const _GreaterThanValidator(this.other, super.error);

  @override
  E? validate(T value) => value.compareTo(other) > 0 ? null : error;
}

class _LessThanValidator<T extends Comparable<T>, E> extends ComparableValidator<T, E> {
  final T other;

  const _LessThanValidator(this.other, super.error);

  @override
  E? validate(T value) => value.compareTo(other) < 0 ? null : error;
}

class _MinValueValidator<T extends Comparable<T>, E> extends ComparableValidator<T, E> {
  final T other;

  const _MinValueValidator(this.other, super.error);

  @override
  E? validate(T value) => value.compareTo(other) >= 0 ? null : error;
}

class _MaxValueValidator<T extends Comparable<T>, E> extends ComparableValidator<T, E> {
  final T other;

  const _MaxValueValidator(this.other, super.error);

  @override
  E? validate(T value) => value.compareTo(other) <= 0 ? null : error;
}

class _BetweenValidator<T extends Comparable<T>, E> extends ComparableValidator<T, E> {
  final T a;
  final T b;
  final bool inclusive;

  const _BetweenValidator(this.a, this.b, super.error, {this.inclusive = true});

  @override
  E? validate(T value) {
    // Normalize bounds so order doesn't matter
    final lower = a.compareTo(b) <= 0 ? a : b;
    final upper = a.compareTo(b) <= 0 ? b : a;

    if (inclusive) {
      return (value.compareTo(lower) >= 0 && value.compareTo(upper) <= 0) ? null : error;
    } else {
      return (value.compareTo(lower) > 0 && value.compareTo(upper) < 0) ? null : error;
    }
  }
}

class _NotBetweenValidator<T extends Comparable<T>, E> extends ComparableValidator<T, E> {
  final T a;
  final T b;
  final bool inclusive;

  const _NotBetweenValidator(this.a, this.b, super.error, {this.inclusive = true});

  @override
  E? validate(T value) {
    final lower = a.compareTo(b) <= 0 ? a : b;
    final upper = a.compareTo(b) <= 0 ? b : a;

    if (inclusive) {
      return (value.compareTo(lower) >= 0 && value.compareTo(upper) <= 0) ? error : null;
    } else {
      return (value.compareTo(lower) > 0 && value.compareTo(upper) < 0) ? error : null;
    }
  }
}

class _OneOfValidator<T extends Comparable<T>, E> extends ComparableValidator<T, E> {
  final List<T> candidates;

  const _OneOfValidator(this.candidates, super.error);

  @override
  E? validate(T value) => candidates.contains(value) ? null : error;
}

class _NotOneOfValidator<T extends Comparable<T>, E> extends ComparableValidator<T, E> {
  final List<T> candidates;

  const _NotOneOfValidator(this.candidates, super.error);

  @override
  E? validate(T value) => candidates.contains(value) ? error : null;
}
