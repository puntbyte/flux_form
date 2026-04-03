// lib/inputs/shared_inputs.dart
//
// Reusable, domain-typed inputs that extend the abstract base classes.
// Each one locks in validators, sanitizers, and ValidationMode once.
// Reused across Login, Wizard, and EditProfile — no copy-paste.

import 'package:example/errors/auth_error.dart';
import 'package:flux_form/flux_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EmailInput
//
// Demonstrates:
//   • Extending abstract StringInput<E> with InputMixin
//   • ValidationMode.deferred — error hidden until submit fails
//   • Sanitizer pipeline: trim → toLowerCase
//   • Validator.compose — reusable named rule set
// ─────────────────────────────────────────────────────────────────────────────

/// Shared reusable email rule set built with [Validator.compose].
///
/// Compose lets you name a pipeline once and reuse it across multiple inputs:
/// EmailInput, RecoveryEmailInput, InviteEmailInput — all share the same rules.
final Validator<String, AuthError> emailRules = Validator.compose<String, AuthError>([
  const StringValidator.required(AuthError.required),
  const FormatValidator.email(AuthError.invalidEmail),
]);

/// Shared reusable email sanitizer built with [Sanitizer.compose].
final Sanitizer<String> emailSanitizers = Sanitizer.compose<String>([
  const StringSanitizer.trim(),
  const StringSanitizer.toLowerCase(),
]);

class EmailInput extends StringInput<AuthError>
    with InputMixin<String, AuthError, EmailInput> {
  const EmailInput.untouched({super.value = ''})
      : super.untouched(mode: ValidationMode.deferred);

  const EmailInput.touched({super.value = '', super.remoteError})
      : super.touched(mode: ValidationMode.deferred);

  EmailInput._(super.data) : super.fromData();

  @override
  List<Sanitizer<String>> get sanitizers => [emailSanitizers];

  @override
  List<Validator<String, AuthError>> get validators => [emailRules];

  @override
  EmailInput update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    AuthError? remoteError,
  }) => EmailInput._(prepareUpdate(
    value: value, status: status, mode: mode, remoteError: remoteError,
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
// PasswordInput
//
// Demonstrates:
//   • ValidationMode.live — error visible while typing
//   • detailedErrors for a password-strength meter (see LoginPage)
//   • Multiple granular validators (each maps to one strength requirement)
// ─────────────────────────────────────────────────────────────────────────────

class PasswordInput extends StringInput<AuthError>
    with InputMixin<String, AuthError, PasswordInput> {
  const PasswordInput.untouched({super.value = ''})
      : super.untouched(mode: ValidationMode.live);

  const PasswordInput.touched({super.value = ''})
      : super.touched(mode: ValidationMode.live);

  PasswordInput._(super.data) : super.fromData();

  /// Individual validators (not composed) so [detailedErrors] can surface
  /// each unmet requirement independently for the strength meter.
  @override
  List<Validator<String, AuthError>> get validators => [
    const StringValidator.required(AuthError.required),
    const StringValidator.minLength(8, AuthError.tooShort),
    const StringValidator.hasUppercase(AuthError.noUppercase),
    const StringValidator.hasDigit(AuthError.noDigit),
    const StringValidator.hasSpecialChar(AuthError.noSpecialChar),
  ];

  @override
  PasswordInput update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    AuthError? remoteError,
  }) => PasswordInput._(prepareUpdate(
    value: value, status: status, mode: mode, remoteError: remoteError,
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
// UsernameInput
//
// Demonstrates:
//   • ValidationMode.blur — error shown only after the field loses focus
//   • asyncValidators getter — async rules live next to sync rules
//   • runBuiltInAsyncValidation / runAsync (called from the Cubit)
// ─────────────────────────────────────────────────────────────────────────────

class UsernameInput extends StringInput<AuthError>
    with InputMixin<String, AuthError, UsernameInput> {
  const UsernameInput.untouched({super.value = ''})
      : super.untouched(mode: ValidationMode.blur);

  const UsernameInput.touched({super.value = '', super.remoteError})
      : super.touched(mode: ValidationMode.blur);

  UsernameInput._(super.data) : super.fromData();

  @override
  List<Sanitizer<String>> get sanitizers => [
    const StringSanitizer.trim(),
    const StringSanitizer.toLowerCase(),
  ];

  @override
  List<Validator<String, AuthError>> get validators => [
    const StringValidator.required(AuthError.required),
    const StringValidator.minLength(3, AuthError.tooShort),
    // Only alphanumeric characters allowed
    StringValidator.pattern(RegExp(r'^[a-z0-9_]+$'), AuthError.unknown),
  ];

  /// Async validators — checked via [runBuiltInAsyncValidation].
  @override
  List<AsyncValidator<String, AuthError>> get asyncValidators => [
    const _UsernameAvailabilityValidator(),
  ];

  @override
  UsernameInput update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    AuthError? remoteError,
  }) => UsernameInput._(prepareUpdate(
    value: value, status: status, mode: mode, remoteError: remoteError,
  ));
}

/// Simulates a server-side username availability check.
///
/// Demonstrates [AsyncValidator] — a separate class with a [Future<E?>] validate method.
/// Registered on [UsernameInput.asyncValidators] so the Cubit can call
/// [InputMixin.runBuiltInAsyncValidation] without hardcoding the task.
class _UsernameAvailabilityValidator extends AsyncValidator<String, AuthError> {
  const _UsernameAvailabilityValidator() : super(AuthError.usernameTaken);

  static const _takenUsernames = {'admin', 'root', 'flux', 'test'};

  @override
  Future<AuthError?> validate(String value) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    return _takenUsernames.contains(value.toLowerCase())
        ? AuthError.usernameTaken
        : null;
  }
}