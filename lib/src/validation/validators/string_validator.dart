// lib/src/validation/validators/string_validator.dart

import 'package:flux_form/src/validation/validator.dart';

/// A namespace for String-based validation rules.
abstract class StringValidator<E> extends Validator<String, E> {
  const StringValidator(super.error);

  /// Validates that the string is not empty (trims whitespace by default).
  const factory StringValidator.required(E error) = _RequiredValidator;

  /// Validates that the string is strictly not empty (no trimming).
  const factory StringValidator.notEmpty(E error) = _NotEmptyValidator;

  /// Validates minimum character length.
  const factory StringValidator.minLength(int min, E error) = _MinLengthValidator;

  /// Validates maximum character length.
  const factory StringValidator.maxLength(int max, E error) = _MaxLengthValidator;

  /// Validates against a custom Regex.
  const factory StringValidator.pattern(RegExp regex, E error) = _RegexValidator;

  // --- Numeric String Checks ---

  /// Validates that the string can be parsed into a number.
  const factory StringValidator.isNumeric(E error) = _IsNumericStringValidator;

  /// Validates that the string represents a number >= [min].
  const factory StringValidator.numericMin(num min, E error) = _MinStringValueValidator;

  /// Validates that the string represents a number <= [max].
  const factory StringValidator.numericMax(num max, E error) = _MaxStringValueValidator;

  // --- Content Checks ---
  /// Validates that the string contains [substring].
  const factory StringValidator.contains(String substring, E error) = _ContainsValidator;

  /// Validates that the string starts with [prefix].
  const factory StringValidator.startsWith(String prefix, E error) = _StartsWithValidator;

  /// Validates that the string ends with [suffix].
  const factory StringValidator.endsWith(String suffix, E error) = _EndsWithValidator;

  /// Validates that the string does NOT contain [substring].
  const factory StringValidator.notContains(String substring, E error) = _NotContainsValidator;

  // --- New validators added below ---

  /// Exact length (if non-empty).
  const factory StringValidator.exactLength(int length, E error) = _ExactLengthValidator;

  /// Length between min and max (inclusive).
  const factory StringValidator.lengthBetween(int min, int max, E error) = _LengthBetweenValidator;

  /// Disallow any whitespace characters.
  const factory StringValidator.noWhitespace(E error) = _NoWhitespaceValidator;

  /// Disallow leading or trailing whitespace.
  const factory StringValidator.noLeadingTrailingWhitespace(E error) =
      _NoLeadingTrailingWhitespaceValidator;

  /// Allow only ASCII characters (code <= 127).
  const factory StringValidator.asciiOnly(E error) = _AsciiOnlyValidator;

  /// Allow only printable ASCII characters (32..126).
  const factory StringValidator.printableAscii(E error) = _PrintableAsciiValidator;

  /// Must contain at least one uppercase character A-Z.
  const factory StringValidator.hasUppercase(E error) = _HasUppercaseValidator;

  /// Must contain at least one lowercase character a-z.
  const factory StringValidator.hasLowercase(E error) = _HasLowercaseValidator;

  /// Must contain at least one digit 0-9.
  const factory StringValidator.hasDigit(E error) = _HasDigitValidator;

  /// Must contain at least one special (non-alphanumeric) character.
  const factory StringValidator.hasSpecialChar(E error) = _HasSpecialCharValidator;

  /// Minimum number of unique characters.
  const factory StringValidator.minUniqueChars(int minUnique, E error) = _MinUniqueCharsValidator;

  /// Composite password strength check:
  /// positional: minUpper, minLower, minDigits, minSpecial, then error.
  const factory StringValidator.passwordStrength(
    int minUpper,
    int minLower,
    int minDigits,
    int minSpecial,
    E error,
  ) = _PasswordStrengthValidator;
}

// ================= Implementation =================

class _RequiredValidator<E> extends StringValidator<E> {
  const _RequiredValidator(super.error);

  @override
  E? validate(String value) => value.trim().isEmpty ? error : null;
}

class _NotEmptyValidator<E> extends StringValidator<E> {
  const _NotEmptyValidator(super.error);

  @override
  E? validate(String value) => value.isEmpty ? error : null;
}

class _MinLengthValidator<E> extends StringValidator<E> {
  final int minLength;

  const _MinLengthValidator(this.minLength, super.error);

  @override
  E? validate(String value) => value.length < minLength ? error : null;
}

class _MaxLengthValidator<E> extends StringValidator<E> {
  final int maxLength;

  const _MaxLengthValidator(this.maxLength, super.error);

  @override
  E? validate(String value) => value.length > maxLength ? error : null;
}

class _RegexValidator<E> extends StringValidator<E> {
  final RegExp regex;

  const _RegexValidator(this.regex, super.error);

  @override
  E? validate(String value) => (value.isNotEmpty && !regex.hasMatch(value)) ? error : null;
}

class _IsNumericStringValidator<E> extends StringValidator<E> {
  const _IsNumericStringValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return num.tryParse(value) == null ? error : null;
  }
}

