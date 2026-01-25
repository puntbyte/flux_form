// lib/src/forms/fields/string_input.dart

import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';

/// A base class for String inputs.
///
/// Subclass this and override [validators] and [sanitizers] to define logic.
class StringInput<E> extends FormInput<String, E> {
  const StringInput.untouched({
    String value = '',
    super.mode,
    super.errorCache,
  }) : super.untouched(value);

  const StringInput.touched({
    String value = '',
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched(value);

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
