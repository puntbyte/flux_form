// lib/src/validation/validator.dart

import 'package:flux_form/src/validation/validator_pipeline.dart';
import 'package:meta/meta.dart';

/// A synchronous validation rule.
///
/// [T] is the type of the value being validated.
/// [E] is the type of the error returned on failure.
@immutable
abstract class Validator<T, E> {
  final E? error;

  const Validator([this.error]);

  /// Returns [error] if [value] is invalid, otherwise returns null.
  E? validate(T value);

  /// Adapts a [Validator<T, E>] to accept a subtype [S extends T].
  ///
  /// Useful for Extension Types:
  /// ```dart
  /// // Validator<String, E> → Validator<Email, E>
  /// StringValidator.required(AuthError.required).adapt<Email>()
  /// ```
  Validator<S, E> adapt<S extends T>() => _AdaptedValidator<S, T, E>(this);

  /// Creates a single [Validator] that runs [validators] in order and returns
  /// the first error found — equivalent to a named, reusable pipeline.
  ///
  /// Use this to define shared rule sets that can be dropped into any input's
  /// `validators` list:
  ///
  /// ```dart
  /// // Define once.
  /// const passwordRules = Validator.compose([
  ///   StringValidator.required(AuthError.required),
  ///   StringValidator.minLength(8, AuthError.tooShort),
  ///   StringValidator.hasUppercase(AuthError.noUppercase),
  ///   StringValidator.hasDigit(AuthError.noDigit),
  /// ]);
  ///
  /// // Reuse across inputs.
  /// class PasswordInput extends StringInput<AuthError> {
  ///   @override
  ///   List<Validator<String, AuthError>> get validators => [passwordRules];
  /// }
  ///
  /// class ConfirmPasswordInput extends StringInput<AuthError> {
  ///   @override
  ///   List<Validator<String, AuthError>> get validators => [passwordRules];
  /// }
  /// ```
  static Validator<T, E> compose<T, E>(List<Validator<T, E>> validators) =>
      _ComposedValidator<T, E>(validators);
}

// ─────────────────────────────────────────────────────────────────────────────

class _AdaptedValidator<S extends T, T, E> extends Validator<S, E> {
  final Validator<T, E> original;

  _AdaptedValidator(this.original) : super(original.error);

  @override
  E? validate(S value) => original.validate(value);
}

class _ComposedValidator<T, E> extends Validator<T, E> {
  final List<Validator<T, E>> _validators;

  const _ComposedValidator(this._validators) : super(null);

  @override
  E? validate(T value) {
    for (final v in _validators) {
      final result = v.validate(value);
      if (result != null) return result;
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// An asynchronous validation rule.
///
/// Useful for server-side checks (username availability, email existence).
@immutable
abstract class AsyncValidator<T, E> {
  final E? error;

  const AsyncValidator([this.error]);

  /// Validates [value] asynchronously.
  Future<E?> validate(T value);

  /// Creates a single [AsyncValidator] that awaits [validators] in order and
  /// returns the first error found.
  ///
  /// For parallel execution, use
  /// [ValidatorPipeline.validateAsyncParallel] directly.
  static AsyncValidator<T, E> compose<T, E>(
    List<AsyncValidator<T, E>> validators,
  ) => _ComposedAsyncValidator<T, E>(validators);
}

class _ComposedAsyncValidator<T, E> extends AsyncValidator<T, E> {
  final List<AsyncValidator<T, E>> _validators;

  const _ComposedAsyncValidator(this._validators) : super(null);

  @override
  Future<E?> validate(T value) async {
    for (final v in _validators) {
      final result = await v.validate(value);
      if (result != null) return result;
    }
    return null;
  }
}
