import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_error.dart';
import 'package:flux_form/src/forms/form_input.dart';

/// A standard generic input for any type [T] (Enums, Objects, Colors, etc) and any error type [E]
/// that extends [FormError].
class StandardInput<T, E extends FormError> extends FormInput<T, E> {
  const StandardInput.untouched({
    required super.value,
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const StandardInput.touched({
    required super.value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  StandardInput._(super.data) : super.fromData();

  @override
  StandardInput<T, E> update({
    T? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => StandardInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
  );
}
