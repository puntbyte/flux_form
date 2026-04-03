// lib/src/forms/inputs/string_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────
// Abstract base — extend this for domain-specific string inputs
// such as EmailInput, PasswordInput, UsernameInput, etc.
//
// Usage:
//   class EmailInput extends StringInput<AuthError>
//       with InputMixin<String, AuthError, EmailInput> {
//     const EmailInput.untouched({super.value = ''}) : super.untouched();
//     const EmailInput.touched({super.value = '', super.remoteError})
//         : super.touched();
//     EmailInput._(super.data) : super.fromData();
//
//     @override
//     List<Sanitizer<String>> get sanitizers =>
//         [StringSanitizer.trim(), StringSanitizer.toLowerCase()];
//
//     @override
//     List<Validator<String, AuthError>> get validators => [
//       StringValidator.required(AuthError.required),
//       FormatValidator.email(AuthError.invalidEmail),
//     ];
//
//     @override
//     EmailInput update({...}) => EmailInput._(prepareUpdate(...));
//   }
// ─────────────────────────────────────────────────────────────
abstract class StringInput<E> extends FormInput<String, E> {
  const StringInput.untouched({
    super.value = '',
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const StringInput.touched({
    super.value = '',
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  @protected
  StringInput.fromData(super.data) : super.fromData();

  @override
  StringInput<E> update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  });
}

// ─────────────────────────────────────────────────────────────
// Concrete — use directly for one-off string fields where
// subclassing is not worth the overhead.
//
// Usage:
//   final search = SimpleStringInput.untouched(
//     value: '',
//     validators: [StringValidator.required('Search term required')],
//     sanitizers: [StringSanitizer.trim()],
//   );
// ─────────────────────────────────────────────────────────────
final class SimpleStringInput<E> extends StringInput<E>
    with InputMixin<String, E, SimpleStringInput<E>> {
  final List<Validator<String, E>> _validators;
  final List<Sanitizer<String>> _sanitizers;

  const SimpleStringInput.untouched({
    super.value = '',
    super.mode,
    super.errorCache,
    List<Validator<String, E>> validators = const [],
    List<Sanitizer<String>> sanitizers = const [],
  }) : _validators = validators,
        _sanitizers = sanitizers,
        super.untouched();

  const SimpleStringInput.touched({
    super.value = '',
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    List<Validator<String, E>> validators = const [],
    List<Sanitizer<String>> sanitizers = const [],
  }) : _validators = validators,
        _sanitizers = sanitizers,
        super.touched();

  SimpleStringInput._(super.data, this._validators, this._sanitizers)
      : super.fromData();

  @override
  List<Validator<String, E>> get validators => _validators;

  @override
  List<Sanitizer<String>> get sanitizers => _sanitizers;

  @override
  SimpleStringInput<E> update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => SimpleStringInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
    _validators,
    _sanitizers,
  );
}