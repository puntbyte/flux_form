// lib/src/forms/mixins/form_mixin.dart

import 'package:flux_form/flux_form.dart';

/// A mixin for State classes that manage inputs individually,
/// rather than through a [FormSchema].
///
/// This is the Formz-style alternative for those who prefer to hold
/// inputs directly on their state class rather than in a schema:
///
/// ```dart
/// class LoginState with FormMixin {
///   final EmailInput email;
///   final PasswordInput password;
///   final SubmissionStatus status;
///
///   const LoginState({
///     this.email = const EmailInput.untouched(),
///     this.password = const PasswordInput.untouched(),
///     this.status = SubmissionStatus.idle,
///   });
///
///   @override
///   List<FormInput> get inputs => [email, password];
/// }
/// ```
///
/// Note: Unlike [FormSchema], [FormMixin] cannot reconstruct itself — its
/// [touchAll] and [reset] methods return plain lists that you unpack into
/// your state's [copyWith]. If you prefer automatic reconstruction, use
/// [FormSchema] with [FormSchema.touchAll] / [FormSchema.reset] instead.
mixin FormMixin {
  /// All inputs managed by this state.
  ///
  /// The order determines the order of [invalidInputs] and [errors].
  List<FormInput<dynamic, dynamic>> get inputs;

  // ── Aggregate validity ────────────────────────────────────

  bool get isValid => FormValidator.validate(inputs);

  bool get isNotValid => !isValid;

  bool get isUntouched => FormValidator.isUntouched(inputs);

  bool get isTouched => FormValidator.isTouched(inputs);

  // ── Error access ──────────────────────────────────────────

  /// Returns every input that is currently invalid, in [inputs] order.
  List<FormInput<dynamic, dynamic>> get invalidInputs => FormValidator.validateGranularly(inputs);

  /// Returns every non-null error from every input in [inputs] order.
  ///
  /// Useful for building an error-summary widget.
  List<dynamic> get errors => inputs.map((input) => input.error).whereType<Object>().toList();

  // ── Bulk mutations ────────────────────────────────────────

  /// Returns a new list with every input marked [InputStatus.touched].
  ///
  /// Because [FormMixin] cannot reconstruct itself, you must manually
  /// unpack the result into your state's [copyWith]:
  ///
  /// ```dart
  /// Future<void> submit() async {
  ///   if (isNotValid) {
  ///     final touched = touchAll();
  ///     emit(state.copyWith(
  ///       email: touched[0] as EmailInput,
  ///       password: touched[1] as PasswordInput,
  ///       status: SubmissionStatus.failure,
  ///     ));
  ///     return;
  ///   }
  ///   // proceed ...
  /// }
  /// ```
  ///
  /// If you find yourself doing this often, consider switching to
  /// [FormSchema] which handles reconstruction automatically.
  List<FormInput<dynamic, dynamic>> touchAll() =>
      inputs.map((input) => input.update(status: InputStatus.touched)).toList();

  /// Returns a new list with every input reset to its [FormInput.initialValue]
  /// and [InputStatus.untouched].
  ///
  /// ⚠️  Known limitation: for inputs whose value type [T] is nullable
  /// (e.g., [DateTimeInput] where T = DateTime?), this may not correctly
  /// reset to null until the nullable sentinel fix (#13) is applied.
  List<FormInput<dynamic, dynamic>> reset() => inputs
      .map(
        (input) => input.update(
          value: input.initialValue,
          status: InputStatus.untouched,
        ),
      )
      .toList();
}
