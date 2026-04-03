// lib/src/forms/builders/string_input_builder.dart

import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/inputs/string_input.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizers/string_sanitizer.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validators/format_validator.dart';
import 'package:flux_form/src/validation/validators/logic_validator.dart';
import 'package:flux_form/src/validation/validators/string_validator.dart';

/// A fluent builder that composes validators, sanitizers, and mode into a
/// [SimpleStringInput] without requiring a subclass.
///
/// ```dart
/// final email = StringInputBuilder<AuthError>()
///   .trim()
///   .toLowerCase()
///   .required(AuthError.required)
///   .email(AuthError.invalidEmail)
///   .mode(ValidationMode.deferred)
///   .buildUntouched();
/// ```
class StringInputBuilder<E> {
  final List<Validator<String, E>> _validators = [];
  final List<Sanitizer<String>> _sanitizers = [];
  ValidationMode _mode = ValidationMode.live;

  // ── Sanitizer shortcuts ───────────────────────────────────

  StringInputBuilder<E> trim() => _s(const StringSanitizer.trim());

  StringInputBuilder<E> toLowerCase() => _s(const StringSanitizer.toLowerCase());

  StringInputBuilder<E> toUpperCase() => _s(const StringSanitizer.toUpperCase());

  StringInputBuilder<E> digitsOnly() => _s(const StringSanitizer.digitsOnly());

  StringInputBuilder<E> removeSpaces() => _s(const StringSanitizer.removeSpaces());

  StringInputBuilder<E> capitalize() => _s(const StringSanitizer.capitalize());

  /// Adds a raw [Sanitizer<String>] to the pipeline.
  StringInputBuilder<E> sanitize(Sanitizer<String> sanitizer) => _s(sanitizer);

  // ── StringValidator shortcuts ─────────────────────────────

  /// Fails when the trimmed string is empty.
  StringInputBuilder<E> required(E error) => _v(StringValidator.required(error));

  /// Fails when the string is strictly empty (no trimming).
  StringInputBuilder<E> notEmpty(E error) => _v(StringValidator.notEmpty(error));

  StringInputBuilder<E> minLength(int min, E error) => _v(StringValidator.minLength(min, error));

  StringInputBuilder<E> maxLength(int max, E error) => _v(StringValidator.maxLength(max, error));

  StringInputBuilder<E> exactLength(int length, E error) =>
      _v(StringValidator.exactLength(length, error));

  StringInputBuilder<E> lengthBetween(int min, int max, E error) =>
      _v(StringValidator.lengthBetween(min, max, error));

  StringInputBuilder<E> pattern(RegExp regex, E error) => _v(StringValidator.pattern(regex, error));

  StringInputBuilder<E> isNumeric(E error) => _v(StringValidator.isNumeric(error));

  StringInputBuilder<E> numericMin(num min, E error) => _v(StringValidator.numericMin(min, error));

  StringInputBuilder<E> numericMax(num max, E error) => _v(StringValidator.numericMax(max, error));

  StringInputBuilder<E> contains(String substring, E error) =>
      _v(StringValidator.contains(substring, error));

  StringInputBuilder<E> notContains(String substring, E error) =>
      _v(StringValidator.notContains(substring, error));

  StringInputBuilder<E> startsWith(String prefix, E error) =>
      _v(StringValidator.startsWith(prefix, error));

  StringInputBuilder<E> endsWith(String suffix, E error) =>
      _v(StringValidator.endsWith(suffix, error));

  StringInputBuilder<E> noWhitespace(E error) => _v(StringValidator.noWhitespace(error));

  StringInputBuilder<E> noLeadingTrailingWhitespace(E error) =>
      _v(StringValidator.noLeadingTrailingWhitespace(error));

  StringInputBuilder<E> asciiOnly(E error) => _v(StringValidator.asciiOnly(error));

  StringInputBuilder<E> printableAscii(E error) => _v(StringValidator.printableAscii(error));

  StringInputBuilder<E> hasUppercase(E error) => _v(StringValidator.hasUppercase(error));

  StringInputBuilder<E> hasLowercase(E error) => _v(StringValidator.hasLowercase(error));

  StringInputBuilder<E> hasDigit(E error) => _v(StringValidator.hasDigit(error));

