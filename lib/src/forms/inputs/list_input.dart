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

/// Base class to avoid naming conflicts with the concrete implementation.
abstract class ListInputBase<T, E> extends FormInput<List<T>, E> {
  /// Stores the specific error found in an item (if any).
  final E? _firstItemError;

  const ListInputBase.untouched({
    super.value = const [],
    super.mode,
    super.errorCache,
  }) : _firstItemError = null,
       super.untouched();

  const ListInputBase.touched({
    super.value = const [],
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    E? firstItemError,
  }) : _firstItemError = firstItemError,
       super.touched();

  @protected
  ListInputBase.fromData(super.data, E? firstItemError)
    : _firstItemError = firstItemError,
      super.fromData();
}

/// A field for managing dynamic lists (e.g., Tags, Multi-selects).
class ListInput<T, E> extends ListInputBase<T, E> with InputMixin<List<T>, E, ListInput<T, E>> {
  const ListInput.untouched({
    super.value = const [],
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const ListInput.touched({
    super.value = const [],
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    super.firstItemError,
  }) : super.touched();

  ListInput._(super.data, super.firstItemError) : super.fromData();

  /// Define validators for individual items here.
  List<Validator<T, E>> get itemValidators => const [];

  /// Define sanitizers for individual items here.
  List<Sanitizer<T>> get itemSanitizers => const [];

  @override
  E? validate(List<T> value) {
    // 1. Validate Structure (e.g., ListMinLength)
    final structError = ValidatorPipeline.validate(value, validators);
    if (structError != null) return structError;

    // 2. Validate Items (Stop at first error)
    if (itemValidators.isNotEmpty) {
      for (final item in value) {
        final err = ValidatorPipeline.validate(item, itemValidators);
        if (err != null) return err;
      }
    }

    return null;
  }

  /// Returns the first error found inside the items.
  /// Useful for showing "Item #3 is invalid" in the UI.
  E? get itemError => _firstItemError;

  /// Returns the specific validation error for the item at [index].
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
  }) {
    // 1. Prepare basics
    final rawValue = value ?? this.value;
    final valueChanged = value != null && value != this.value;
    final effectiveStatus = status ?? this.status;

    // 2. Resolve Remote Error (Match standard prepareUpdate logic)
    E? effectiveRemote;
    if (remoteError != null) {
      effectiveRemote = remoteError;
    } else if (effectiveStatus == InputStatus.untouched) {
      effectiveRemote = null;
    } else if (valueChanged) {
      effectiveRemote = null; // Clear stale server error on change
    } else {
      effectiveRemote = currentRemoteError;
    }

    // 3. Optimized Validation (Single Pass)
    // We do this manually here (instead of calling super.validate) so we can
    // separate 'structError' from 'itemError' for the cache.
    final structError = ValidatorPipeline.validate(rawValue, validators);
    E? itemErr;

    if (structError == null && itemValidators.isNotEmpty) {
      for (final item in rawValue) {
        final err = ValidatorPipeline.validate(item, itemValidators);
        if (err != null) {
          itemErr = err;
          break; // Stop at first error
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

    return ListInput._(newData, itemErr);
  }

  @override
  List<T> sanitize(List<T> value) {
    // 1. Run list-level sanitizers (if any)
    var result = super.sanitize(value);

    // 2. Run item-level sanitizers
    if (itemSanitizers.isNotEmpty) {
      result = result.map((item) => SanitizerPipeline.sanitize(item, itemSanitizers)).toList();
    }

    return result;
  }

  ListInput<T, E> addItem(T item) {
    final sanitized = SanitizerPipeline.sanitize(item, itemSanitizers);
    // Use List.of to ensure a new mutable reference
    final newList = List<T>.of(value)..add(sanitized);

    return update(value: newList, status: InputStatus.touched);
  }

  ListInput<T, E> setItem(int index, T newItem) {
    if (index < 0 || index >= value.length) return this;
    final sanitized = SanitizerPipeline.sanitize(newItem, itemSanitizers);
    final newList = List<T>.of(value);
    newList[index] = sanitized;

    return update(value: newList, status: InputStatus.touched);
  }

  ListInput<T, E> removeItemAt(int index) {
    if (index < 0 || index >= value.length) return this;
    final newList = List<T>.of(value)..removeAt(index);

    return update(value: newList, status: InputStatus.touched);
  }
}
