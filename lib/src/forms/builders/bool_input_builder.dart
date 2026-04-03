// lib/src/forms/builders/bool_input_builder.dart

import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/inputs/bool_input.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validators/bool_validator.dart';
import 'package:flux_form/src/validation/validators/logic_validator.dart';

/// A fluent builder that composes validators into a [SimpleBoolInput].
///
/// ```dart
/// final acceptTerms = BoolInputBuilder<String>()
///   .isTrue('You must accept the Terms of Service')
///   .mode(ValidationMode.deferred)
///   .buildUntouched();
/// ```
class BoolInputBuilder<E> {
  final List<Validator<bool, E>> _validators = [];
  ValidationMode _mode = ValidationMode.live;

  // ── BoolValidator shortcuts ───────────────────────────────

  BoolInputBuilder<E> isTrue(E error) => _v(BoolValidator.isTrue(error));

  BoolInputBuilder<E> isFalse(E error) => _v(BoolValidator.isFalse(error));

  BoolInputBuilder<E> equals(bool expected, E error) => _v(BoolValidator.equals(expected, error));

  // ── LogicValidator shortcuts ──────────────────────────────

  BoolInputBuilder<E> when({
    required bool Function() condition,
    required Validator<bool, E> validator,
  }) => _v(LogicValidator.when(condition: condition, validator: validator));

  BoolInputBuilder<E> unless({
    required bool Function() condition,
    required Validator<bool, E> validator,
  }) => _v(LogicValidator.unless(condition: condition, validator: validator));

  // ── Escape hatch ──────────────────────────────────────────

  BoolInputBuilder<E> validate(Validator<bool, E> validator) => _v(validator);

  // ── Mode ──────────────────────────────────────────────────

  BoolInputBuilder<E> mode(ValidationMode mode) {
    _mode = mode;
    return this;
  }

  // ── Build ─────────────────────────────────────────────────

  SimpleBoolInput<E> buildUntouched({bool value = false}) => SimpleBoolInput.untouched(
    value: value,
    validators: List.unmodifiable(_validators),
    mode: _mode,
  );

  SimpleBoolInput<E> buildTouched({bool value = false, E? remoteError}) => SimpleBoolInput.touched(
    value: value,
    validators: List.unmodifiable(_validators),
    mode: _mode,
    remoteError: remoteError,
  );

  BoolInputBuilder<E> _v(Validator<bool, E> v) {
    _validators.add(v);
    return this;
  }
}
