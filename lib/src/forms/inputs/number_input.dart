// lib/src/forms/inputs/number_input.dart

import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';

/// A generic input for numeric values.
/// Can be used as [NumberInput<int>] or [NumberInput<double>].
class NumberInput<T extends num, E> extends FormInput<T, E>
    with InputMixin<T, E, NumberInput<T, E>> {
  const NumberInput.untouched({
    required T value,
    super.mode,
    super.errorCache,
  }) : super.untouched(value);

  const NumberInput.touched({
    required T value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched(value);

  NumberInput._(super.data) : super.fromData();

  @override
  NumberInput<T, E> update({
    T? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => NumberInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
  );

  NumberInput<T, E> increment([num amount = 1]) {
    final newValue = value + amount;

    final casted = switch (value) {
      int() => newValue.toInt() as T,
      double() => newValue.toDouble() as T,
    };

    return update(value: casted, status: .touched);
  }

  NumberInput<T, E> decrement([num amount = 1]) => increment(-amount);
}
