// lib/src/forms/inputs/number_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:meta/meta.dart';

/// A generic input for numeric values. Can be used as [NumberInput<int>] or [NumberInput<double>].
abstract class NumberInput<T extends num, E> extends FormInput<T, E> {
  const NumberInput.untouched({
    required super.value,
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const NumberInput.touched({
    required super.value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  @protected
  NumberInput.fromData(super.data) : super.fromData();
}

/// A generic input for numeric values. Can be used as [NumberInput<int>] or [NumberInput<double>].
final class SimpleNumberInput<T extends num, E> extends NumberInput<T, E>
    with InputMixin<T, E, SimpleNumberInput<T, E>> {
  const SimpleNumberInput.untouched({
    required super.value,
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const SimpleNumberInput.touched({
    required super.value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  SimpleNumberInput._(super.data) : super.fromData();

  @override
  SimpleNumberInput<T, E> update({
    T? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => SimpleNumberInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
  );

  SimpleNumberInput<T, E> increment([num amount = 1]) {
    final newValue = value + amount;

    final casted = switch (value) {
      int() => newValue.toInt() as T,
      double() => newValue.toDouble() as T,
    };

    return update(value: casted, status: .touched);
  }

  SimpleNumberInput<T, E> decrement([num amount = 1]) => increment(-amount);
}
