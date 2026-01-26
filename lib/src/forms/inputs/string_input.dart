// lib/src/forms/fields/string_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:meta/meta.dart';

abstract class StringInputBase<E> extends FormInput<String, E> {
  const StringInputBase.untouched({
    super.value = '',
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const StringInputBase.touched({
    super.value = '',
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  @protected
  StringInputBase.fromData(super.data) : super.fromData();
}

/// A base class for String inputs.
///
/// Subclass this and override [validators] and [sanitizers] to define logic.
final class StringInput<E> extends StringInputBase<E> with InputMixin<String, E, StringInput<E>> {
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

  StringInput._(super.data) : super.fromData();

  @override
  StringInput<E> update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => StringInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
  );
}
