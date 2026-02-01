// lib/src/validation/validators/bool_validator.dart

import 'package:flux_form/src/validation/validator.dart';

/// A namespace for Boolean rules.
abstract class BoolValidator<E> extends Validator<bool, E> {
  const BoolValidator(super.error);

  /// Validates value is true.
  const factory BoolValidator.isTrue(E error) = _IsTrueValidator;

  /// Validates value is false.
  const factory BoolValidator.isFalse(E error) = _IsFalseValidator;

  /// Validates value equals expected boolean.
  const factory BoolValidator.equals(bool expected, E error) = _EqualsValidator;
}

class _IsTrueValidator<E> extends BoolValidator<E> {
  const _IsTrueValidator(super.error);

  @override
  E? validate(bool value) => value ? null : error;
}

class _IsFalseValidator<E> extends BoolValidator<E> {
  const _IsFalseValidator(super.error);

  @override
  E? validate(bool value) => !value ? null : error;
}

class _EqualsValidator<E> extends BoolValidator<E> {
  final bool expected;

  const _EqualsValidator(this.expected, super.error);

  @override
  E? validate(bool value) => value == expected ? null : error;
}
