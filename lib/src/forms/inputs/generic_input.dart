// lib/src/forms/inputs/generic_input.dart

import 'package:flux_form/flux_form.dart';

/// A concrete implementation of FormInput for one-off use cases.
///
/// Usage:
/// ```dart
/// final zipCode = GenericInput<String, String>.touched(
///   value: '90210',
///   validators: [RequiredValidator('Required'), MinLengthValidator(5, 'Too short')],
/// );
/// ```
final class GenericInput<T, E> extends FormInput<T, E> with InputMixin<T, E, GenericInput<T, E>> {
  final List<Validator<T, E>> _validators;
  final List<Sanitizer<T>> _sanitizers;

  const GenericInput.untouched({
    required super.value,
    List<Validator<T, E>> validators = const [],
    List<Sanitizer<T>> sanitizers = const [],
    super.mode,
  }) : _validators = validators,
       _sanitizers = sanitizers,
       super.untouched();

  const GenericInput.touched({
    required super.value,
    List<Validator<T, E>> validators = const [],
    List<Sanitizer<T>> sanitizers = const [],
    super.initialValue,
    super.mode,
    super.remoteError,
  }) : _validators = validators,
       _sanitizers = sanitizers,
       super.touched();

  GenericInput._(super.data, this._validators, this._sanitizers) : super.fromData();

  @override
  List<Validator<T, E>> get validators => _validators;

  @override
  List<Sanitizer<T>> get sanitizers => _sanitizers;

  @override
  GenericInput<T, E> update({
    T? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => GenericInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
    _validators, // Pass these through so they aren't lost on update
    _sanitizers,
  );
}
