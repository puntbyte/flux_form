// lib/src/forms/builders/map_input_builder.dart

import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/inputs/map_input.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validators/logic_validator.dart';
import 'package:flux_form/src/validation/validators/object_validator.dart';

/// A fluent builder that composes map-level and value-level validators and
/// sanitizers into a [SimpleMapInput<K, V, E>].
///
/// Methods are grouped into two sets:
/// - **Map-level** (no prefix): rules that apply to the whole map.
/// - **Value-level** (`value` prefix): rules applied to every individual value.
///
/// ```dart
/// final metadata = MapInputBuilder<String, String, String>()
///   .notEmpty('At least one entry is required')
///   .valueValidate(StringValidator.required('Value cannot be empty'))
///   .valueTrim()
///   .buildUntouched();
/// ```
class MapInputBuilder<K, V, E> {
  final List<Validator<Map<K, V>, E>> _validators = [];
  final List<Sanitizer<Map<K, V>>> _sanitizers = [];
  final List<Validator<V, E>> _valueValidators = [];
  final List<Sanitizer<V>> _valueSanitizers = [];
  ValidationMode _mode = ValidationMode.live;

  // ── Map-level validators ──────────────────────────────────

  /// Fails when the map is empty.
  MapInputBuilder<K, V, E> notEmpty(E error) => _v(_NotEmptyMapValidator(error));

  /// Fails when the map has fewer than [min] entries.
  MapInputBuilder<K, V, E> minLength(int min, E error) => _v(_MinLengthMapValidator(min, error));

  /// Fails when the map has more than [max] entries.
  MapInputBuilder<K, V, E> maxLength(int max, E error) => _v(_MaxLengthMapValidator(max, error));

  /// Fails when the map does not contain [key].
  MapInputBuilder<K, V, E> containsKey(K key, E error) => _v(_ContainsKeyValidator(key, error));

  // ── Map-level LogicValidator shortcuts ────────────────────

  MapInputBuilder<K, V, E> when({
    required bool Function() condition,
    required Validator<Map<K, V>, E> validator,
  }) => _v(LogicValidator.when(condition: condition, validator: validator));

  MapInputBuilder<K, V, E> unless({
    required bool Function() condition,
    required Validator<Map<K, V>, E> validator,
  }) => _v(LogicValidator.unless(condition: condition, validator: validator));

  // ── Map-level escape hatches ──────────────────────────────

  MapInputBuilder<K, V, E> validate(Validator<Map<K, V>, E> validator) => _v(validator);

  MapInputBuilder<K, V, E> sanitize(Sanitizer<Map<K, V>> sanitizer) => _s(sanitizer);

  // ── Value-level rules ─────────────────────────────────────

  /// Adds a per-value validator. Checked against each map value individually.
  MapInputBuilder<K, V, E> valueValidate(Validator<V, E> validator) => _vv(validator);

  /// Adds a per-value sanitizer. Applied to each value before storage.
  MapInputBuilder<K, V, E> valueSanitize(Sanitizer<V> sanitizer) => _vs(sanitizer);

  /// Validates that no value equals [forbidden].
  MapInputBuilder<K, V, E> valueNotMatch(V forbidden, E error) =>
      _vv(ObjectValidator.notMatch(forbidden, error));

  /// Validates that every value is one of [candidates].
  MapInputBuilder<K, V, E> valueOneOf(List<V> candidates, E error) =>
      _vv(ObjectValidator.oneOf(candidates, error));

  // ── Mode ──────────────────────────────────────────────────

  MapInputBuilder<K, V, E> mode(ValidationMode mode) {
    _mode = mode;
    return this;
  }

  // ── Build ─────────────────────────────────────────────────

  SimpleMapInput<K, V, E> buildUntouched({Map<K, V> value = const {}}) => SimpleMapInput.untouched(
    value: value,
    validators: List.unmodifiable(_validators),
    sanitizers: List.unmodifiable(_sanitizers),
    valueValidators: List.unmodifiable(_valueValidators),
    valueSanitizers: List.unmodifiable(_valueSanitizers),
    mode: _mode,
  );

  SimpleMapInput<K, V, E> buildTouched({
    Map<K, V> value = const {},
    E? remoteError,
  }) => SimpleMapInput.touched(
    value: value,
    validators: List.unmodifiable(_validators),
    sanitizers: List.unmodifiable(_sanitizers),
    valueValidators: List.unmodifiable(_valueValidators),
    valueSanitizers: List.unmodifiable(_valueSanitizers),
    mode: _mode,
    remoteError: remoteError,
  );

  // ── Internal helpers ──────────────────────────────────────

  MapInputBuilder<K, V, E> _v(Validator<Map<K, V>, E> v) {
    _validators.add(v);
    return this;
  }

  MapInputBuilder<K, V, E> _s(Sanitizer<Map<K, V>> s) {
    _sanitizers.add(s);
    return this;
  }

  MapInputBuilder<K, V, E> _vv(Validator<V, E> v) {
    _valueValidators.add(v);
    return this;
  }

  MapInputBuilder<K, V, E> _vs(Sanitizer<V> s) {
    _valueSanitizers.add(s);
    return this;
  }
}

// ── Private map-level validator implementations ───────────────────────────────

class _NotEmptyMapValidator<K, V, E> extends Validator<Map<K, V>, E> {
  const _NotEmptyMapValidator(super.error);

  @override
  E? validate(Map<K, V> value) => value.isEmpty ? error : null;
}

class _MinLengthMapValidator<K, V, E> extends Validator<Map<K, V>, E> {
  final int min;

  const _MinLengthMapValidator(this.min, super.error);

  @override
  E? validate(Map<K, V> value) => value.length < min ? error : null;
}

class _MaxLengthMapValidator<K, V, E> extends Validator<Map<K, V>, E> {
  final int max;

  const _MaxLengthMapValidator(this.max, super.error);

  @override
  E? validate(Map<K, V> value) => value.length > max ? error : null;
}

class _ContainsKeyValidator<K, V, E> extends Validator<Map<K, V>, E> {
  final K key;

  const _ContainsKeyValidator(this.key, super.error);

  @override
  E? validate(Map<K, V> value) => value.containsKey(key) ? null : error;
}
