// features/login/forms/login_schema.dart

import 'package:example/features/login/inputs/email_input.dart';
import 'package:example/features/login/inputs/password_input.dart';
import 'package:flux_form/flux_form.dart';

class LoginShema extends FormShema {
  final EmailInput email;
  final PasswordInput password;

  const LoginShema({
    this.email = const EmailInput.untouched(),
    this.password = const PasswordInput.untouched(),
  });

  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'email': email,
    'password': password,
  };

  LoginShema copyWith({EmailInput? email, PasswordInput? password}) => LoginShema(
    email: email ?? this.email,
    password: password ?? this.password,
  );
}
