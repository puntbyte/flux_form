// lib/src/forms/inputs/number_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────
// Abstract base — extend this for domain-specific numeric inputs
// such as AgeInput, PriceInput, QuantityInput, etc.
//
// Usage:
//   class AgeInput extends NumberInput<int, MyError>
//       with InputMixin<int, MyError, AgeInput> {
//     const AgeInput.untouched({super.value = 0}) : super.untouched();
//     const AgeInput.touched({super.value = 0}) : super.touched();
//     AgeInput._(super.data) : super.fromData();
//
//     @override
//     List<Validator<int, MyError>> get validators => [
//       NumberValidator.min(0, MyError.negative),
//       NumberValidator.max(120, MyError.tooOld),
//     ];
//
//     @override
//     AgeInput update({...}) => AgeInput._(prepareUpdate(...));
//   }
// ─────────────────────────────────────────────────────────────
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

  /// Adds [amount] to the current value and marks the input as touched.
  ///
  /// Handles both [int] and [double] subtypes correctly.
  /// Override in the concrete class to narrow the static return type.
  ///
  ///   @override
  ///   MyNumberInput increment([num amount = 1]) => super.increment(amount) as MyNumberInput;
  NumberInput<T, E> increment([num amount = 1]) {
    final raw = value + amount;
    final casted = switch (value) {
      int() => raw.toInt() as T,
      double() => raw.toDouble() as T,
      _ => raw as T,
    };
    return update(value: casted, status: InputStatus.touched);
  }

  /// Subtracts [amount] from the current value.
  NumberInput<T, E> decrement([num amount = 1]) => increment(-amount);

  @override
  NumberInput<T, E> update({
    T? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  });
}

// ─────────────────────────────────────────────────────────────
// Concrete — use directly for one-off numeric fields.
//
// Usage:
//   final quantity = SimpleNumberInput<int, String>.untouched(
//     value: 1,
//     validators: [NumberValidator.min(1, 'Must be at least 1')],
//   );
// ─────────────────────────────────────────────────────────────
final class SimpleNumberInput<T extends num, E> extends NumberInput<T, E>
    with InputMixin<T, E, SimpleNumberInput<T, E>> {
  final List<Validator<T, E>> _validators;
  final List<Sanitizer<T>> _sanitizers;

  const SimpleNumberInput.untouched({
    required super.value,
    super.mode,
    super.errorCache,
    List<Validator<T, E>> validators = const [],
    List<Sanitizer<T>> sanitizers = const [],
  }) : _validators = validators,
       _sanitizers = sanitizers,
       super.untouched();

  const SimpleNumberInput.touched({
    required super.value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    List<Validator<T, E>> validators = const [],
    List<Sanitizer<T>> sanitizers = const [],
  }) : _validators = validators,
       _sanitizers = sanitizers,
       super.touched();

  SimpleNumberInput._(super.data, this._validators, this._sanitizers) : super.fromData();

  @override
  List<Validator<T, E>> get validators => _validators;

  @override
  List<Sanitizer<T>> get sanitizers => _sanitizers;

  /// Narrows the return type to [SimpleNumberInput<T, E>].
  @override
  SimpleNumberInput<T, E> increment([num amount = 1]) =>
      super.increment(amount) as SimpleNumberInput<T, E>;

  /// Narrows the return type to [SimpleNumberInput<T, E>].
  @override
  SimpleNumberInput<T, E> decrement([num amount = 1]) => increment(-amount);

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
    _validators,
    _sanitizers,
  );
}
