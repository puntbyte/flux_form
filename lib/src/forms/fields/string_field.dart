// lib/src/forms/fields/string_field.dart

import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/field.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizer_pipeline.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validator_pipeline.dart';

/// A base class for String inputs.
///
/// Subclass this and override [validators] and [sanitizers] to define logic.
class StringField extends Field<String, String> {
  const StringField.untouched({
    String value = '',
    super.mode,
    super.errorCache,
  }) : super.untouched(value);

  const StringField.touched({
    String value = '',
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched(value);

  List<Validator<String, String>> get validators => [];

  List<Sanitizer<String>> get sanitizers => [];

  @override
  String sanitize(String value) {
    if (sanitizers.isEmpty) return value;
    return SanitizerPipeline.sanitize(value, sanitizers);
  }

  @override
  String? validate(String value) {
    return ValidatorPipeline.validate(value, validators);
  }

  @override
  StringField copyWith({
    String? value,
    bool? isTouched,
    ValidationMode? mode,
    String? remoteError,
  }) {
    // 1. Sanitize the new value (if provided)
    final candidateValue = value ?? this.value;
    final sanitizedValue = value != null ? sanitize(candidateValue) : candidateValue;

    // 2. Validate immediately (Smart Caching)
    final computedError = validate(sanitizedValue);

    // 3. Return new instance
    final shouldBeTouched = (isTouched ?? false) || this.isTouched;

    if (shouldBeTouched) {
      return StringField.touched(
        value: sanitizedValue,
        mode: mode ?? this.mode,
        remoteError: remoteError ?? this.error,
        errorCache: computedError,
      );
    } else {
      return StringField.untouched(
        value: sanitizedValue,
        mode: mode ?? this.mode,
        errorCache: computedError,
      );
    }
  }
}
