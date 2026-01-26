// lib/src/forms/form_group.dart

import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/form_validator.dart';

/// A base class for strongly-typed forms.
///
/// Users extend this class and define getters for their inputs.
/// This provides Type Safety (via the getters) AND Group Logic (via the list).
abstract class FormGroup {
  const FormGroup();

  /// Defines the inputs with their associated keys (field names).
  Map<String, FormInput<dynamic, dynamic>> get namedInputs;

  /// The list of inputs, derived automatically.
  List<FormInput<dynamic, dynamic>> get inputs => namedInputs.values.toList();

  // --- Logic ---
  bool get isValid => FormValidator.validate(inputs);

  bool get isNotValid => !isValid;

  bool get isUntouched => FormValidator.isUntouched(inputs);

  bool get isTouched => FormValidator.isTouched(inputs);

  /// Returns the first error found (useful for general snackbars).
  dynamic get firstError => FormValidator.firstError(inputs);

  /// Automatically generates a Map of current values.
  /// Uses a "Collection For" to ensure a [Map<String, dynamic>] is returned.
  Map<String, dynamic> get values => {
    for (final entry in namedInputs.entries) entry.key: entry.value.value,
  };
}
