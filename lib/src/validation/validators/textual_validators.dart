// lib/src/rules/textual_validators.dart

import 'package:flux_form/src/validation/validator.dart';

/// Validates that a String is not empty (checks after trimming whitespace).
class RequiredValidator<F> extends Validator<String, F> {
  const RequiredValidator(super.error);

  @override
  F? validate(String value) => value.trim().isEmpty ? error : null;
}

/// Validates that a String is strictly not empty (no trimming).
/// Use this if whitespace only is considered a valid input.
class NotEmptyValidator<F> extends Validator<String, F> {
  const NotEmptyValidator(super.error);

  @override
  F? validate(String value) => value.isEmpty ? error : null;
}

/// Validates that a String matches a standard Email regex.
class EmailValidator<F> extends Validator<String, F> {
  // Simple, standard email regex.
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  const EmailValidator(super.error);

  @override
  F? validate(String value) {
    if (value.isEmpty) return null; // Use RequiredRule for empty checks
    return _emailRegExp.hasMatch(value) ? null : error;
  }
}

/// Validates that a String has a minimum character length.
class MinLengthValidator<F> extends Validator<String, F> {
  final int minLength;

  const MinLengthValidator(this.minLength, super.error);

  @override
  F? validate(String value) => value.length < minLength ? error : null;
}

/// Validates that a String does not exceed a maximum character length.
class MaxLengthValidator<F> extends Validator<String, F> {
  final int maxLength;

  const MaxLengthValidator(this.maxLength, super.error);

  @override
  F? validate(String value) => value.length > maxLength ? error : null;
}

/// Validates that a String matches a custom Regular Expression.
class RegexValidator<F> extends Validator<String, F> {
  final RegExp regex;

  const RegexValidator(this.regex, super.error);

  @override
  F? validate(String value) {
    if (value.isEmpty) return null;
    return regex.hasMatch(value) ? null : error;
  }
}
