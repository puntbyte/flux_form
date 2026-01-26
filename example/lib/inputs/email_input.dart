import 'package:flux_form/flux_form.dart';

class EmailInput extends StringInputBase<String> with InputMixin<String, String, EmailInput> {
  // 3. Clean Constructors (No rules passed to super!)
  // Note: We cannot use 'const' anymore because validation runs immediately.
  const EmailInput.pure({super.value}) : super.untouched(mode: ValidationMode.deferred);

  const EmailInput.dirty({super.value}) : super.touched(mode: ValidationMode.deferred);

  // 1. Define Rules ONCE here
  @override
  List<Validator<String, String>> get validators => [
    const RequiredValidator('Email is required'),
    const EmailValidator('Invalid email format'),
  ];

  // 2. Define Sanitizers ONCE here (Optional)
  @override
  List<Sanitizer<String>> get sanitizers => [
    const TrimSanitizer(),
    const ToLowerCaseSanitizer(),
  ];

  // 4. CopyWith returning correct type
  @override
  EmailInput update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    String? remoteError,
  }) {
    final data = prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    );

    return switch(data.status) {
      InputStatus.touched => EmailInput.pure(value: data.value),
      InputStatus.untouched => EmailInput.dirty(value: data.value),
    };
  }
}
