// lib/src/forms/builders/number_input_builder.dart

import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/inputs/number_input.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizers/number_sanitizer.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validators/logic_validator.dart';
import 'package:flux_form/src/validation/validators/number_validator.dart';

/// A fluent builder that composes validators and sanitizers into a
/// [SimpleNumberInput<T, E>].
///
/// [T] must extend [num] — typically `int` or `double`.
///
/// [NumberValidator] targets `num`, so each shortcut calls [Validator.adapt]
/// to narrow the type to [T] safely.
///
/// ```dart
/// final quantity = NumberInputBuilder<int, String>()
///   .min(1, 'Must be at least 1')
///   .max(99, 'Cannot exceed 99')
///   .buildUntouched(value: 1);
/// ```
class NumberInputBuilder<T extends num, E> {
  final List<Validator<T, E>> _validators = [];
  final List<Sanitizer<T>> _sanitizers = [];
  ValidationMode _mode = ValidationMode.live;

  // ── NumberValidator shortcuts ─────────────────────────────
  // NumberValidator<E> validates `num`. .adapt<T>() converts it to
  // Validator<T, E> so it slots into List<Validator<T, E>>.

  NumberInputBuilder<T, E> min(num min, E error) => _v(NumberValidator.min(min, error).adapt<T>());

  NumberInputBuilder<T, E> max(num max, E error) => _v(NumberValidator.max(max, error).adapt<T>());

  NumberInputBuilder<T, E> positive(E error) => _v(NumberValidator.positive(error).adapt<T>());

  NumberInputBuilder<T, E> negative(E error) => _v(NumberValidator.negative(error).adapt<T>());

  NumberInputBuilder<T, E> nonZero(E error) => _v(NumberValidator.nonZero(error).adapt<T>());

  NumberInputBuilder<T, E> between(num min, num max, E error, {bool inclusive = true}) =>
      _v(NumberValidator.between(min, max, error, inclusive: inclusive).adapt<T>());

  NumberInputBuilder<T, E> notBetween(num min, num max, E error, {bool inclusive = true}) =>
      _v(NumberValidator.notBetween(min, max, error, inclusive: inclusive).adapt<T>());

  NumberInputBuilder<T, E> integer(E error) => _v(NumberValidator.integer(error).adapt<T>());

  NumberInputBuilder<T, E> multipleOf(num factor, E error) =>
      _v(NumberValidator.multipleOf(factor, error).adapt<T>());

  NumberInputBuilder<T, E> even(E error) => _v(NumberValidator.even(error).adapt<T>());

  NumberInputBuilder<T, E> odd(E error) => _v(NumberValidator.odd(error).adapt<T>());

  // ── NumberSanitizer shortcuts ─────────────────────────────
  // NumberSanitizer targets `num`. .adapt<T>() narrows to Sanitizer<T>.

  NumberInputBuilder<T, E> round() => _s(const NumberSanitizer.round().adapt<T>());

  NumberInputBuilder<T, E> ceil() => _s(const NumberSanitizer.ceil().adapt<T>());

  NumberInputBuilder<T, E> floor() => _s(const NumberSanitizer.floor().adapt<T>());

  NumberInputBuilder<T, E> abs() => _s(const NumberSanitizer.abs().adapt<T>());

  NumberInputBuilder<T, E> clamp(num min, num max) =>
      _s(NumberSanitizer.clamp(min, max).adapt<T>());

  // ── LogicValidator shortcuts ──────────────────────────────

  NumberInputBuilder<T, E> when({
    required bool Function() condition,
    required Validator<T, E> validator,
  }) => _v(LogicValidator.when(condition: condition, validator: validator));

  NumberInputBuilder<T, E> unless({
    required bool Function() condition,
    required Validator<T, E> validator,
  }) => _v(LogicValidator.unless(condition: condition, validator: validator));

  // ── Escape hatches ────────────────────────────────────────

  NumberInputBuilder<T, E> validate(Validator<T, E> validator) => _v(validator);

  NumberInputBuilder<T, E> sanitize(Sanitizer<T> sanitizer) => _s(sanitizer);

  // ── Mode ──────────────────────────────────────────────────

  NumberInputBuilder<T, E> mode(ValidationMode mode) {
    _mode = mode;
    return this;
  }

  // ── Build ─────────────────────────────────────────────────

  SimpleNumberInput<T, E> buildUntouched({required T value}) => SimpleNumberInput.untouched(
    value: value,
    validators: List.unmodifiable(_validators),
    sanitizers: List.unmodifiable(_sanitizers),
    mode: _mode,
  );

  SimpleNumberInput<T, E> buildTouched({required T value, E? remoteError}) =>
      SimpleNumberInput.touched(
        value: value,
        validators: List.unmodifiable(_validators),
        sanitizers: List.unmodifiable(_sanitizers),
        mode: _mode,
        remoteError: remoteError,
      );

  NumberInputBuilder<T, E> _v(Validator<T, E> v) {
    _validators.add(v);
    return this;
  }

  NumberInputBuilder<T, E> _s(Sanitizer<T> s) {
    _sanitizers.add(s);
    return this;
  }
}
