// lib/forms/inputs/bool_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:meta/meta.dart';

abstract class BoolInputBase<E> extends FormInput<bool, E> {
  const BoolInputBase.untouched({
    super.value = false,
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const BoolInputBase.touched({
    super.value = false,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  @protected
  BoolInputBase.fromData(super.data) : super.fromData();
}

final class BoolInput<E> extends BoolInputBase<E> with InputMixin<bool, E, BoolInput<E>> {
  const BoolInput.untouched({
    super.value = false,
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const BoolInput.touched({
    super.value = false,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

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
