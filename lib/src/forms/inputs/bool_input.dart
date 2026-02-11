// lib/forms/inputs/bool_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:flux_form/src/validation/validator.dart';

final class BoolInput<E> extends FormInput<bool, E> with InputMixin<bool, E, BoolInput<E>> {
  final List<Validator<bool, E>> _validators;

  const BoolInput.untouched({
    super.value = false,
    super.mode,
    super.errorCache,
    List<Validator<bool, E>> validators = const [],
  }) : _validators = validators,
       super.untouched();

  const BoolInput.touched({
    super.value = false,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    List<Validator<bool, E>> validators = const [],
  }) : _validators = validators,
       super.touched();

  BoolInput._(super.data, this._validators) : super.fromData();

  @override
  List<Validator<bool, E>> get validators => _validators;

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
    _validators,
  );
}
