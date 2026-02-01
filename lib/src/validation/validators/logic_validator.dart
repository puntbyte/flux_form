// lib/src/validation/validators/logic_validator.dart

import 'package:flux_form/src/validation/validator.dart';

typedef ValidatorPredicate = bool Function();

/// A convenience entry point for Logic Validators.
abstract class LogicValidator<T, E> extends Validator<T, E> {
  const LogicValidator(super.error);

  /// Applies [validator] only if the [condition] returns true.
  factory LogicValidator.when({
    required ValidatorPredicate condition,
    required Validator<T, E> validator,
  }) = _WhenValidator<T, E>;

  /// Applies [validator] only if the [condition] returns false.
  factory LogicValidator.unless({
    required ValidatorPredicate condition,
    required Validator<T, E> validator,
  }) = _UnlessValidator<T, E>;

  /// Applies [validator] only if the input [value] satisfies the [predicate].
  factory LogicValidator.where({
    required bool Function(T value) predicate,
    required Validator<T, E> validator,
  }) = _WhereValidator<T, E>;

  /// Valid if AT LEAST ONE of the [validators] passes.
  const factory LogicValidator.any(
    List<Validator<T, E>> validators,
    E error,
  ) = _AnyValidator<T, E>;

  /// Valid if ALL of the [validators] pass (first failing validator's error is returned).
  const factory LogicValidator.all(
    List<Validator<T, E>> validators,
    E error,
  ) = _AllValidator<T, E>;

  /// Valid if NONE of the [validators] pass.
  const factory LogicValidator.none(
    List<Validator<T, E>> validators,
    E error,
  ) = _NoneValidator<T, E>;

  /// Valid if EXACTLY ONE of the [validators] passes.
  const factory LogicValidator.xor(
    List<Validator<T, E>> validators,
    E error,
  ) = _XorValidator<T, E>;

  /// Delegates validation to a custom callback function.
  const factory LogicValidator.custom(
    E? Function(T value) validator,
  ) = _DynamicValidator<T, E>;
}

/// Applies [validator] only if the [condition] returns true.
/// The condition is evaluated lazily during validation.
class _WhenValidator<T, E> extends LogicValidator<T, E> {
  final ValidatorPredicate condition;
  final Validator<T, E> validator;

  _WhenValidator({
    required this.condition,
    required this.validator,
  }) : super(validator.error);

  @override
  E? validate(T value) {
    if (condition()) return validator.validate(value);

    return null;
  }
}

/// Applies [validator] only if the [condition] returns false.
class _UnlessValidator<T, E> extends LogicValidator<T, E> {
  final ValidatorPredicate condition;
  final Validator<T, E> validator;

  _UnlessValidator({
    required this.condition,
    required this.validator,
  }) : super(validator.error);

  @override
  E? validate(T value) {
    if (!condition()) return validator.validate(value);

    return null;
  }
}

/// Logical OR. Passes if AT LEAST ONE of the [validators] passes.
/// Returns [error] only if ALL validators fail.
class _AnyValidator<T, E> extends LogicValidator<T, E> {
  final List<Validator<T, E>> validators;

  const _AnyValidator(this.validators, super.error);

  @override
  E? validate(T value) {
    for (final rule in validators) {
      // If any rule returns null (valid), the whole group is valid.
      if (rule.validate(value) == null) return null;
    }
    // If we reach here, all failed.
    return error;
  }
}

class _AllValidator<T, E> extends LogicValidator<T, E> {
  final List<Validator<T, E>> validators;

  const _AllValidator(this.validators, super.error);

  @override
  E? validate(T value) {
    for (final rule in validators) {
      final res = rule.validate(value);
      if (res != null) return res; // return first failure
    }
    return null;
  }
}

class _NoneValidator<T, E> extends LogicValidator<T, E> {
  final List<Validator<T, E>> validators;

  const _NoneValidator(this.validators, super.error);

  @override
  E? validate(T value) {
    for (final rule in validators) {
      if (rule.validate(value) == null) return error; // one passed -> invalid
    }
    return null;
  }
}

class _XorValidator<T, E> extends LogicValidator<T, E> {
  final List<Validator<T, E>> validators;

  const _XorValidator(this.validators, super.error);

  @override
  E? validate(T value) {
    var passCount = 0;
    for (final rule in validators) {
      if (rule.validate(value) == null) passCount++;
      if (passCount > 1) break;
    }
    return passCount == 1 ? null : error;
  }
}

/// A validator that delegates logic to a callback.
/// Useful for complex cross-field validation where the error might change dynamically.
class _DynamicValidator<T, E> extends LogicValidator<T, E> {
  final E? Function(T value) validator;

  // Pass null to super because the error is determined dynamically by the callback
  const _DynamicValidator(this.validator) : super(null);

  @override
  E? validate(T value) => validator(value);
}

/// Applies [validator] only if the value itself satisfies the [predicate].
/// Difference from [_WhenValidator]: Checks the *input value*, not external state.
class _WhereValidator<T, E> extends LogicValidator<T, E> {
  final bool Function(T value) predicate;
  final Validator<T, E> validator;

  _WhereValidator({
    required this.predicate,
    required this.validator,
  }) : super(validator.error);

  @override
  E? validate(T value) {
    if (predicate(value)) return validator.validate(value);

    return null;
  }
}
