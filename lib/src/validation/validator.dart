// lib/src/validation/validator.dart

import 'package:meta/meta.dart';

/// A synchronous validation rule.
/// [T] is the type of value being validated.
/// [E] is the type of error returned (e.g., String or FluxFault).
@immutable
abstract class Validator<T, E> {
  final E? error;

  const Validator([this.error]);

  /// Returns [error] if [value] is invalid, otherwise returns null.
  E? validate(T value);

  /// Adapts a validator expecting [T] to accept a subtype [S].
  /// Useful for Extension Types (e.g., converting [Validator<String>] to [Validator<Email>]).
  Validator<S, E> adapt<S extends T>() => _AdaptedValidator<S, T, E>(this);
}

class _AdaptedValidator<S extends T, T, E> extends Validator<S, E> {
  final Validator<T, E> original;

  _AdaptedValidator(this.original) : super(original.error);

  @override
  E? validate(S value) => original.validate(value);
}

/// A asynchronous validation rule.
/// Useful for checking databases, APIs, etc.
@immutable
abstract class AsyncValidator<T, E> {
  final E? error;

  const AsyncValidator([this.error]);

  /// Validates [value] asynchronously.
  Future<E?> validate(T value);
}
