// lib/src/forms/enums/validation_mode.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/submission_status.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';

/// Controls **when** a field's validation error becomes visible in the UI.
///
/// Pass one of these values to an input's `mode` parameter:
/// ```dart
/// const EmailInput.untouched({super.value = ''})
///     : super.untouched(mode: ValidationMode.deferred);
/// ```
///
/// All three modes share the same underlying display logic in
/// [FormInput.displayError]:
/// - `failure` status always reveals errors, regardless of mode.
/// - Otherwise, `deferred` hides errors; `live` and `blur` reveal them only
///   once the field is touched.
///
/// The difference between [live] and [blur] is **not** enforced by the library
/// at runtime — it is a **UI contract** you establish in your widget layer.
enum ValidationMode {
  /// Errors are hidden until [SubmissionStatus.failure].
  ///
  /// The error is never shown while the user is typing. It only appears after
  /// a failed submit attempt sets the global status to
  /// [SubmissionStatus.failure]. This is the least intrusive mode — the user
  /// gets no inline feedback until they try to submit.
  ///
  /// **Best for:** Email, username, and other fields where showing an error
  /// mid-typing would feel aggressive.
  ///
  /// **Widget contract:** call `replaceValue()` in `onChanged` as usual.
  ///
  /// ```dart
  /// TextField(
  ///   onChanged: (v) => cubit.emailChanged(v),
  ///   decoration: InputDecoration(
  ///     // Error is hidden until the first failed submit.
  ///     errorText: state.form.email.displayError(state.status),
  ///   ),
  /// )
  /// ```
  deferred,

  /// Errors appear immediately as the user types, once the field is touched.
  ///
  /// As soon as the user begins interacting with the field ([replaceValue]
  /// marks it as [InputStatus.touched]), errors become visible on the next
  /// value change. This mode gives the tightest feedback loop.
  ///
  /// **Best for:** Password strength, search bars, and fields where real-time
  /// correction is desirable.
  ///
  /// **Widget contract:** call `replaceValue()` in `onChanged`.
  ///
  /// ```dart
  /// TextField(
  ///   onChanged: (v) => cubit.passwordChanged(v),
  ///   decoration: InputDecoration(
  ///     // Error visible while typing as soon as the field is dirty.
  ///     errorText: state.form.password.displayError(state.status),
  ///   ),
  /// )
  /// ```
  live,

  /// Errors appear only after the user has finished interacting with the field.
  ///
  /// ## Runtime behaviour
  /// At runtime, [blur] is **identical to [live]**: [FormInput.displayError]
  /// reveals the error as soon as [InputStatus.touched]. The library itself
  /// has no access to focus events — focus is a UI-framework concept.
  ///
  /// The distinction is a **UI contract you own in your widget layer**:
  ///
  /// - Use [InputMixin.setValue] in `onChanged` (updates value, does NOT mark
  ///   touched → error stays hidden while the user types).
  /// - Use [InputMixin.markTouched] in `onEditingComplete`, a `FocusNode`
  ///   listener, or any equivalent "field left" callback (marks touched →
  ///   error becomes visible).
  ///
  /// By following this contract, the error only appears after the user moves
  /// on from the field, even though the library just sees "is it touched?".
  ///
  /// **Best for:** Fields where mid-type errors are distracting — username
  /// availability, confirmation fields, complex formatted inputs.
  ///
  /// **Widget contract:**
  /// ```dart
  /// // State management layer —
  /// void usernameChanged(String value) {
  ///   // setValue: no touch → error stays hidden while typing.
  ///   emit(state.copyWith(
  ///     form: state.form.copyWith(
  ///       username: state.form.username.setValue(value),
  ///     ),
  ///   ));
  /// }
  ///
  /// void usernameBlurred() {
  ///   // markTouched: error (if any) now becomes visible.
  ///   emit(state.copyWith(
  ///     form: state.form.copyWith(
  ///       username: state.form.username.markTouched(),
  ///     ),
  ///   ));
  /// }
  ///
  /// // Widget layer —
  /// TextField(
  ///   onChanged: (v) => cubit.usernameChanged(v),
  ///   onEditingComplete: cubit.usernameBlurred,
  ///   decoration: InputDecoration(
  ///     errorText: state.form.username.displayError(state.status),
  ///   ),
  /// )
  /// ```
  ///
  /// For async checks (e.g., username availability), combine with
  /// [InputMixin.runAsync]:
  /// ```dart
  /// Future<void> usernameBlurred() async {
  ///   final resolved = await state.form.username.runAsync(
  ///     task: () => api.checkUsername(state.form.username.value),
  ///     onValidating: (v) => emit(state.copyWith(
  ///       form: state.form.copyWith(username: v),
  ///     )),
  ///   );
  ///   emit(state.copyWith(form: state.form.copyWith(username: resolved)));
  /// }
  /// ```
  blur,
}
