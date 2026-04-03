// lib/src/validation/validators/string_validator.dart


import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/validation/validator.dart';

/// A namespace for String-based validation rules.
abstract class StringValidator<E> extends Validator<String, E> {
  const StringValidator(super.error);

  // ── Required / empty checks ───────────────────────────────
  //
  // There are three distinct "is this field empty?" rules. The difference
  // is in how they handle whitespace-only values like "   ":
  //
  // ┌────────────────────┬──────────────┬──────────────┬──────────────┐
  // │ Validator          │ ""           │ "   "        │ "a"          │
  // ├────────────────────┼──────────────┼──────────────┼──────────────┤
  // │ required           │ ✗ error      │ ✗ error      │ ✓ valid      │
  // │ trimmedRequired    │ ✗ error      │ ✗ error      │ ✓ valid      │
  // │ notEmpty           │ ✗ error      │ ✓ valid      │ ✓ valid      │
  // └────────────────────┴──────────────┴──────────────┴──────────────┘
  //
  // `required` and `trimmedRequired` are functionally identical — both trim
  // before checking. `required` is the conventional name; `trimmedRequired`
  // is the explicit, self-documenting alias.
  //
  // Rule of thumb:
  //   • Use `required`        → standard "this field must not be blank" rule.
  //   • Use `trimmedRequired` → same as above, but makes the trim explicit
  //                             (useful when your sanitizer does NOT include
  //                             `StringSanitizer.trim()` and you still want to
  //                             reject whitespace-only submissions).
  //   • Use `notEmpty`        → when a single space is a legitimate value
  //                             (rare — e.g., a middle-name separator field).

  /// Fails when the value is empty after trimming whitespace.
  ///
  /// `""` → error.
  /// `"   "` → error (whitespace-only is treated as blank).
  /// `"a"` → valid.
  ///
  /// This is the standard "field is required" rule for most text inputs.
  /// See also [trimmedRequired] (explicit alias) and [notEmpty] (no trimming).
  const factory StringValidator.required(E error) = _RequiredValidator;

  /// Explicit alias for [required].
  ///
  /// Identical behaviour: fails when `value.trim().isEmpty`.
  /// Use this name when you want to make the trim behaviour self-documenting,
  /// particularly when your input does NOT include `StringSanitizer.trim()`
  /// in its sanitizers list.
  ///
  /// ```dart
  /// // Makes the "trimming before checking" contract obvious to readers:
  /// StringValidator.trimmedRequired(AuthError.required)
  /// ```
  const factory StringValidator.trimmedRequired(E error) = _RequiredValidator;

  /// Fails when the value is strictly empty (zero characters, no trimming).
  ///
  /// `""` → error.
  /// `"   "` → **valid** (whitespace is treated as content).
  /// `"a"` → valid.
  ///
  /// Use this only when a whitespace-only string is a deliberate, valid input
  /// (e.g., a text-art field). For standard "required" behaviour, prefer
  /// [required] or [trimmedRequired].
  const factory StringValidator.notEmpty(E error) = _NotEmptyValidator;

  // ── Length checks ─────────────────────────────────────────

  /// Fails when the string's length is less than [min].
  const factory StringValidator.minLength(int min, E error) = _MinLengthValidator;

  /// Fails when the string's length is greater than [max].
  const factory StringValidator.maxLength(int max, E error) = _MaxLengthValidator;

  /// Fails when the string is non-empty and not exactly [length] characters.
  const factory StringValidator.exactLength(int length, E error) = _ExactLengthValidator;

  /// Fails when the string is non-empty and its length is outside [[min], [max]].
  const factory StringValidator.lengthBetween(int min, int max, E error) = _LengthBetweenValidator;

  // ── Pattern checks ────────────────────────────────────────

  /// Fails when the string is non-empty and does not match [regex].
  const factory StringValidator.pattern(RegExp regex, E error) = _RegexValidator;

  // ── Numeric string checks ─────────────────────────────────

  /// Fails when the string is non-empty and cannot be parsed as a number.
  const factory StringValidator.isNumeric(E error) = _IsNumericStringValidator;

  /// Fails when the string represents a number less than [min].
  /// Passes (valid) when the value is empty or not parseable as a number.
  const factory StringValidator.numericMin(num min, E error) = _MinStringValueValidator;

  /// Fails when the string represents a number greater than [max].
  /// Passes (valid) when the value is empty or not parseable as a number.
  const factory StringValidator.numericMax(num max, E error) = _MaxStringValueValidator;

  // ── Content checks ────────────────────────────────────────

  /// Fails when the string does not contain [substring].
  const factory StringValidator.contains(String substring, E error) = _ContainsValidator;

  /// Fails when the string does not start with [prefix].
  const factory StringValidator.startsWith(String prefix, E error) = _StartsWithValidator;

  /// Fails when the string does not end with [suffix].
  const factory StringValidator.endsWith(String suffix, E error) = _EndsWithValidator;

  /// Fails when the string contains [substring].
  const factory StringValidator.notContains(String substring, E error) = _NotContainsValidator;

  // ── Whitespace checks ─────────────────────────────────────

  /// Fails when the string contains any whitespace character (including internal spaces).
  const factory StringValidator.noWhitespace(E error) = _NoWhitespaceValidator;

  /// Fails when the string has leading or trailing whitespace.
  const factory StringValidator.noLeadingTrailingWhitespace(E error) =
      _NoLeadingTrailingWhitespaceValidator;

  // ── Character set checks ──────────────────────────────────

  /// Fails when the string contains any character with a code point above 127.
  const factory StringValidator.asciiOnly(E error) = _AsciiOnlyValidator;

  /// Fails when the string contains any character outside the printable ASCII
  /// range (code points 32–126).
  const factory StringValidator.printableAscii(E error) = _PrintableAsciiValidator;

  // ── Character composition checks ──────────────────────────

  /// Fails when the string contains no uppercase letter (A–Z).
  const factory StringValidator.hasUppercase(E error) = _HasUppercaseValidator;

  /// Fails when the string contains no lowercase letter (a–z).
  const factory StringValidator.hasLowercase(E error) = _HasLowercaseValidator;

  /// Fails when the string contains no digit (0–9).
  const factory StringValidator.hasDigit(E error) = _HasDigitValidator;

  /// Fails when the string contains no non-alphanumeric character.
  const factory StringValidator.hasSpecialChar(E error) = _HasSpecialCharValidator;

  /// Fails when the number of unique characters is less than [minUnique].
  const factory StringValidator.minUniqueChars(int minUnique, E error) = _MinUniqueCharsValidator;

  // ── Password composite check ──────────────────────────────

  /// Composite password strength check.
  ///
  /// Fails when any of the minimums are not met:
  /// - [minUpper] uppercase letters (A–Z)
  /// - [minLower] lowercase letters (a–z)
  /// - [minDigits] digits (0–9)
  /// - [minSpecial] non-alphanumeric characters
  ///
  /// For granular per-requirement feedback (e.g., a strength meter), use
  /// [FormInput.detailedErrors] with individual validators instead.
  const factory StringValidator.passwordStrength(
    int minUpper,
    int minLower,
    int minDigits,
    int minSpecial,
    E error,
  ) = _PasswordStrengthValidator;
}

// ════════════════════════════════════════════════════════════════
// Implementations
// ════════════════════════════════════════════════════════════════

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
        upp++;
      } else if (ch >= 0x61 && ch <= 0x7A) {
        low++;
      } else if (ch >= 0x30 && ch <= 0x39) {
        dig++;
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
