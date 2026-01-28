// features/login/models/auth_error.dart

import 'package:flutter/material.dart';
import 'package:flux_form/flux_form.dart';

enum AuthError implements FormError {
  required('required'),
  invalidEmail('invalid_email'),
  tooShort('too_short'),
  emailTaken('email_taken'), // Demonstrated Remote Error
  unknown('unknown');

  @override
  final String code;
  const AuthError(this.code);

  @override
  String message([dynamic context]) {
    if (context is BuildContext) {
      // In a real app, use AppLocalizations.of(context)
      return switch (this) {
        AuthError.required => 'This field is required',
        AuthError.invalidEmail => 'Please enter a valid email',
        AuthError.tooShort => 'Must be at least 6 characters',
        AuthError.emailTaken => 'This email is already registered',
        AuthError.unknown => 'Unknown error',
      };
    }
    return code;
  }
}
