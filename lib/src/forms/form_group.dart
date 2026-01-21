// lib/src/forms/form_group.dart

import 'package:flux_form/src/forms/field.dart';
import 'package:flux_form/src/forms/form_validator.dart';

/// A base class for strongly-typed forms.
///
/// Users extend this class and define getters for their inputs.
/// This provides Type Safety (via the getters) AND Group Logic (via the list).
abstract class FormGroup {
  const FormGroup();

  /// The list of inputs in this form.
  /// You must override this to register your fields.
  List<Field<dynamic, dynamic>> get fields;

  // --- Logic ---
  bool get isValid => FormValidator.validate(fields);

  bool get isUntouched => FormValidator.isUntouched(fields);

  bool get isTouched => FormValidator.isTouched(fields);

  /// Returns the first error found (useful for general snackbars).
  dynamic get firstFault => FormValidator.firstError(fields);

  // --- Serialization ---
  // This should be implemented by the subclass if JSON is needed,
  // OR we can't automagically know the keys without reflection.
  Map<String, dynamic> get values => {};
}
