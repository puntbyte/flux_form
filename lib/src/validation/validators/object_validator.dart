// lib/src/validation/validators/object_validator.dart
import 'package:flux_form/src/validation/validator.dart';

/// A namespace for generic object matching rules.
abstract class ObjectValidator<T, E> extends Validator<T, E> {
  const ObjectValidator(super.error);

  /// Validates value == [other].
  const factory ObjectValidator.match(T other, E error) = _MatchValidator;

  /// Validates value != [other].
  const factory ObjectValidator.notMatch(T other, E error) = _NotMatchValidator;

  /// Validates the value is one of the provided candidates.
  const factory ObjectValidator.oneOf(List<T> candidates, E error) = _OneOfValidator;

  /// Validates the value is NOT one of the provided candidates.
  const factory ObjectValidator.notOneOf(List<T> candidates, E error) = _NotOneOfValidator;

  /// Validates value with a custom predicate function.
  const factory ObjectValidator.predicate(bool Function(T) predicate, E error) =
      _PredicateValidator;
}

class _MatchValidator<T, E> extends ObjectValidator<T, E> {
  final T other;

  const _MatchValidator(this.other, super.error);

  @override
  E? validate(T value) => value == other ? null : error;
}

class _NotMatchValidator<T, E> extends ObjectValidator<T, E> {
  final T other;

  const _NotMatchValidator(this.other, super.error);

  @override
  E? validate(T value) => value != other ? null : error;
}

class _OneOfValidator<T, E> extends ObjectValidator<T, E> {
  final List<T> candidates;

  const _OneOfValidator(this.candidates, super.error);

  @override
  E? validate(T value) => candidates.contains(value) ? null : error;
}

class _NotOneOfValidator<T, E> extends ObjectValidator<T, E> {
  final List<T> candidates;

  const _NotOneOfValidator(this.candidates, super.error);

  @override
  E? validate(T value) => candidates.contains(value) ? error : null;
}

class _PredicateValidator<T, E> extends ObjectValidator<T, E> {
  final bool Function(T) predicate;

  const _PredicateValidator(this.predicate, super.error);

  @override
  E? validate(T value) => predicate(value) ? null : error;
}
