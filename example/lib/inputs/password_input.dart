import 'package:flux_form/flux_form.dart';

class PasswordInput extends StringField {
  // Live validation (Change mode)
  const PasswordInput.untouched({super.value})
    : super.untouched(mode: ValidationMode.onInteraction);

  const PasswordInput.touched({super.value}) : super.touched(mode: ValidationMode.onInteraction);

  @override
  List<Validator<String, String>> get validators => [
    const RequiredValidator('Password is required'),
    const MinLengthValidator(6, 'Password must be at least 6 characters'),
  ];

  @override
  PasswordInput copyWith({
    String? value,
    bool? isTouched,
    ValidationMode? mode,
    String? remoteError,
  }) {
    return isTouched ?? false
        ? PasswordInput.untouched(value: value ?? this.value)
        : PasswordInput.touched(value: value ?? this.value);
  }
}
