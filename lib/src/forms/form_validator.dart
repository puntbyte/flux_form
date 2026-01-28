// lib/src/forms/form_validator.dart

import 'package:flux_form/src/forms/form_input.dart';

class FormValidator {
  const FormValidator._();

  static bool validate(List<FormInput<dynamic, dynamic>> inputs) {
    return inputs.every((input) => input.isValid);
  }

  static bool isUntouched(List<FormInput<dynamic, dynamic>> inputs) {
    return inputs.every((input) => input.isUntouched);
  }

  static bool isTouched(List<FormInput<dynamic, dynamic>> inputs) {
    return inputs.any((input) => input.isTouched);
  }

  /// Returns a list of all inputs that are currently invalid.
  /// Useful for "Scroll to Error" or "Error Summary" features.
  ///
  /// Returns a [List] to preserve the order defined in the form.
  static List<FormInput<dynamic, dynamic>> validateGranularly(
    List<FormInput<dynamic, dynamic>> inputs,
  ) => inputs.where((input) => input.isNotValid).toList();

  /// Returns the first fault found in a list of inputs.
  /// Casts the return type to [E] if provided.
  static E? firstError<E>(List<FormInput<dynamic, E>> inputs) {
    for (final field in inputs) {
      if (field.isNotValid) return field.error;
    }

    return null;
  }
}
