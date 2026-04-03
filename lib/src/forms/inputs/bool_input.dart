// lib/src/forms/inputs/bool_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────
// Abstract base — extend this when you need custom bool logic.
//
// Usage:
//   class AcceptTermsInput extends BoolInput<MyError>
//       with InputMixin<bool, MyError, AcceptTermsInput> {
//     const AcceptTermsInput.untouched() : super.untouched();
//     const AcceptTermsInput.touched({super.value}) : super.touched();
//     AcceptTermsInput._(super.data) : super.fromData();
//
//     @override
//     List<Validator<bool, MyError>> get validators =>
//         [BoolValidator.isTrue(MyError.mustAccept)];
//
//     @override
//     AcceptTermsInput update({...}) =>
//         AcceptTermsInput._(prepareUpdate(...));
//   }
// ─────────────────────────────────────────────────────────────
abstract class BoolInput<E> extends FormInput<bool, E> {
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

  @protected
  BoolInput.fromData(super.data) : super.fromData();

  /// Flips the current boolean value and marks the input as touched.
  ///
  /// Delegates to [update], so the concrete subclass return type is preserved
  /// at runtime. Override in the concrete class to narrow the static return type.
  ///
  ///   @override
  ///   MyBoolInput toggle() => update(value: !value);
  BoolInput<E> toggle() => update(value: !value);

  @override
  BoolInput<E> update({
    bool? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  });
}

// ─────────────────────────────────────────────────────────────
// Concrete — use directly for one-off checkboxes / toggles.
//
// Usage:
//   final acceptTerms = SimpleBoolInput.untouched(
//     value: false,
//     validators: [BoolValidator.isTrue('You must accept terms')],
//   );
// ─────────────────────────────────────────────────────────────
final class SimpleBoolInput<E> extends BoolInput<E> with InputMixin<bool, E, SimpleBoolInput<E>> {
  final List<Validator<bool, E>> _validators;

  const SimpleBoolInput.untouched({
    super.value = false,
    super.mode,
    super.errorCache,
    List<Validator<bool, E>> validators = const [],
  }) : _validators = validators,
       super.untouched();

  const SimpleBoolInput.touched({
    super.value = false,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    List<Validator<bool, E>> validators = const [],
  }) : _validators = validators,
       super.touched();

  SimpleBoolInput._(super.data, this._validators) : super.fromData();

  @override
  List<Validator<bool, E>> get validators => _validators;

  /// Narrows the return type to [SimpleBoolInput<E>].
  @override
  SimpleBoolInput<E> toggle() => update(value: !value);

  @override
  SimpleBoolInput<E> update({
    bool? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => SimpleBoolInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
    _validators,
  );
}
