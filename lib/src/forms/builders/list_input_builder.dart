// lib/src/forms/builders/list_input_builder.dart

import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/inputs/list_input.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validators/list_validator.dart';
import 'package:flux_form/src/validation/validators/logic_validator.dart';

/// A fluent builder that composes list-level and item-level validators and
/// sanitizers into a concrete [ListInput<T, E>].
///
/// Methods are grouped into two sets:
/// - **List-level** (no prefix): rules that apply to the whole list
///   (e.g., minimum count, uniqueness).
/// - **Item-level** (`item` prefix): rules applied individually to each
///   item in the list.
///
/// ```dart
/// final tags = ListInputBuilder<String, String>()
///   .minLength(1, 'Add at least one tag')
///   .maxLength(10, 'Too many tags')
///   .unique('Tags must be unique')
///   .itemTrim()
///   .itemToLowerCase()
///   .itemValidate(StringValidator.required('Tag cannot be empty'))
///   .mode(ValidationMode.live)
///   .buildUntouched();
/// ```
class ListInputBuilder<T, E> {
  final List<Validator<List<T>, E>> _validators = [];
  final List<Sanitizer<List<T>>> _sanitizers = [];
  final List<Validator<T, E>> _itemValidators = [];
  final List<Sanitizer<T>> _itemSanitizers = [];
  ValidationMode _mode = ValidationMode.live;

  // ── List-level ListValidator shortcuts ────────────────────

  ListInputBuilder<T, E> notEmpty(E error) => _v(ListValidator.notEmpty(error));

  ListInputBuilder<T, E> minLength(int min, E error) => _v(ListValidator.minLength(min, error));

  ListInputBuilder<T, E> maxLength(int max, E error) => _v(ListValidator.maxLength(max, error));

  ListInputBuilder<T, E> unique(E error) => _v(ListValidator.unique(error));

  ListInputBuilder<T, E> contains(T candidate, E error) =>
      _v(ListValidator.contains(candidate, error));

  ListInputBuilder<T, E> containsAll(List<T> candidates, E error) =>
      _v(ListValidator.containsAll(candidates, error));

  ListInputBuilder<T, E> containsNone(List<T> forbidden, E error) =>
      _v(ListValidator.containsNone(forbidden, error));

  ListInputBuilder<T, E> allMatch(bool Function(T) predicate, E error) =>
      _v(ListValidator.allMatch(predicate, error));

  ListInputBuilder<T, E> noneMatch(bool Function(T) predicate, E error) =>
      _v(ListValidator.noneMatch(predicate, error));

  ListInputBuilder<T, E> minUnique(int min, E error) => _v(ListValidator.minUnique(min, error));

  ListInputBuilder<T, E> maxUnique(int max, E error) => _v(ListValidator.maxUnique(max, error));

  // ── List-level LogicValidator shortcuts ───────────────────

  ListInputBuilder<T, E> when({
    required bool Function() condition,
    required Validator<List<T>, E> validator,
  }) => _v(LogicValidator.when(condition: condition, validator: validator));

  ListInputBuilder<T, E> unless({
    required bool Function() condition,
    required Validator<List<T>, E> validator,
  }) => _v(LogicValidator.unless(condition: condition, validator: validator));

  // ── List-level escape hatches ─────────────────────────────

  ListInputBuilder<T, E> validate(Validator<List<T>, E> validator) => _v(validator);

  ListInputBuilder<T, E> sanitize(Sanitizer<List<T>> sanitizer) => _s(sanitizer);

  // ── Item-level rules ──────────────────────────────────────

  /// Adds a per-item validator. Checked against each item individually.
  ListInputBuilder<T, E> itemValidate(Validator<T, E> validator) => _iv(validator);

  /// Adds a per-item sanitizer. Applied to each item before storage.
  ListInputBuilder<T, E> itemSanitize(Sanitizer<T> sanitizer) => _is(sanitizer);

  // ── Mode ──────────────────────────────────────────────────

  ListInputBuilder<T, E> mode(ValidationMode mode) {
    _mode = mode;
    return this;
  }

  // ── Build ─────────────────────────────────────────────────

  SimpleListInput<T, E> buildUntouched({List<T> value = const []}) => SimpleListInput.untouched(
    value: value,
    validators: List.unmodifiable(_validators),
    sanitizers: List.unmodifiable(_sanitizers),
    itemValidators: List.unmodifiable(_itemValidators),
    itemSanitizers: List.unmodifiable(_itemSanitizers),
    mode: _mode,
  );

  SimpleListInput<T, E> buildTouched({List<T> value = const [], E? remoteError}) => SimpleListInput.touched(
    value: value,
    validators: List.unmodifiable(_validators),
    sanitizers: List.unmodifiable(_sanitizers),
    itemValidators: List.unmodifiable(_itemValidators),
    itemSanitizers: List.unmodifiable(_itemSanitizers),
    mode: _mode,
    remoteError: remoteError,
  );

  // ── Internal helpers ──────────────────────────────────────

  ListInputBuilder<T, E> _v(Validator<List<T>, E> v) {
    _validators.add(v);
    return this;
  }

  ListInputBuilder<T, E> _s(Sanitizer<List<T>> s) {
    _sanitizers.add(s);
    return this;
  }

  ListInputBuilder<T, E> _iv(Validator<T, E> v) {
    _itemValidators.add(v);
    return this;
  }

  ListInputBuilder<T, E> _is(Sanitizer<T> s) {
    _itemSanitizers.add(s);
    return this;
  }
}
