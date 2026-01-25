// lib/src/forms/form_group.dart

import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/form_validator.dart';

/// A base class for strongly-typed forms.
///
/// Users extend this class and define getters for their inputs.
/// This provides Type Safety (via the getters) AND Group Logic (via the list).
abstract class FormGroup {
  const FormGroup();

  /// The list of inputs in this form.
  /// You must override this to register your fields.
  List<FormInput<dynamic, dynamic>> get inputs;

  // --- Logic ---
  bool get isValid => FormValidator.validate(inputs);

  bool get isUntouched => FormValidator.isUntouched(inputs);

  bool get isTouched => FormValidator.isTouched(inputs);

  /// Returns the first error found (useful for general snackbars).
  dynamic get firstError => FormValidator.firstError(inputs);

  // --- Serialization ---
  // This should be implemented by the subclass if JSON is needed,
  // OR we can't automagically know the keys without reflection.
  Map<String, dynamic> get values => {};
}
