// lib/features/login/forms/login_schema.dart

import 'package:example/inputs/shared_inputs.dart';
import 'package:flux_form/flux_form.dart';

class LoginSchema extends FormSchema {
  final EmailInput email;
  final PasswordInput password;

  const LoginSchema({
    this.email = const EmailInput.untouched(),
    this.password = const PasswordInput.untouched(),
    super.formKey,
  });

  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'email': email,
    'password': password,
  };

  LoginSchema copyWith({
    EmailInput? email,
    PasswordInput? password,
    int? formKey,
  }) => LoginSchema(
    email: email ?? this.email,
    password: password ?? this.password,
    formKey: formKey ?? this.formKey,
  );

  @override
  LoginSchema touchAll() => copyWith(
    email: email.markTouched(),
    password: password.markTouched(),
    // formKey deliberately unchanged — touchAll is not a reset.
  );

  /// Resets all inputs to their initial values and increments [formKey].
  ///
  /// The incremented key causes any [TextField] or [TextFormField] widgets
  /// that use `key: ValueKey('${state.schema.formKey}_fieldName')` to be
  /// destroyed and recreated by Flutter — clearing their visible text without
  /// needing a [TextEditingController].
  @override
  LoginSchema reset() => LoginSchema(
    // Inputs default to their untouched constructors automatically.
    formKey: nextFormKey, // ← this is what triggers widget recreation
  );

  @override
  LoginSchema populateFrom(Map<String, dynamic> data) => copyWith(
    email: email.replaceValue(data['email'] as String? ?? ''),
  );
}
