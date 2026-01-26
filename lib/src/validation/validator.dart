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
