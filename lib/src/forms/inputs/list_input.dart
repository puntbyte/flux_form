// lib/src/forms/inputs/list_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:flux_form/src/forms/models/input_data.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizer_pipeline.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validator_pipeline.dart';
import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────
// Abstract base — extend this for domain-specific list inputs
// such as TagsInput, CartItemsInput, GroceryListInput, etc.
//
// Override [validators] for list-level rules (e.g. min/max length),
// [itemValidators] for per-item rules, and [itemSanitizers] to clean
// items before they are stored.
//
// Usage:
//   class GroceryListInput extends BaseListInput<String, String>
//       with InputMixin<List<String>, String, GroceryListInput> {
//     const GroceryListInput.untouched({super.value = const []})
//         : super.untouched(mode: ValidationMode.live);
//     const GroceryListInput.touched({super.value = const []})
//         : super.touched(mode: ValidationMode.live);
//     GroceryListInput._(super.data, super.firstItemError) : super.fromData();
//
//     @override
//     List<Validator<List<String>, String>> get validators => [
//       ListValidator.minLength(3, 'Need at least 3 items'),
//     ];
//
//     @override
//     List<Validator<String, String>> get itemValidators => [
//       StringValidator.required('Item cannot be empty'),
//     ];
//
//     @override
//     GroceryListInput update({...}) =>
//         GroceryListInput._(prepareUpdate(...), _computedItemError);
//   }
// ─────────────────────────────────────────────────────────────
abstract class ListInput<T, E> extends FormInput<List<T>, E> {
  /// Stores the first item-level error found during the last update cycle.
  /// This makes [itemError] an O(1) read instead of re-running validation.
  final E? _firstItemError;

  const ListInput.untouched({
    super.value = const [],
    super.mode,
    super.errorCache,
  }) : _firstItemError = null,
       super.untouched();

  const ListInput.touched({
    super.value = const [],
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    E? firstItemError,
  }) : _firstItemError = firstItemError,
       super.touched();

  @protected
  ListInput.fromData(super.data, E? firstItemError)
    : _firstItemError = firstItemError,
      super.fromData();

  // ── Per-item validators and sanitizers ───────────────────

  /// Validators applied to every individual item in the list.
  List<Validator<T, E>> get itemValidators => const [];

  /// Sanitizers applied to every individual item in the list.
  List<Sanitizer<T>> get itemSanitizers => const [];

  // ── Overridden pipeline hooks ─────────────────────────────

  /// Runs list-level [validators] first, then per-item [itemValidators].
  /// Both checks run in a single pass; item errors are cached in [_firstItemError].
  @override
  E? validate(List<T> value) {
    final structError = ValidatorPipeline.validate(value, validators);
    if (structError != null) return structError;

    if (itemValidators.isNotEmpty) {
      for (final item in value) {
        final err = ValidatorPipeline.validate(item, itemValidators);
        if (err != null) return err;
      }
    }

    return null;
  }

  /// Runs list-level [sanitizers], then [itemSanitizers] on each item.
  @override
  List<T> sanitize(List<T> value) {
    var result = super.sanitize(value);

    if (itemSanitizers.isNotEmpty) {
      result = result.map((item) => SanitizerPipeline.sanitize(item, itemSanitizers)).toList();
    }

    return result;
  }

  // ── Item error access ─────────────────────────────────────

  /// The first item-level error from the last update cycle (O(1) read).
  E? get itemError => _firstItemError;

  /// The validation error for the item at [index] (recomputes on each call).
  E? itemErrorAt(int index) {
    if (index < 0 || index >= value.length) return null;
    return ValidatorPipeline.validate(value[index], itemValidators);
  }

  @override
  ListInput<T, E> update({
    List<T>? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  });
}

