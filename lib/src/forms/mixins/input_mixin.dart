import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';

/// A mixin that provides fluent convenience methods for [FormInput] subclasses.
///
/// [T] - Value Type
/// [E] - Error Type
/// [I] - The concrete Input class (e.g., StringInput)
///
/// Usage:
/// ```dart
/// class StringInput extends FormInput<String, String>
///     with InputMixin<String, String, StringInput> { ... }
mixin InputMixin<T, E, I extends FormInput<T, E>> on FormInput<T, E> {
  /// Updates the value and marks the field as [InputStatus.touched].
  /// Use this for standard user interactions (typing, checking boxes).
  I replaceValue(T value) => update(value: value, status: .touched) as I;

  /// Updates the value but keeps the current status (touched/untouched).
  /// Useful for programmatic updates where you don't want to trigger validation errors yet.
  I setValue(T value) => update(value: value) as I;

  /// Resets the input to its [initialValue] and [InputStatus.untouched].
  I reset() => update(value: initialValue, status: .untouched, remoteError: null) as I;

  /// Manually marks the field as touched without changing the value.
  /// Useful for "Validate on Blur" logic.
  I markTouched() => update(status: InputStatus.touched) as I;

  /// Manually marks the field as untouched.
  I markUntouched() => update(status: InputStatus.untouched) as I;

  /// Injects an external error (e.g., from an API response).
  /// This will take precedence over local validation.
  I setRemoteError(E error) => update(remoteError: error) as I;

  /// Clears any existing remote error.
  I clearRemoteError() => update(remoteError: null) as I;

  /// Changes the validation mode dynamically.
  I setMode(ValidationMode mode) => update(mode: mode) as I;
}
