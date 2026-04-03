// lib/errors/auth_error.dart

import 'package:flux_form/flux_form.dart';

/// Demonstrates [FormError] — a typed error enum that carries both a
/// machine-readable [code] (for API mapping / analytics) and a localised
/// [message] (for UI display).
///
/// Using an enum instead of raw strings means the compiler catches every
/// missing case in switch expressions, and error handling is centralised here.
enum AuthError implements FormError {
  required('required'),
  invalidEmail('invalid_email'),
  tooShort('too_short'),
  noUppercase('no_uppercase'),
  noDigit('no_digit'),
  noSpecialChar('no_special_char'),
  emailTaken('email_taken'),
  usernameTaken('username_taken'),
  unknown('unknown')
  ;

  @override
  final String code;

  const AuthError(this.code);

  static AuthError fromCode(String? code) => AuthError.values.firstWhere(
    (e) => e.code == code,
    orElse: () => AuthError.unknown,
  );

  @override
  String message([dynamic context]) {
    // In a real app: AppLocalizations.of(context as BuildContext).someKey
    return switch (this) {
      AuthError.required => 'This field is required',
      AuthError.invalidEmail => 'Please enter a valid email address',
      AuthError.tooShort => 'Must be at least 8 characters',
      AuthError.noUppercase => 'Must contain an uppercase letter',
      AuthError.noDigit => 'Must contain a digit',
      AuthError.noSpecialChar => r'Must contain a special character (!@#$%)',
      AuthError.emailTaken => 'This email is already registered',
      AuthError.usernameTaken => 'This username is already taken',
      AuthError.unknown => 'An unknown error occurred',
    };
  }
}

/// Demonstrates error enums WITHOUT [FormError] — simple, sufficient for apps
/// that handle localisation purely in the UI layer.
enum BookingError {
  required,
  invalidDate,
  checkOutBeforeCheckIn,
  tooShort, // stay of less than 1 night
  tooLong, // stay exceeds 30 nights
}
