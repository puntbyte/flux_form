import 'package:example/features/localized_register/auth_error.dart';
import 'package:flux_form/flux_form.dart';

/// A field that holds a String value but returns an [AuthError] on failure.
class AuthField extends FormInput<String, AuthError> {
  // We allow rules to be passed in, just like StringField
  final List<Validator<String, AuthError>> rules;

  const AuthField.untouched({super.value = '', this.rules = const []}) : super.untouched();

  const AuthField.touched({super.value = '', this.rules = const []}) : super.touched();


  @override
  AuthField update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    AuthError? remoteError,
  }) {
    // If we are copying, we usually keep the same rules.
    // If you need dynamic rules, you can add a `rules` parameter here.
    return isTouched ?? false
        ? AuthField.touched(
      value: value ?? this.value,
      rules: rules,
    )
        : AuthField.untouched(
      value: value ?? this.value,
      rules: rules,
    );
  }
}
