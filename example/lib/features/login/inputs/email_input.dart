// features/login/inputs/email_input.dart

import 'package:example/features/login/models/auth_error.dart';
import 'package:flux_form/flux_form.dart';

class EmailInput extends StringInputBase<AuthError> with InputMixin<String, AuthError, EmailInput> {
  // Use Deferred mode: Error only shows after submit (or if remote error exists)
  const EmailInput.untouched({super.value}) : super.untouched(mode: ValidationMode.deferred);

  const EmailInput.touched({super.value, super.remoteError})
    : super.touched(mode: ValidationMode.deferred);

  // Private constructor for updates
  EmailInput._(super.data) : super.fromData();

  @override
  List<Validator<String, AuthError>> get validators => [
    const RequiredValidator(AuthError.required),
    const EmailValidator(AuthError.invalidEmail),
  ];

  @override
  List<Sanitizer<String>> get sanitizers => [
    const TrimSanitizer(),
    const ToLowerCaseSanitizer(),
  ];

  @override
  EmailInput update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    AuthError? remoteError,
  }) {
    return EmailInput._(
      prepareUpdate(
        value: value,
        status: status,
        mode: mode,
        remoteError: remoteError,
      ),
    );
  }
}
