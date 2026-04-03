// lib/src/forms/mixins/input_mixin.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';

/// A mixin that provides fluent convenience methods for [FormInput] subclasses.
///
/// [T] - Value type
/// [E] - Error type
/// [I] - The concrete input class (e.g., `EmailInput`)
///
/// Usage:
/// ```dart
/// class EmailInput extends StringInput<AuthError>
///     with InputMixin<String, AuthError, EmailInput> { ... }
/// ```
mixin InputMixin<T, E, I extends FormInput<T, E>> on FormInput<T, E> {
  // ── Synchronous mutators ──────────────────────────────────

  /// Updates the value, runs validation, and marks the input as [InputStatus.touched].
  ///
  /// Use this for standard user interactions (typing, selecting).
  I replaceValue(T value) => update(value: value, status: InputStatus.touched) as I;

  /// Updates the value but preserves the current [InputStatus].
  ///
  /// Use this for programmatic value changes where you do NOT want to trigger
  /// validation display yet. Pair with [ValidationMode.blur]: call [setValue]
  /// in `onChanged`, then [markTouched] in `onEditingComplete`.
  I setValue(T value) => update(value: value) as I;

  /// Reverts the input to its [FormInput.initialValue] and [InputStatus.untouched].
  ///
  /// ⚠️  Known limitation for nullable [T]: see [FormInput.prepareUpdate].
  I reset() => update(value: initialValue, status: InputStatus.untouched, remoteError: null) as I;

  /// Marks the field as [InputStatus.touched] without changing the value.
  ///
  /// Useful for [ValidationMode.blur]: call this in `onEditingComplete` or a
  /// [FocusNode] listener to reveal the error only after the user leaves the field.
  I markTouched() => update(status: InputStatus.touched) as I;

  /// Marks the field as [InputStatus.untouched] without changing the value.
  I markUntouched() => update(status: InputStatus.untouched) as I;

  /// Sets the status to [InputStatus.validating].
  ///
  /// Call this immediately before awaiting an async task. Prefer the higher-level
  /// [runAsync] which handles the full lifecycle automatically.
  I markValidating() => update(status: InputStatus.validating) as I;

  /// Injects an external error (e.g., "Email already taken" from an API response).
  ///
  /// The remote error takes precedence over local validation errors and is
  /// automatically cleared when the user modifies the field.
  I setRemoteError(E error) => update(remoteError: error) as I;

  /// Clears any existing remote error.
  I clearRemoteError() => update(remoteError: null) as I;

  /// Changes the [ValidationMode] dynamically.
  I setMode(ValidationMode mode) => update(mode: mode) as I;

  // ── Async validation lifecycle ────────────────────────────

  /// Resolves the result of an async validation operation.
  ///
  /// - If [error] is non-null, sets a remote error and marks the field touched.
  /// - If [error] is null, clears any previous remote error and marks touched.
  ///
  /// Prefer [runAsync] which calls this automatically.
  I resolveAsyncValidation(E? error) {
    if (error != null) {
      return update(remoteError: error, status: InputStatus.touched) as I;
    } else {
      return update(remoteError: null, status: InputStatus.touched) as I;
    }
  }

  /// Runs an async validation task through the standard lifecycle:
  /// `markValidating` → `await task` → `resolveAsyncValidation`.
  ///
  /// [onValidating] is called **synchronously** with the validating state so you
  /// can emit it to the UI immediately (showing a spinner). The method then
  /// awaits [task] and returns the fully resolved input.
  ///
  /// Typical Cubit usage:
  /// ```dart
  /// Future<void> usernameChanged(String value) async {
  ///   // 1. Update the raw value (no touch yet)
  ///   emit(state.copyWith(
  ///     schema: state.schema.copyWith(username: state.schema.username.setValue(value)),
  ///   ));
  ///
  ///   // 2. Run the async check
  ///   final resolved = await state.schema.username.runAsync(
  ///     task: () => api.checkUsername(value),
  ///     onValidating: (validating) => emit(
  ///       state.copyWith(schema: state.schema.copyWith(username: validating)),
  ///     ),
  ///   );
  ///
  ///   // 3. Emit the final result
  ///   emit(state.copyWith(schema: state.schema.copyWith(username: resolved)));
  /// }
  /// ```
  Future<I> runAsync({
    required Future<E?> Function() task,
    required void Function(I validating) onValidating,
  }) async {
    onValidating(markValidating());
    final error = await task();
    return resolveAsyncValidation(error);
  }

  /// Convenience wrapper for [runAsync] that uses the declared [asyncValidators].
  ///
  /// Use this when async rules are defined as [FormInput.asyncValidators] on
  /// the input class rather than provided inline:
  ///
  /// ```dart
  /// final resolved = await state.schema.username.runBuiltInAsyncValidation(
  ///   onValidating: (v) => emit(state.copyWith(
  ///     schema: state.schema.copyWith(username: v),
  ///   )),
  /// );
  /// emit(state.copyWith(schema: state.schema.copyWith(username: resolved)));
  /// ```
  Future<I> runBuiltInAsyncValidation({
    required void Function(I validating) onValidating,
  }) => runAsync(
    task: () => validateAsync(value),
    onValidating: onValidating,
  );
}
