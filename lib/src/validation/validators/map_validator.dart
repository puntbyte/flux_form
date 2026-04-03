// lib/src/validation/validators/map_validator.dart

import 'package:flux_form/src/validation/validator.dart';

/// A namespace for [Map]-level validation rules.
///
/// [MapValidator] validates the **map as a whole** — its size, required keys,
/// or whether all values satisfy a predicate. For per-value rules, add a
/// `Validator<V, E>` to your `MapInput.valueValidators` getter or to
/// `SimpleMapInput`'s `valueValidators` constructor parameter.
///
/// ```dart
/// class MetadataInput extends MapInput<String, String, MetaError>
///     with InputMixin<Map<String, String>, MetaError, MetadataInput> {
///   @override
///   List<Validator<Map<String, String>, MetaError>> get validators => [
///     MapValidator.minLength(1, MetaError.emptyMetadata),
///     MapValidator.requiresKeys(['title'], MetaError.missingTitle),
///   ];
///
///   // Per-value rule: each value must be non-blank.
///   @override
///   List<Validator<String, MetaError>> get valueValidators => [
///     StringValidator.required(MetaError.emptyValue),
///   ];
/// }
/// ```
abstract class MapValidator<K, V, E> extends Validator<Map<K, V>, E> {
  const MapValidator(super.error);

  /// Fails when the map is empty.
  const factory MapValidator.notEmpty(E error) = _NotEmptyMapValidator;

  /// Fails when the map has fewer than [min] entries.
  const factory MapValidator.minLength(int min, E error) = _MinLengthMapValidator;

  /// Fails when the map has more than [max] entries.
  const factory MapValidator.maxLength(int max, E error) = _MaxLengthMapValidator;

  /// Fails when the map does not contain [key].
  const factory MapValidator.containsKey(K key, E error) = _ContainsKeyMapValidator;

  /// Fails when the map is missing any of [keys].
  const factory MapValidator.requiresKeys(List<K> keys, E error) = _RequiresKeysMapValidator;

  /// Fails when any **value** in the map does not satisfy [predicate].
  ///
  /// Not `const` because it captures a function.
  const factory MapValidator.allValues(bool Function(V value) predicate, E error) =
      _AllValuesMapValidator;

  /// Fails when any **entry** in the map does not satisfy [predicate].
  ///
  /// Not `const` because it captures a function.
  const factory MapValidator.allEntries(
    bool Function(K key, V value) predicate,
    E error,
  ) = _AllEntriesMapValidator;
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementations
// ─────────────────────────────────────────────────────────────────────────────

class _NotEmptyMapValidator<K, V, E> extends MapValidator<K, V, E> {
  const _NotEmptyMapValidator(super.error);

  @override
  E? validate(Map<K, V> value) => value.isEmpty ? error : null;
}

class _MinLengthMapValidator<K, V, E> extends MapValidator<K, V, E> {
  final int min;

  const _MinLengthMapValidator(this.min, super.error);

  @override
  E? validate(Map<K, V> value) => value.length < min ? error : null;
}

class _MaxLengthMapValidator<K, V, E> extends MapValidator<K, V, E> {
  final int max;

  const _MaxLengthMapValidator(this.max, super.error);

  @override
  E? validate(Map<K, V> value) => value.length > max ? error : null;
}

class _ContainsKeyMapValidator<K, V, E> extends MapValidator<K, V, E> {
  final K key;

  const _ContainsKeyMapValidator(this.key, super.error);

  @override
  E? validate(Map<K, V> value) => value.containsKey(key) ? null : error;
}

class _RequiresKeysMapValidator<K, V, E> extends MapValidator<K, V, E> {
  final List<K> keys;

  const _RequiresKeysMapValidator(this.keys, super.error);

  @override
  E? validate(Map<K, V> value) {
    for (final key in keys) {
      if (!value.containsKey(key)) return error;
    }
    return null;
  }
}

class _AllValuesMapValidator<K, V, E> extends MapValidator<K, V, E> {
  final bool Function(V) predicate;

  const _AllValuesMapValidator(this.predicate, super.error);

  @override
  E? validate(Map<K, V> value) {
    for (final v in value.values) {
      if (!predicate(v)) return error;
    }
    return null;
  }
}

class _AllEntriesMapValidator<K, V, E> extends MapValidator<K, V, E> {
  final bool Function(K, V) predicate;

  const _AllEntriesMapValidator(this.predicate, super.error);

  @override
  E? validate(Map<K, V> value) {
    for (final entry in value.entries) {
      if (!predicate(entry.key, entry.value)) return error;
    }
    return null;
  }
}