  StringInputBuilder<E> hasSpecialChar(E error) => _v(StringValidator.hasSpecialChar(error));

  StringInputBuilder<E> minUniqueChars(int min, E error) =>
      _v(StringValidator.minUniqueChars(min, error));

  StringInputBuilder<E> passwordStrength({
    required E error, int minUpper = 1,
    int minLower = 1,
    int minDigits = 1,
    int minSpecial = 1,
  }) => _v(StringValidator.passwordStrength(minUpper, minLower, minDigits, minSpecial, error));

  // ── FormatValidator shortcuts ─────────────────────────────

  StringInputBuilder<E> email(E error) => _v(FormatValidator.email(error));

  StringInputBuilder<E> url(E error, {bool requireProtocol = true}) =>
      _v(FormatValidator.url(error, requireProtocol: requireProtocol));

  StringInputBuilder<E> uuid(E error) => _v(FormatValidator.uuid(error));

  StringInputBuilder<E> creditCard(E error) => _v(FormatValidator.creditCard(error));

  StringInputBuilder<E> hexColor(E error) => _v(FormatValidator.hexColor(error));

  StringInputBuilder<E> alpha(E error) => _v(FormatValidator.alpha(error));

  StringInputBuilder<E> alphaNumeric(E error) => _v(FormatValidator.alphaNumeric(error));

  StringInputBuilder<E> ipv4(E error) => _v(FormatValidator.ipv4(error));

  StringInputBuilder<E> ipv6(E error) => _v(FormatValidator.ipv6(error));

  StringInputBuilder<E> ip(E error) => _v(FormatValidator.ip(error));

  StringInputBuilder<E> domain(E error) => _v(FormatValidator.domain(error));

  StringInputBuilder<E> e164Phone(E error) => _v(FormatValidator.e164Phone(error));

  StringInputBuilder<E> slug(E error) => _v(FormatValidator.slug(error));

  StringInputBuilder<E> base64(E error) => _v(FormatValidator.base64(error));

  StringInputBuilder<E> json(E error) => _v(FormatValidator.json(error));

  StringInputBuilder<E> iso8601(E error) => _v(FormatValidator.iso8601(error));

  StringInputBuilder<E> macAddress(E error) => _v(FormatValidator.macAddress(error));

  StringInputBuilder<E> fileExtension(List<String> allowed, E error) =>
      _v(FormatValidator.fileExtension(allowed, error));

  // ── LogicValidator shortcuts ──────────────────────────────

  /// Applies [validator] only when [condition] returns true at runtime.
  StringInputBuilder<E> when({
    required bool Function() condition,
    required Validator<String, E> validator,
  }) => _v(LogicValidator.when(condition: condition, validator: validator));

  /// Applies [validator] only when [condition] returns false at runtime.
  StringInputBuilder<E> unless({
    required bool Function() condition,
    required Validator<String, E> validator,
  }) => _v(LogicValidator.unless(condition: condition, validator: validator));

  // ── Escape hatch ──────────────────────────────────────────

  /// Adds any [Validator<String, E>] that isn't covered by a named shortcut.
  StringInputBuilder<E> validate(Validator<String, E> validator) => _v(validator);

  // ── Mode ──────────────────────────────────────────────────

  StringInputBuilder<E> mode(ValidationMode mode) {
    _mode = mode;
    return this;
  }

  // ── Build ─────────────────────────────────────────────────

  SimpleStringInput<E> buildUntouched({String value = ''}) => SimpleStringInput.untouched(
    value: value,
    validators: List.unmodifiable(_validators),
    sanitizers: List.unmodifiable(_sanitizers),
    mode: _mode,
  );

  SimpleStringInput<E> buildTouched({
    String value = '',
    String? initialValue,
    E? remoteError,
  }) => SimpleStringInput.touched(
    value: value,
    initialValue: initialValue,
    validators: List.unmodifiable(_validators),
    sanitizers: List.unmodifiable(_sanitizers),
    mode: _mode,
    remoteError: remoteError,
  );

  // ── Internal helpers ──────────────────────────────────────
  StringInputBuilder<E> _v(Validator<String, E> v) {
    _validators.add(v);
    return this;
  }

  StringInputBuilder<E> _s(Sanitizer<String> s) {
    _sanitizers.add(s);
    return this;
  }
}
