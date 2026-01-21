// lib/src/rules/general_validators.dart

import 'package:flux_form/src/validation/validator.dart';

/// Validates that the input value equals [otherValue].
/// Common use case: "Confirm Password" field.
class MatchValidator<T, E> extends Validator<T, E> {
  final T otherValue;

  const MatchValidator(this.otherValue, super.error);

  @override
  E? validate(T value) => value == otherValue ? null : error;
}

/// Validates that the input value is NOT equal to [otherValue].
class NotMatchValidator<T, E> extends Validator<T, E> {
  final T otherValue;

  const NotMatchValidator(this.otherValue, super.error);

  @override
  E? validate(T value) => value != otherValue ? null : error;
}

/// Validates that a boolean value is true.
/// Common use case: "Accept Terms and Conditions".
class IsTrueValidator<E> extends Validator<bool, E> {
  const IsTrueValidator(super.error);

  @override
  E? validate(bool value) => value ? null : error;
}

/// Validates that a boolean value is false.
class IsFalseValidator<E> extends Validator<bool, E> {
  const IsFalseValidator(super.error);

  @override
  E? validate(bool value) => !value ? null : error;
}

// ==========================================
// Collections (List, Set, Map)
// ==========================================
class ListNotEmptyValidator<T, E> extends Validator<List<T>, E> {
  const ListNotEmptyValidator(super.error);

  @override
  E? validate(List<T> value) => value.isEmpty ? error : null;
}

/// Validates that a List has at least [minSize] items.
class ListMinLengthValidator<T, E> extends Validator<List<T>, E> {
  final int minSize;

  const ListMinLengthValidator(this.minSize, super.error);

  @override
  E? validate(List<T> value) => value.length < minSize ? error : null;
}

/// Validates that a List does not exceed [maxSize] items.
class ListMaxLengthValidator<T, E> extends Validator<List<T>, E> {
  final int maxSize;

  const ListMaxLengthValidator(this.maxSize, super.error);

  @override
  E? validate(List<T> value) => value.length > maxSize ? error : null;
}
