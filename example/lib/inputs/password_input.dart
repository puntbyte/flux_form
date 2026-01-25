import 'package:flux_form/flux_form.dart';

class PasswordInput extends StringInput<String> with InputMixin<String, String, PasswordInput> {
  const PasswordInput.untouched({super.value}) : super.untouched(mode: ValidationMode.live);

  const PasswordInput.touched({super.value}) : super.touched(mode: ValidationMode.live);

  @override
  List<Validator<String, String>> get validators => [
    const RequiredValidator('Password is required'),
    const MinLengthValidator(6, 'Password must be at least 6 characters'),
  ];

  @override
  PasswordInput update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    String? remoteError,
  }) {
    final data = prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError
    );

    return switch(data.status) {
      InputStatus.touched => PasswordInput.untouched(value: value ?? this.value),
      InputStatus.untouched => PasswordInput.touched(value: value ?? this.value),
    };
  }
}
