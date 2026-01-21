// lib/src/forms/mixins/form_mixin.dart

import 'package:flux_form/src/forms/field.dart';
import 'package:flux_form/src/forms/form_validator.dart';

/// Mixin for State classes to check overall validity easily.
mixin FormMixin {
  List<Field<dynamic, dynamic>> get fields;

  bool get isValid => FormValidator.validate(fields);

  bool get isNotValid => !isValid;

  bool get isUntouched => FormValidator.isUntouched(fields);

  bool get isTouched => FormValidator.isTouched(fields);
}
