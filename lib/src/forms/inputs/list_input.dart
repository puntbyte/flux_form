import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizer_pipeline.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validator_pipeline.dart';

/// A field for managing dynamic lists.
class ListInput<T, E> extends FormInput<List<T>, E> {
  /// Stores the specific error found in an item (if any).
  /// This is calculated during [update] to avoid re-looping on getters.
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

  List<Validator<T, E>> get itemValidators => [];

  List<Sanitizer<T>> get itemSanitizers => [];

  @override
  E? validate(List<T> value) {
    // 1. Validate Structure
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

  /// Returns the first error found inside the items (excluding structure errors).
  /// O(1) access.
  E? get itemError => _firstItemError;

  /// Returns the specific validation error for the item at [index].
  /// Runs on-demand.
  E? getItemError(int index) {
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
    final rawValue = value ?? this.value;

    // 1. Resolve Touched & Remote
    final effectiveTouched = (isTouched ?? false) || isTouched;
    final valueChanged = value != null && value != this.value;

    // ⚡️ FIX: Use 'currentRemoteError' (the protected getter)
    final effectiveRemote = (remoteError != null)
        ? remoteError
        : (valueChanged ? null : currentRemoteError);

    // 2. Custom Validation Logic (Single Pass)
    final structError = ValidatorPipeline.validate(rawValue, validators);
    E? itemErr;

    if (structError == null && itemValidators.isNotEmpty) {
      for (final item in rawValue) {
        final err = ValidatorPipeline.validate(item, itemValidators);
        if (err != null) {
          itemErr = err;
          break;
        }
      }
    }

    final computedError = structError ?? itemErr;

    // 3. Return Instance
    if (effectiveTouched) {
      return ListInput.touched(
        value: rawValue,
        initialValue: initialValue,
        mode: mode ?? this.mode,
        remoteError: effectiveRemote,
        errorCache: computedError,
        firstItemError: itemErr,
      );
    } else {
      return ListInput.untouched(
        value: rawValue,
        mode: mode ?? this.mode,
        errorCache: computedError,
      );
    }
  }

  // ===========================================================================
  // MUTATION HELPERS
  // ===========================================================================

  ListInput<T, E> addItem(T item) {
    final sanitized = SanitizerPipeline.sanitize(item, itemSanitizers);
    final newList = List<T>.from(value)..add(sanitized);

    return update(value: newList, status: .touched);
  }

  ListInput<T, E> setItem(int index, T newItem) {
    if (index < 0 || index >= value.length) return this;
    final sanitized = SanitizerPipeline.sanitize(newItem, itemSanitizers);
    final newList = List<T>.from(value);
    newList[index] = sanitized;

    return update(value: newList, status: .touched);
  }

  ListInput<T, E> removeItemAt(int index) {
    if (index < 0 || index >= value.length) return this;
    final newList = List<T>.from(value)..removeAt(index);

    return update(value: newList, status: .touched);
  }
}
