// lib/src/sanitization/sanitizer.dart

import 'package:flux_form/src/forms/builders/number_input_builder.dart';
import 'package:flux_form/src/sanitization/sanitizers/number_sanitizer.dart';
import 'package:meta/meta.dart';

/// Interface for transforming / cleaning data before validation.
@immutable
abstract class Sanitizer<T> {
  const Sanitizer();

  /// Transforms [value] into its sanitized form.
  T sanitize(T value);

  /// Adapts a [Sanitizer<T>] to accept a subtype [S extends T].
  ///
  /// Used internally by [NumberSanitizer] and [NumberInputBuilder] to narrow
  /// `num` sanitizers to `int` or `double`:
  /// ```dart
  /// NumberSanitizer.round().adapt<int>()
  /// ```
  Sanitizer<S> adapt<S extends T>() => _AdaptedSanitizer<S, T>(this);

  /// Creates a single [Sanitizer] that runs [sanitizers] in sequence,
  /// passing the output of each as the input to the next.
  ///
  /// Use this to define reusable sanitization pipelines:
  ///
  /// ```dart
  /// // Define once.
  /// final emailSanitizers = Sanitizer.compose([
  ///   StringSanitizer.trim(),
  ///   StringSanitizer.toLowerCase(),
  /// ]);
  ///
  /// // Reuse across inputs.
  /// class EmailInput extends StringInput<AuthError> {
  ///   @override
  ///   List<Sanitizer<String>> get sanitizers => [emailSanitizers];
  /// }
  ///
  /// class RecoveryEmailInput extends StringInput<AuthError> {
  ///   @override
  ///   List<Sanitizer<String>> get sanitizers => [emailSanitizers];
  /// }
  /// ```
  static Sanitizer<T> compose<T>(List<Sanitizer<T>> sanitizers) =>
      _ComposedSanitizer<T>(sanitizers);
}

// ─────────────────────────────────────────────────────────────────────────────

class _AdaptedSanitizer<S extends T, T> extends Sanitizer<S> {
  final Sanitizer<T> original;

  const _AdaptedSanitizer(this.original);

  @override
  S sanitize(S value) => original.sanitize(value) as S;
}

class _ComposedSanitizer<T> extends Sanitizer<T> {
  final List<Sanitizer<T>> _sanitizers;

  const _ComposedSanitizer(this._sanitizers);

  @override
  T sanitize(T value) {
    var result = value;
    for (final s in _sanitizers) {
      result = s.sanitize(result);
    }
    return result;
  }
}
