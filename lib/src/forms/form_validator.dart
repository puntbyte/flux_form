// lib/src/forms/form_validator.dart

import 'package:flux_form/src/forms/field.dart';

class FormValidator {
  const FormValidator._();

  static bool validate(List<Field<dynamic, dynamic>> fields) {
    return fields.every((field) => field.isValid);
  }

  static bool isUntouched(List<Field<dynamic, dynamic>> fields) {
    return fields.every((field) => field.isUntouched);
  }

  static bool isTouched(List<Field<dynamic, dynamic>> fields) {
    return fields.any((field) => field.isTouched);
  }

  /// Returns the first fault found in a list of inputs.
  /// Casts the return type to [F] if provided.
  static F? firstError<F>(List<Field<dynamic, F>> fields) {
    for (final field in fields) {
      if (field.isNotValid) return field.error;
    }

    return null;
  }
}
