// lib/src/validation/validators/number_validator.dart

import 'package:flux_form/src/validation/validator.dart';

/// A namespace for Numeric validation rules (int/double).
abstract class NumberValidator<E> extends Validator<num, E> {
  const NumberValidator(super.error);

  /// Validates number is >= [min].
  const factory NumberValidator.min(num min, E error) = _MinNumberValidator;

  /// Validates number is <= [max].
  const factory NumberValidator.max(num max, E error) = _MaxNumberValidator;

  /// Validates number is >= 0.
  const factory NumberValidator.positive(E error) = _NonNegativeValidator;

  /// Validates number is < 0.
  const factory NumberValidator.negative(E error) = _NegativeNumberValidator;

  /// Validates number is not zero.
  const factory NumberValidator.nonZero(E error) = _NonZeroNumberValidator;

  /// Validates number is between min and max (inclusive by default).
  const factory NumberValidator.between(num min, num max, E error, {bool inclusive}) =
  _BetweenNumberValidator;

  /// Validates number is NOT between min and max.
  const factory NumberValidator.notBetween(num min, num max, E error, {bool inclusive}) =
  _NotBetweenNumberValidator;

  /// Validates the number is an integer (no fractional part).
  const factory NumberValidator.integer(E error) = _IntegerNumberValidator;

  /// Validates the number is a multiple of [factor].
  const factory NumberValidator.multipleOf(num factor, E error) = _MultipleOfNumberValidator;

  /// Validates the number is even (only meaningful for integers).
  const factory NumberValidator.even(E error) = _EvenNumberValidator;

  /// Validates the number is odd (only meaningful for integers).
  const factory NumberValidator.odd(E error) = _OddNumberValidator;
}

class _MinNumberValidator<E> extends NumberValidator<E> {
  final num min;

  const _MinNumberValidator(this.min, super.error);

  @override
  E? validate(num value) => value < min ? error : null;
}

class _MaxNumberValidator<E> extends NumberValidator<E> {
  final num max;

  const _MaxNumberValidator(this.max, super.error);

  @override
  E? validate(num value) => value > max ? error : null;
}

class _NonNegativeValidator<E> extends NumberValidator<E> {
  const _NonNegativeValidator(super.error);

  @override
  E? validate(num value) => value < 0 ? error : null;
}

class _NegativeNumberValidator<E> extends NumberValidator<E> {
  const _NegativeNumberValidator(super.error);

  @override
  E? validate(num value) => value >= 0 ? error : null;
}

class _NonZeroNumberValidator<E> extends NumberValidator<E> {
  const _NonZeroNumberValidator(super.error);

  @override
  E? validate(num value) => value == 0 ? error : null;
}

class _BetweenNumberValidator<E> extends NumberValidator<E> {
  final num a;
  final num b;
  final bool inclusive;

  const _BetweenNumberValidator(this.a, this.b, super.error, {this.inclusive = true});

  @override
  E? validate(num value) {
    final lower = a <= b ? a : b;
    final upper = a <= b ? b : a;

    if (inclusive) {
      return (value >= lower && value <= upper) ? null : error;
    } else {
      return (value > lower && value < upper) ? null : error;
    }
  }
}

class _NotBetweenNumberValidator<E> extends NumberValidator<E> {
  final num a;
  final num b;
  final bool inclusive;

  const _NotBetweenNumberValidator(this.a, this.b, super.error, {this.inclusive = true});

  @override
  E? validate(num value) {
    final lower = a <= b ? a : b;
    final upper = a <= b ? b : a;

    if (inclusive) {
      return (value >= lower && value <= upper) ? error : null;
    } else {
      return (value > lower && value < upper) ? error : null;
    }
  }
}

class _IntegerNumberValidator<E> extends NumberValidator<E> {
  const _IntegerNumberValidator(super.error);

  @override
  E? validate(num value) {
    return (value % 1 == 0) ? null : error;
  }
}

class _MultipleOfNumberValidator<E> extends NumberValidator<E> {
  final num factor;

  const _MultipleOfNumberValidator(this.factor, super.error);

  @override
  E? validate(num value) {
    if (factor == 0) return error;
    if (value is int && factor is int) {
      return (value % (factor as int) == 0) ? null : error;
    } else {
      final quotient = value / factor;
      const eps = 1e-9;
      return ((quotient - quotient.round()).abs() < eps) ? null : error;
    }
  }
}

class _EvenNumberValidator<E> extends NumberValidator<E> {
  const _EvenNumberValidator(super.error);

  @override
  E? validate(num value) {
    if (value % 1 != 0) return error; // not integer
    if (value.toInt() % 2 == 0) {
      return null;
    } else {
      return error;
    }
  }
}

class _OddNumberValidator<E> extends NumberValidator<E> {
  const _OddNumberValidator(super.error);

  @override
  E? validate(num value) {
    if (value % 1 != 0) return error; // not integer
    return (value.toInt() % 2 != 0) ? null : error;
  }
}