// ─────────────────────────────────────────────────────────────
// Concrete — use directly for one-off list fields where
// subclassing is not worth the overhead.
//
// Accepts validators and sanitizers via constructor so you can
// compose rules inline without creating a subclass.
//
// Usage (direct composition):
//   final tags = ListInput<String, String>.untouched(
//     validators: [ListValidator.minLength(1, 'At least one tag required')],
//     itemValidators: [StringValidator.required('Tag cannot be empty')],
//     itemSanitizers: [StringSanitizer.trim(), StringSanitizer.toLowerCase()],
//   );
//
// Usage (quick mutation):
//   final updated = tags.addItem('flutter');
// ─────────────────────────────────────────────────────────────
final class SimpleListInput<T, E> extends ListInput<T, E>
    with InputMixin<List<T>, E, SimpleListInput<T, E>> {
  final List<Validator<List<T>, E>> _validators;
  final List<Sanitizer<List<T>>> _sanitizers;
  final List<Validator<T, E>> _itemValidators;
  final List<Sanitizer<T>> _itemSanitizers;

  const SimpleListInput.untouched({
    super.value = const [],
    super.mode,
    super.errorCache,
    List<Validator<List<T>, E>> validators = const [],
    List<Sanitizer<List<T>>> sanitizers = const [],
    List<Validator<T, E>> itemValidators = const [],
    List<Sanitizer<T>> itemSanitizers = const [],
  }) : _validators = validators,
       _sanitizers = sanitizers,
       _itemValidators = itemValidators,
       _itemSanitizers = itemSanitizers,
       super.untouched();

  const SimpleListInput.touched({
    super.value = const [],
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    super.firstItemError,
    List<Validator<List<T>, E>> validators = const [],
    List<Sanitizer<List<T>>> sanitizers = const [],
    List<Validator<T, E>> itemValidators = const [],
    List<Sanitizer<T>> itemSanitizers = const [],
  }) : _validators = validators,
       _sanitizers = sanitizers,
       _itemValidators = itemValidators,
       _itemSanitizers = itemSanitizers,
       super.touched();

  SimpleListInput._(
    super.data,
    super.firstItemError,
    this._validators,
    this._sanitizers,
    this._itemValidators,
    this._itemSanitizers,
  ) : super.fromData();

  @override
  List<Validator<List<T>, E>> get validators => _validators;

  @override
  List<Sanitizer<List<T>>> get sanitizers => _sanitizers;

  @override
  List<Validator<T, E>> get itemValidators => _itemValidators;

  @override
  List<Sanitizer<T>> get itemSanitizers => _itemSanitizers;

  // ── Mutation helpers ──────────────────────────────────────

  /// Sanitizes [item] through [itemSanitizers], appends it, and marks as touched.
  SimpleListInput<T, E> addItem(T item) {
    final sanitized = SanitizerPipeline.sanitize(item, _itemSanitizers);
    return update(value: List<T>.of(value)..add(sanitized), status: InputStatus.touched);
  }

  /// Replaces the item at [index] with [newItem] (sanitized) and marks as touched.
  /// Returns [this] unchanged if [index] is out of bounds.
  SimpleListInput<T, E> setItem(int index, T newItem) {
    if (index < 0 || index >= value.length) return this;
    final sanitized = SanitizerPipeline.sanitize(newItem, _itemSanitizers);
    return update(
      value: List<T>.of(value)..[index] = sanitized,
      status: InputStatus.touched,
    );
  }

  /// Removes the item at [index] and marks as touched.
  /// Returns [this] unchanged if [index] is out of bounds.
  SimpleListInput<T, E> removeItemAt(int index) {
    if (index < 0 || index >= value.length) return this;
    return update(
      value: List<T>.of(value)..removeAt(index),
      status: InputStatus.touched,
    );
  }

  @override
  SimpleListInput<T, E> update({
    List<T>? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) {
    final rawValue = value ?? this.value;
    final valueChanged = value != null && value != this.value;
    final effectiveStatus = status ?? this.status;

    // Mirror prepareUpdate's remote error resolution logic.
    E? effectiveRemote;
    if (remoteError != null) {
      effectiveRemote = remoteError;
    } else if (effectiveStatus == InputStatus.untouched) {
      effectiveRemote = null;
    } else if (valueChanged) {
      effectiveRemote = null;
    } else {
      effectiveRemote = currentRemoteError;
    }

    // Single-pass validation: structure errors take priority over item errors.
    final structError = ValidatorPipeline.validate(rawValue, _validators);
    E? itemErr;

    if (structError == null && _itemValidators.isNotEmpty) {
      for (final item in rawValue) {
        final err = ValidatorPipeline.validate(item, _itemValidators);
        if (err != null) {
          itemErr = err;
          break;
        }
      }
    }

    final computedError = structError ?? itemErr;

    final newData = InputData(
      value: rawValue,
      initialValue: initialValue,
      status: effectiveStatus,
      mode: mode ?? this.mode,
      remoteError: effectiveRemote,
      errorCache: computedError,
    );

    return SimpleListInput._(
      newData,
      itemErr,
      _validators,
      _sanitizers,
      _itemValidators,
      _itemSanitizers,
    );
  }
}
