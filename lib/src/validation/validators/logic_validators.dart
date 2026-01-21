// lib/src/rules/logic_validators.dart

import 'package:flux_form/src/validation/validator.dart';

/// Wraps a [validator] and only executes it if [condition] is true.
///
/// Usage:
/// ```dart
/// WhenRule(
///   condition: state.isCheckboxChecked,
///   rule: RequiredRule('Reason is required'),
/// )
/// ```
class WhenValidator<T, E> extends Validator<T, E> {
  final bool condition;
  final Validator<T, E> validator;

  WhenValidator({
    required this.condition,
    required this.validator,
  }) : super(validator.error); // We pass the child's error up

  @override
  E? validate(T value) {
    if (!condition) return null; // Skipped = Valid
    return validator.validate(value);
  }
}

/// Wraps a [validator] and only executes it if [condition] is FALSE.
class UnlessValidator<T, E> extends Validator<T, E> {
  final bool condition;
  final Validator<T, E> validator;

  UnlessValidator({
    required this.condition,
    required this.validator,
  }) : super(validator.error);

  @override
  E? validate(T value) {
    if (condition) return null; // Skipped
    return validator.validate(value);
  }
}

/// Logical OR. Passes if AT LEAST ONE of the [validator] is valid.
/// Returns [error] only if ALL rules fail.
class AnyValidator<T, E> extends Validator<T, E> {
  final List<Validator<T, E>> validator;

  const AnyValidator(this.validator, super.error);

  @override
  E? validate(T value) {
    for (final rule in validator) {
      if (rule.validate(value) == null) return null;
    }

    return error; // All failed
  }
}

/// A rule that validates based on a runtime callback.
/// Essential for Cross-Field validation (e.g. Confirm Password).
class DynamicValidator<T, E> extends Validator<T, E> {
  // Note: Super error is awkward here, so we usually ignore it or pass a dummy
  // if the base class requires it.
  // Better approach: Make base FluxRule not require `error` in constructor if possible,
  // or pass a placeholder.

  // REVISED Base Implementation Concept below:
  final E? Function(T value) validator;

  /// [validator] is a function that returns the Error [E] if invalid,
  /// or null if valid.
  const DynamicValidator(this.validator) : super(null);

  @override
  E? validate(T value) => validator(value);
}
