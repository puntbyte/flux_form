// lib/src/forms/inputs/map_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizer_pipeline.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validator_pipeline.dart';
import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────
// Abstract base — extend this for domain-specific key-value
// collection inputs such as MetadataInput, TagMapInput, etc.
//
// Override [validators] for map-level rules (e.g., minimum
// entry count) and [valueValidators] for per-value rules.
//
// Usage:
//   class MetadataInput extends MapInput<String, String, MyError>
//       with InputMixin<Map<String, String>, MyError, MetadataInput> {
//     const MetadataInput.untouched() : super.untouched();
//     const MetadataInput.touched({super.value}) : super.touched();
//     MetadataInput._(super.data) : super.fromData();
//
//     @override
//     List<Validator<String, MyError>> get valueValidators =>
//         [StringValidator.required(MyError.emptyValue)];
//
//     @override
//     MetadataInput update({...}) => MetadataInput._(prepareUpdate(...));
//   }
// ─────────────────────────────────────────────────────────────
abstract class MapInput<K, V, E> extends FormInput<Map<K, V>, E> {
  const MapInput.untouched({
    super.value = const {},
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const MapInput.touched({
    super.value = const {},
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  @protected
  MapInput.fromData(super.data) : super.fromData();

  // ── Per-value validators and sanitizers ──────────────────

  /// Validators applied to every individual value in the map.
  List<Validator<V, E>> get valueValidators => const [];

  /// Sanitizers applied to every individual value in the map.
  List<Sanitizer<V>> get valueSanitizers => const [];

  // ── Overridden pipeline hooks ─────────────────────────────

  /// Validates the map structure first, then each value individually.
  @override
  E? validate(Map<K, V> value) {
    final structError = ValidatorPipeline.validate(value, validators);
    if (structError != null) return structError;

    if (valueValidators.isNotEmpty) {
      for (final val in value.values) {
        final err = ValidatorPipeline.validate(val, valueValidators);
        if (err != null) return err;
      }
    }

    return null;
  }

  /// Sanitizes each value through [valueSanitizers] after running
  /// map-level sanitizers from [sanitizers].
  @override
  Map<K, V> sanitize(Map<K, V> value) {
    var result = super.sanitize(value);

    if (valueSanitizers.isNotEmpty) {
      result = result.map(
        (key, val) => MapEntry(key, SanitizerPipeline.sanitize(val, valueSanitizers)),
      );
    }

    return result;
  }

  // ── Lookup helpers ────────────────────────────────────────

  /// Returns the validation error for the value at [key], or null if the key
  /// does not exist or the value is valid.
  E? valueErrorAt(K key) {
    if (!value.containsKey(key)) return null;
    return ValidatorPipeline.validate(value[key] as V, valueValidators);
  }

  // ── Mutation helpers ──────────────────────────────────────
  // These create a new map reference so that == equality checks trigger
  // UI rebuilds in Bloc / Riverpod.

  /// Inserts or replaces the entry at [key] with [item], runs [valueSanitizers]
  /// on the item, and marks the input as touched.
  MapInput<K, V, E> putItem(K key, V item) {
    final sanitized = SanitizerPipeline.sanitize(item, valueSanitizers);
    final newMap = Map<K, V>.of(value)..[key] = sanitized;
    return update(value: newMap, status: InputStatus.touched);
  }

  /// Removes the entry at [key] and marks the input as touched.
  /// Returns [this] unchanged if [key] is not present.
  MapInput<K, V, E> removeItem(K key) {
    if (!value.containsKey(key)) return this;
    final newMap = Map<K, V>.of(value)..remove(key);
    return update(value: newMap, status: InputStatus.touched);
  }

  @override
  MapInput<K, V, E> update({
    Map<K, V>? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  });
}

// ─────────────────────────────────────────────────────────────
// Concrete — use directly for one-off key-value collection fields.
//
// Usage:
//   final labels = SimpleMapInput<String, String, String>.untouched(
//     valueValidators: [StringValidator.required('Value cannot be empty')],
//   );
// ─────────────────────────────────────────────────────────────
final class SimpleMapInput<K, V, E> extends MapInput<K, V, E>
    with InputMixin<Map<K, V>, E, SimpleMapInput<K, V, E>> {
  final List<Validator<Map<K, V>, E>> _validators;
  final List<Sanitizer<Map<K, V>>> _sanitizers;
  final List<Validator<V, E>> _valueValidators;
  final List<Sanitizer<V>> _valueSanitizers;

  const SimpleMapInput.untouched({
    super.value = const {},
    super.mode,
    super.errorCache,
    List<Validator<Map<K, V>, E>> validators = const [],
    List<Sanitizer<Map<K, V>>> sanitizers = const [],
    List<Validator<V, E>> valueValidators = const [],
    List<Sanitizer<V>> valueSanitizers = const [],
  }) : _validators = validators,
       _sanitizers = sanitizers,
       _valueValidators = valueValidators,
       _valueSanitizers = valueSanitizers,
       super.untouched();

  const SimpleMapInput.touched({
    super.value = const {},
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    List<Validator<Map<K, V>, E>> validators = const [],
    List<Sanitizer<Map<K, V>>> sanitizers = const [],
    List<Validator<V, E>> valueValidators = const [],
    List<Sanitizer<V>> valueSanitizers = const [],
  }) : _validators = validators,
       _sanitizers = sanitizers,
       _valueValidators = valueValidators,
       _valueSanitizers = valueSanitizers,
       super.touched();

  SimpleMapInput._(
    super.data,
    this._validators,
    this._sanitizers,
    this._valueValidators,
    this._valueSanitizers,
  ) : super.fromData();

  @override
  List<Validator<Map<K, V>, E>> get validators => _validators;

  @override
  List<Sanitizer<Map<K, V>>> get sanitizers => _sanitizers;

  @override
  List<Validator<V, E>> get valueValidators => _valueValidators;

  @override
  List<Sanitizer<V>> get valueSanitizers => _valueSanitizers;

  /// Narrows the return type to [SimpleMapInput<K, V, E>].
  @override
  SimpleMapInput<K, V, E> putItem(K key, V item) =>
      super.putItem(key, item) as SimpleMapInput<K, V, E>;

  /// Narrows the return type to [SimpleMapInput<K, V, E>].
  @override
  SimpleMapInput<K, V, E> removeItem(K key) => super.removeItem(key) as SimpleMapInput<K, V, E>;

  @override
  SimpleMapInput<K, V, E> update({
    Map<K, V>? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => SimpleMapInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
    _validators,
    _sanitizers,
    _valueValidators,
    _valueSanitizers,
  );
}
