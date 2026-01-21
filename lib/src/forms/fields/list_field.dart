import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/field.dart';
import 'package:flux_form/src/forms/mixins/field_cache_mixin.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizer_pipeline.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validator_pipeline.dart';

/// A field for managing dynamic lists with O(1) read performance.
///
/// Subclasses must override [copyWith] to ensure mutation methods return
/// the correct type.
class ListField<T, F> extends Field<List<T>, F> with FieldCacheMixin<List<T>, F> {
  /// Internal cache that stores BOTH the combined error and the specific item error.
  /// Used to satisfy @immutable requirements while keeping O(1) reads.
  late final ({F? combined, F? item}) _computation = _validateWithItemLogic();

  // ===========================================================================
  // CONSTRUCTORS (No const allowed due to Mixin)
  // ===========================================================================

  ListField.untouched({
    List<T> value = const [],
    super.mode,
  }) : super.untouched(value);

  ListField.touched({
    List<T> value = const [],
    super.mode,
    super.remoteError,
  }) : super.touched(value);

  List<Validator<List<T>, F>> get validators => [];

  List<Validator<T, F>> get itemValidators => [];

  List<Sanitizer<T>> get itemSanitizers => [];

  // ===========================================================================
  // VALIDATION
  // ===========================================================================

  /// Performs the actual O(N) validation logic once.
  ({F? combined, F? item}) _validateWithItemLogic() {
    // 1. Validate Structure (e.g. Min/Max length)
    final structError = ValidatorPipeline.validate(value, validators);

    // 2. Validate Items (e.g. Item not empty)
    F? firstItemError;
    if (itemValidators.isNotEmpty) {
      for (final item in value) {
        final err = ValidatorPipeline.validate(item, itemValidators);
        if (err != null) {
          firstItemError = err;
          break; // Stop at first error
        }
      }
    }

    return (combined: structError ?? firstItemError, item: firstItemError);
  }

  @override
  F? validate(List<T> value) {
    // The Mixin calls this. We delegate to our cached computation.
    return _computation.combined;
  }

  /// Returns the first error found inside the items.
  F? get itemError => _computation.item;

  /// Returns the specific validation error for the item at [index].
  /// This runs validation ON-DEMAND for that specific item (fast).
  F? getItemError(int index) {
    if (index < 0 || index >= value.length) return null;
    return ValidatorPipeline.validate(value[index], itemValidators);
  }

  // ===========================================================================
  // MUTATION HELPERS
  // ===========================================================================

  ListField<T, F> addItem(T item) {
    final sanitized = SanitizerPipeline.sanitize(item, itemSanitizers);
    final newList = List<T>.from(value)..add(sanitized);
    return copyWith(value: newList, isTouched: true);
  }

  ListField<T, F> setItem(int index, T newItem) {
    if (index < 0 || index >= value.length) return this;
    final sanitized = SanitizerPipeline.sanitize(newItem, itemSanitizers);
    final newList = List<T>.from(value);
    newList[index] = sanitized;
    return copyWith(value: newList, isTouched: true);
  }

  ListField<T, F> removeItemAt(int index) {
    if (index < 0 || index >= value.length) return this;
    final newList = List<T>.from(value)..removeAt(index);
    return copyWith(value: newList, isTouched: true);
  }

  @override
  ListField<T, F> copyWith({
    List<T>? value,
    bool? isTouched,
    ValidationMode? mode,
    F? remoteError,
  }) {
    if ((isTouched ?? false) || this.isTouched) {
      return ListField.touched(
        value: value ?? this.value,
        mode: mode ?? this.mode,
        remoteError: remoteError ?? error,
      );
    } else {
      return ListField.untouched(
        value: value ?? this.value,
        mode: mode ?? this.mode,
      );
    }
  }
}