class _MinStringValueValidator<E> extends StringValidator<E> {
  final num min;

  const _MinStringValueValidator(this.min, super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    final parsed = num.tryParse(value);
    if (parsed == null) return null;
    return parsed < min ? error : null;
  }
}

class _MaxStringValueValidator<E> extends StringValidator<E> {
  final num max;

  const _MaxStringValueValidator(this.max, super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    final parsed = num.tryParse(value);
    if (parsed == null) return null;
    return parsed > max ? error : null;
  }
}

class _ContainsValidator<E> extends StringValidator<E> {
  final String substring;

  const _ContainsValidator(this.substring, super.error);

  @override
  E? validate(String value) => value.contains(substring) ? null : error;
}

class _StartsWithValidator<E> extends StringValidator<E> {
  final String prefix;

  const _StartsWithValidator(this.prefix, super.error);

  @override
  E? validate(String value) => value.startsWith(prefix) ? null : error;
}

class _EndsWithValidator<E> extends StringValidator<E> {
  final String suffix;

  const _EndsWithValidator(this.suffix, super.error);

  @override
  E? validate(String value) => value.endsWith(suffix) ? null : error;
}

class _NotContainsValidator<E> extends StringValidator<E> {
  final String substring;

  const _NotContainsValidator(this.substring, super.error);

  @override
  E? validate(String value) => !value.contains(substring) ? null : error;
}

// ---------------- New implementations ----------------

class _ExactLengthValidator<E> extends StringValidator<E> {
  final int length;

  const _ExactLengthValidator(this.length, super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return value.length == length ? null : error;
  }
}

class _LengthBetweenValidator<E> extends StringValidator<E> {
  final int min;
  final int max;

  const _LengthBetweenValidator(this.min, this.max, super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    final lower = min <= max ? min : max;
    final upper = min <= max ? max : min;
    return (value.length >= lower && value.length <= upper) ? null : error;
  }
}

class _NoWhitespaceValidator<E> extends StringValidator<E> {
  static final RegExp _white = RegExp(r'\s');

  const _NoWhitespaceValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _white.hasMatch(value) ? error : null;
  }
}

class _NoLeadingTrailingWhitespaceValidator<E> extends StringValidator<E> {
  const _NoLeadingTrailingWhitespaceValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return value.trim() == value ? null : error;
  }
}

class _AsciiOnlyValidator<E> extends StringValidator<E> {
  const _AsciiOnlyValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    for (final r in value.runes) {
      if (r > 127) return error;
    }
    return null;
  }
}

class _PrintableAsciiValidator<E> extends StringValidator<E> {
  const _PrintableAsciiValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    for (final r in value.runes) {
      if (r < 32 || r > 126) return error;
    }
    return null;
  }
}

class _HasUppercaseValidator<E> extends StringValidator<E> {
  static final RegExp _upper = RegExp('[A-Z]');

  const _HasUppercaseValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _upper.hasMatch(value) ? null : error;
  }
}

class _HasLowercaseValidator<E> extends StringValidator<E> {
  static final RegExp _lower = RegExp('[a-z]');

  const _HasLowercaseValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _lower.hasMatch(value) ? null : error;
  }
}

class _HasDigitValidator<E> extends StringValidator<E> {
  static final RegExp _digit = RegExp(r'\d');

  const _HasDigitValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _digit.hasMatch(value) ? null : error;
  }
}

class _HasSpecialCharValidator<E> extends StringValidator<E> {
  // non-alphanumeric (quick approximation)
  static final RegExp _special = RegExp('[^A-Za-z0-9]');

  const _HasSpecialCharValidator(super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    return _special.hasMatch(value) ? null : error;
  }
}

class _MinUniqueCharsValidator<E> extends StringValidator<E> {
  final int minUnique;

  const _MinUniqueCharsValidator(this.minUnique, super.error);

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;
    final unique = value.split('').toSet().length;
    return unique < minUnique ? error : null;
  }
}

class _PasswordStrengthValidator<E> extends StringValidator<E> {
  final int minUpper;
  final int minLower;
  final int minDigits;
  final int minSpecial;

  const _PasswordStrengthValidator(
    this.minUpper,
    this.minLower,
    this.minDigits,
    this.minSpecial,
    super.error,
  );

  @override
  E? validate(String value) {
    if (value.isEmpty) return null;

    var upp = 0;
    var low = 0;
    var dig = 0;
    var spec = 0;

    for (final ch in value.runes) {
      if (ch >= 0x41 && ch <= 0x5A) {
        upp++; // A-Z
      } else if (ch >= 0x61 && ch <= 0x7A) {
        low++; // a-z
      } else if (ch >= 0x30 && ch <= 0x39) {
        dig++; // 0-9
      } else {
        spec++;
      }
    }

    if (upp < minUpper) return error;
    if (low < minLower) return error;
    if (dig < minDigits) return error;
    if (spec < minSpecial) return error;

    return null;
  }
}
