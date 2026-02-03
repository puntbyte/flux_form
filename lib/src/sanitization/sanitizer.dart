// lib/src/sanitizers/sanitizer.dart

import 'package:meta/meta.dart';

/// Interface for transforming/cleaning data.
@immutable
abstract class Sanitizer<T> {
  const Sanitizer();

  /// Transforms the [value] into a sanitized format.
  T sanitize(T value);

  /// Adapts a sanitizer expecting [T] to accept a subtype [S].
  Sanitizer<S> adapt<S extends T>() => _AdaptedSanitizer<S, T>(this);
}

class _AdaptedSanitizer<S extends T, T> extends Sanitizer<S> {
  final Sanitizer<T> original;

  const _AdaptedSanitizer(this.original);

  @override
  S sanitize(S value) => original.sanitize(value) as S;
}
