// lib/src/forms/mixins/form_mixin.dart

import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/form_validator.dart';

/// Mixin for State classes to check overall validity easily.
mixin FormMixin {
  List<FormInput<dynamic, dynamic>> get inputs;

  bool get isValid => FormValidator.validate(inputs);

  bool get isNotValid => !isValid;

  bool get isUntouched => FormValidator.isUntouched(inputs);

  bool get isTouched => FormValidator.isTouched(inputs);

  /// Returns a list of specific inputs that failed validation.
  List<FormInput<dynamic, dynamic>> get invalidInputs => FormValidator.validateGranularly(inputs);
}
