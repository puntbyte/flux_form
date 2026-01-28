// features/login/inputs/password_input.dart

import 'package:example/features/login/models/auth_error.dart';
import 'package:flux_form/flux_form.dart';

class PasswordInput extends StringInputBase<AuthError>
    with InputMixin<String, AuthError, PasswordInput> {
  // Use Live mode: Error shows while typing
  const PasswordInput.untouched({super.value}) : super.untouched(mode: ValidationMode.live);

  const PasswordInput.touched({super.value}) : super.touched(mode: ValidationMode.live);

  PasswordInput._(super.data) : super.fromData();

  @override
  List<Validator<String, AuthError>> get validators => [
    const RequiredValidator(AuthError.required),
    const MinLengthValidator(6, AuthError.tooShort),
  ];

  @override
  PasswordInput update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    AuthError? remoteError,
  }) {
    return PasswordInput._(
      prepareUpdate(
        value: value,
        status: status,
        mode: mode,
        remoteError: remoteError,
      ),
    );
  }
}
