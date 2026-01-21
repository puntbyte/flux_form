import 'package:flux_form/flux_form.dart';

class EmailInput extends StringField {
  // 3. Clean Constructors (No rules passed to super!)
  // Note: We cannot use 'const' anymore because validation runs immediately.
  const EmailInput.pure({super.value}) : super.untouched(mode: ValidationMode.onSubmit);

  const EmailInput.dirty({super.value}) : super.touched(mode: ValidationMode.onSubmit);

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
    bool? isTouched,
    ValidationMode? mode,
    String? remoteError,
  }) {
    // Logic to handle sanitization is inherited from GenericInput.sanitize
    // But we need to call it here if we want to sanitize before creating.
    // However, GenericInput.copyWith handles it.
    // Since we are creating 'new EmailInput', we manually call sanitize if value changed.

    final candidateValue = value ?? this.value;
    final sanitized = value != null ? sanitize(candidateValue) : candidateValue;

    return isTouched ?? false
        ? EmailInput.pure(value: sanitized)
        : EmailInput.dirty(value: sanitized);
  }
}
