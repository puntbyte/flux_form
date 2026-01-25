// lib/forms/inputs/bool_input.dart

import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';

class BoolInput<E> extends FormInput<bool, E> with InputMixin<bool, E, BoolInput<E>> {
  const BoolInput.untouched({
    bool value = false,
    super.mode,
    super.errorCache,
  }) : super.untouched(value);

  const BoolInput.touched({
    bool value = false,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched(value);

  BoolInput._(super.data) : super.fromData();

  BoolInput<E> toggle() => update(value: !value);

  @override
  BoolInput<E> update({
    bool? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => BoolInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
  );
}
