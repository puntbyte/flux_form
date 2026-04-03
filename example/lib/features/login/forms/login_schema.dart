// lib/features/login/forms/login_schema.dart

import 'package:example/inputs/shared_inputs.dart';
import 'package:flux_form/flux_form.dart';

/// Demonstrates [FormSchema]:
///   • [namedInputs] for automatic serialization via [values]
///   • [touchAll] / [reset] delegating to typed [copyWith]
///   • [validate] as the single submit guard
///   • [populateFrom] for edit flows
class LoginSchema extends FormSchema {
  final EmailInput email;
  final PasswordInput password;

  const LoginSchema({
    this.email = const EmailInput.untouched(),
    this.password = const PasswordInput.untouched(),
  });

  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'email': email,
    'password': password,
  };

  LoginSchema copyWith({EmailInput? email, PasswordInput? password}) =>
      LoginSchema(email: email ?? this.email, password: password ?? this.password);

  /// [touchAll] — marks every input touched so deferred errors become visible.
  /// Called internally by [validate] before checking [isValid].
  @override
  LoginSchema touchAll() => copyWith(
    email: email.markTouched(),
    password: password.markTouched(),
  );

  /// [reset] — reverts all inputs to initial values and clears touched state.
  @override
  LoginSchema reset() => copyWith(
    email: email.reset(),
    password: password.reset(),
  );

  /// [populateFrom] — pre-fills the schema from a server response or local cache.
  /// Demonstrates the edit-flow pattern: call this when loading an existing user.
  @override
  LoginSchema populateFrom(Map<String, dynamic> data) => copyWith(
    email: email.replaceValue(data['email'] as String? ?? ''),
  );
}