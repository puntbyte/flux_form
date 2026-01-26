// lib/src/validation/validators/numeric_validators.dart

import 'package:flux_form/src/validation/validator.dart';

// ==========================================
// Strict Rules (Input is explicitly num/int/double)
// ==========================================

/// Validates that a number is greater than or equal to [min].
class MinNumberValidator<F> extends Validator<num, F> {
  final num min;

  const MinNumberValidator(this.min, super.error);

  @override
  F? validate(num value) => value < min ? error : null;
}

/// Validates that a number is less than or equal to [max].
class MaxNumberValidator<F> extends Validator<num, F> {
  final num max;

  const MaxNumberValidator(this.max, super.error);

  @override
  F? validate(num value) => value > max ? error : null;
}

/// Validates that a number is not negative.
class NonNegativeValidator<F> extends Validator<num, F> {
  const NonNegativeValidator(super.error);

  @override
  F? validate(num value) => value < 0 ? error : null;
}

// ==========================================
// String Rules (Input is String, but represents a number)
// ==========================================

/// Validates that a String can be parsed into a number (int or double).
class IsNumericStringValidator<F> extends Validator<String, F> {
  const IsNumericStringValidator(super.error);

  @override
  F? validate(String value) {
    if (value.isEmpty) return null;
    return num.tryParse(value) == null ? error : null;
  }
}

/// Validates that a String represents a number >= [min].
class MinStringValueValidator<F> extends Validator<String, F> {
  final num min;

  const MinStringValueValidator(this.min, super.error);

  @override
  F? validate(String value) {
    if (value.isEmpty) return null;
    final parsed = num.tryParse(value);
    // If it's not a number, we return null here so IsNumericStringRule can handle the type check,
    // OR you can return error here if you want strict checking combined.
    // Usually best to chain rules: [IsNumericStringRule, MinStringValueRule]
    if (parsed == null) return null;
    return parsed < min ? error : null;
  }
}

/// Validates that a String represents a number <= [max].
class MaxStringValueValidator<F> extends Validator<String, F> {
  final num max;

  const MaxStringValueValidator(this.max, super.error);

  @override
  F? validate(String value) {
    if (value.isEmpty) return null;
    final parsed = num.tryParse(value);
    if (parsed == null) return null;
    return parsed > max ? error : null;
  }
}
