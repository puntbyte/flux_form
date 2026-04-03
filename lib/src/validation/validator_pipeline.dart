// lib/src/validation/validator_pipeline.dart

import 'package:flux_form/src/validation/validator.dart';

typedef OnValidateStart<T> = void Function(T value);
typedef OnValidateError<T, E> = void Function(T value, E error);
typedef OnValidateSuccess<T> = void Function(T value);

/// Helper that runs lists of [Validator] and [AsyncValidator] instances.
class ValidatorPipeline {
  const ValidatorPipeline._();

  // ── Synchronous ───────────────────────────────────────────

  /// Runs [validators] in order and returns the first error found.
  ///
  /// Returns null when all validators pass.
  static E? validate<T, E>(T value, List<Validator<T, E>> validators) {
    for (final v in validators) {
      final result = v.validate(value);
      if (result != null) return result;
    }
    return null;
  }

  /// Runs [validators] in order with lifecycle hooks.
  ///
  /// Useful for logging, analytics, or debugging:
  /// ```dart
  /// ValidatorPipeline.validateWithHooks(
  ///   email.value,
  ///   email.validators,
  ///   onStart: (v) => log('Validating: $v'),
  ///   onError: (v, e) => analytics.track('validation_error', {'field': 'email', 'error': e}),
  /// );
  /// ```
  static E? validateWithHooks<T, E>(
    T value,
    List<Validator<T, E>> validators, {
    OnValidateStart<T>? onStart,
    OnValidateError<T, E>? onError,
    OnValidateSuccess<T>? onSuccess,
  }) {
    onStart?.call(value);

    for (final v in validators) {
      final result = v.validate(value);
      if (result != null) {
        onError?.call(value, result);
        return result;
      }
    }

    onSuccess?.call(value);
    return null;
  }

  /// Runs ALL [validators] and returns every error found.
  ///
  /// Unlike [validate], this does not short-circuit on the first error.
  /// Use for password-strength meters or multi-requirement checklists:
  /// ```dart
  /// final allErrors = ValidatorPipeline.validateAll(password.value, password.validators);
  /// ```
  static List<E> validateAll<T, E>(T value, List<Validator<T, E>> validators) {
    return validators.map((v) => v.validate(value)).whereType<E>().toList();
  }

  // ── Asynchronous (sequential) ─────────────────────────────

  /// Awaits [asyncValidators] in order and returns the first error found.
  ///
  /// Validators run sequentially — each one waits for the previous to complete.
  /// For independent validators that can run simultaneously, prefer
  /// [validateAsyncParallel].
  static Future<E?> validateAsync<T, E>(
    T value,
    List<AsyncValidator<T, E>> asyncValidators,
  ) async {
    for (final v in asyncValidators) {
      final result = await v.validate(value);
      if (result != null) return result;
    }
    return null;
  }

  // ── Asynchronous (parallel) ───────────────────────────────

  /// Runs all [asyncValidators] concurrently and returns the first error in
  /// pipeline order (not in completion order).
  ///
  /// All validators start at the same time via [Future.wait]. Once all have
  /// settled, results are scanned in declaration order so that the error
  /// priority matches the order you declared your validators — even if a
  /// later validator finished first.
  ///
  /// Use this when your async validators are **independent** (e.g., separate
  /// API calls that do not rely on each other's result):
  ///
  /// ```dart
  /// class UsernameInput extends StringInput<AuthError>
  ///     with InputMixin<String, AuthError, UsernameInput> {
  ///   @override
  ///   List<AsyncValidator<String, AuthError>> get asyncValidators => [
  ///     UsernameAvailabilityValidator(),
  ///     UsernameBannedWordsValidator(),
  ///   ];
  /// }
  ///
  /// // In your cubit, choose sequential or parallel per field:
  /// final error = await ValidatorPipeline.validateAsyncParallel(
  ///   state.schema.username.value,
  ///   state.schema.username.asyncValidators,
  /// );
  /// ```
  ///
  /// For validators that must run in order (e.g., the second check only makes
  /// sense if the first passes), use [validateAsync] instead.
  static Future<E?> validateAsyncParallel<T, E>(
    T value,
    List<AsyncValidator<T, E>> asyncValidators,
  ) async {
    if (asyncValidators.isEmpty) return null;

    // Fire all validators simultaneously.
    final futures = asyncValidators.map((v) => v.validate(value)).toList();
    final results = await Future.wait(futures);

    // Return the first error in declaration order — preserves pipeline priority.
    for (final result in results) {
      if (result != null) return result;
    }
    return null;
  }
}
