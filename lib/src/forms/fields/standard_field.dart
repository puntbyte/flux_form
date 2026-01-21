// lib/src/forms/fields/standard_field.dart

import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/field.dart';
import 'package:flux_form/src/forms/form_error.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizer_pipeline.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validator_pipeline.dart';

/// A generic field that returns [FormError] (typed errors) instead of Strings.
class StandardField<T> extends Field<T, FormError> {
  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  List<Validator<T, FormError>> get validators => [];

  List<Sanitizer<T>> get sanitizers => [];

  // ===========================================================================
  // CONSTRUCTORS
  // ===========================================================================

  const StandardField.untouched({
    required T value,
    super.mode,
    super.errorCache,
  }) : super.untouched(value);

  const StandardField.touched({
    required T value,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched(value);

  // ===========================================================================
  // LOGIC
  // ===========================================================================

  @override
  T sanitize(T value) {
    if (sanitizers.isEmpty) return value;
    return SanitizerPipeline.sanitize(value, sanitizers);
  }

  @override
  FormError? validate(T value) {
    return ValidatorPipeline.validate(value, validators);
  }

  @override
  StandardField<T> copyWith({
    T? value,
    bool? isTouched,
    ValidationMode? mode,
    FormError? remoteError,
  }) {
    final candidateValue = value ?? this.value;
    final sanitizedValue = value != null ? sanitize(candidateValue) : candidateValue;

    final computedError = validate(sanitizedValue);
    final shouldBeTouched = (isTouched ?? false) || this.isTouched;

    if (shouldBeTouched) {
      return StandardField.touched(
        value: sanitizedValue,
        mode: mode ?? this.mode,
        remoteError: remoteError ?? this.error,
        errorCache: computedError,
      );
    } else {
      return StandardField.untouched(
        value: sanitizedValue,
        mode: mode ?? this.mode,
        errorCache: computedError,
      );
    }
  }
}
