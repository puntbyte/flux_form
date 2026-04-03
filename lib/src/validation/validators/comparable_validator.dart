// lib/src/validation/validators/comparable_validator.dart

import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validators/object_validator.dart';

/// A namespace for [Comparable] validation rules (dates, durations, numbers).
///
/// Use [ComparableValidator] when you need ordering semantics: greater than,
/// less than, between a range. For equality and membership checks
/// (`oneOf` / `notOneOf`), prefer [ObjectValidator] — it works for any [T],
/// not just [Comparable<T>].
abstract class ComparableValidator<T extends Comparable<T>, E> extends Validator<T, E> {
  const ComparableValidator(super.error);

  // ── Ordering ──────────────────────────────────────────────

  /// Fails when `value <= other`.
  const factory ComparableValidator.greaterThan(T other, E error) = _GreaterThanValidator;

  /// Fails when `value >= other`.
  const factory ComparableValidator.lessThan(T other, E error) = _LessThanValidator;

  /// Fails when `value < min` (i.e., value must be >= min).
  const factory ComparableValidator.min(T min, E error) = _MinValueValidator;

  /// Fails when `value > max` (i.e., value must be <= max).
  const factory ComparableValidator.max(T max, E error) = _MaxValueValidator;

  // ── Range ─────────────────────────────────────────────────

  /// Fails when [value] falls outside the range [[min], [max]].
  ///
  /// When [inclusive] is true (default): `min <= value <= max`.
  /// When [inclusive] is false: `min < value < max`.
  ///
  /// Bounds are normalised automatically so order does not matter.
  const factory ComparableValidator.between(
    T min,
    T max,
    E error, {
    bool inclusive,
  }) = _BetweenValidator;

  /// Fails when [value] falls inside the range [[min], [max]].
  ///
  /// Inverse of [ComparableValidator.between].
  const factory ComparableValidator.notBetween(
    T min,
    T max,
    E error, {
    bool inclusive,
  }) = _NotBetweenValidator;

  // ── Membership ────────────────────────────────────────────

  /// @deprecated Use [ObjectValidator.oneOf] instead.
  ///
  /// [ComparableValidator.oneOf] requires [T] to extend [Comparable<T>],
  /// but membership checks need only equality (`==`). [ObjectValidator.oneOf]
  /// works for any type and is the canonical choice.
  ///
  /// ```dart
  /// // Before
  /// ComparableValidator.oneOf(['a', 'b'], error)
  ///
  /// // After
  /// ObjectValidator.oneOf(['a', 'b'], error)
  /// ```
  @Deprecated(
    'Use ObjectValidator.oneOf instead. '
    'The Comparable constraint is unnecessary for membership checks. '
    'ComparableValidator.oneOf will be removed in the next major version.',
  )
  const factory ComparableValidator.oneOf(List<T> candidates, E error) = _OneOfValidator;

  /// @deprecated Use [ObjectValidator.notOneOf] instead.
  ///
  /// See [ComparableValidator.oneOf] deprecation note.
  @Deprecated(
    'Use ObjectValidator.notOneOf instead. '
    'The Comparable constraint is unnecessary for membership checks. '
    'ComparableValidator.notOneOf will be removed in the next major version.',
  )
  const factory ComparableValidator.notOneOf(List<T> candidates, E error) = _NotOneOfValidator;
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementations
// ─────────────────────────────────────────────────────────────────────────────

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
    final lower = a.compareTo(b) <= 0 ? a : b;
    final upper = a.compareTo(b) <= 0 ? b : a;

    return inclusive
        ? (value.compareTo(lower) >= 0 && value.compareTo(upper) <= 0 ? null : error)
        : (value.compareTo(lower) > 0 && value.compareTo(upper) < 0 ? null : error);
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

    return inclusive
        ? (value.compareTo(lower) >= 0 && value.compareTo(upper) <= 0 ? error : null)
        : (value.compareTo(lower) > 0 && value.compareTo(upper) < 0 ? error : null);
  }
}

// ignore: deprecated_member_use_from_same_package
class _OneOfValidator<T extends Comparable<T>, E> extends ComparableValidator<T, E> {
  final List<T> candidates;

  const _OneOfValidator(this.candidates, super.error);

  @override
  E? validate(T value) => candidates.contains(value) ? null : error;
}

// ignore: deprecated_member_use_from_same_package
class _NotOneOfValidator<T extends Comparable<T>, E> extends ComparableValidator<T, E> {
  final List<T> candidates;

  const _NotOneOfValidator(this.candidates, super.error);

  @override
  E? validate(T value) => candidates.contains(value) ? error : null;
}
