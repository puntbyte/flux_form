// lib/src/validation/validator_pipeline.dart

import 'package:flux_form/src/validation/validator.dart';

typedef OnValidateStart<T> = void Function(T value);
typedef OnValidateError<T, E> = void Function(T value, E error);
typedef OnValidateSuccess<T> = void Function(T value);

/// Helper to run a list of validators.
class ValidatorPipeline {
  // Prevent instantiation
  const ValidatorPipeline._();

  /// Standard synchronous validation.
  /// Iterates through [validators] and returns the first error found.
  static E? validate<T, E>(T value, List<Validator<T, E>> validators) {
    for (final validator in validators) {
      final result = validator.validate(value);
      if (result != null) return result;
    }

    return null;
  }

  /// Validation with Lifecycle Hooks.
  /// Useful for logging or complex debugging.
  static E? validateWithHooks<T, E>(
    T value,
    List<Validator<T, E>> validators, {
    OnValidateStart<T>? onStart,
    OnValidateError<T, E>? onError,
    OnValidateSuccess<T>? onSuccess,
  }) {
    onStart?.call(value);

    for (final validator in validators) {
      final result = validator.validate(value);
      if (result != null) {
        onError?.call(value, result);
        return result;
      }
    }

    onSuccess?.call(value);
    return null;
  }

  /// Asynchronous validation pipeline.
  /// Awaits each validator sequentially.
  static Future<E?> validateAsync<T, E>(
    T value,
    List<AsyncValidator<T, E>> asyncValidators,
  ) async {
    for (final validator in asyncValidators) {
      final result = await validator.validate(value);
      if (result != null) return result;
    }

    return null;
  }

  /// Runs ALL validators and returns a list of ALL errors found.
  /// Useful for "Password Strength" lists where you want to show multiple
  /// missing requirements at once.
  static List<E> validateAll<T, E>(T value, List<Validator<T, E>> validators) {
    return validators
        .map((v) => v.validate(value))
        .whereType<E>() // Filter out nulls (valid results)
        .toList();
  }
}
