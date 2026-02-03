// lib/src/forms/fields/string_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:meta/meta.dart';

abstract class StringInput<T extends String, E> extends FormInput<T, E> {
  const StringInput.untouched({
    required super.value,
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const StringInput.touched({
    required super.value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  @protected
  StringInput.fromData(super.data) : super.fromData();
}

/// A base class for String inputs.
///
/// Subclass this and override [validators] and [sanitizers] to define logic.
final class SimpleStringInput<E> extends StringInput<String, E>
    with InputMixin<String, E, SimpleStringInput<E>> {
  const SimpleStringInput.untouched({
    super.value = '',
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const SimpleStringInput.touched({
    super.value = '',
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  SimpleStringInput._(super.data) : super.fromData();

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
  );
}
