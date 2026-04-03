import 'package:example/features/localized_register/auth_error.dart';
import 'package:flux_form/flux_form.dart';

/// A field that holds a String value but returns an [AuthError] on failure.
class AuthField extends FormInput<String, AuthError> {
  // We allow rules to be passed in, just like StringField
  final List<Validator<String, AuthError>> rules;

  const AuthField.untouched({super.value = '', this.rules = const []}) : super.untouched();

  const AuthField.touched({super.value = '', this.rules = const []}) : super.touched();

  @override
  List<Validator<String, AuthError>> get validators => rules;

  @override
  AuthField update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    AuthError? remoteError,
  }) {
    // isTouched is a plain bool — the previous `isTouched ?? false` was a
    // no-op null-check on a non-nullable value. Also respect the incoming
    // status so replaceValue() correctly transitions the field to touched.
    final effectiveStatus = status ?? this.status;
    return effectiveStatus == InputStatus.untouched
        ? AuthField.untouched(value: value ?? this.value, rules: rules)
        : AuthField.touched(value: value ?? this.value, rules: rules);
  }
}
