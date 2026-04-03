// lib/src/forms/inputs/object_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_error.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────
// Abstract base — extend this for inputs that hold an arbitrary
// object or enum value type [T] with a structured [FormError]
// error type [E].
//
// [ObjectInput] fills the gap left by the primitive-typed bases
// (StringInput, NumberInput, BoolInput, DateTimeInput, ListInput,
// MapInput): when your value type is an enum, a DTO, a nullable
// sealed class, or any other non-primitive — and your errors
// implement [FormError] — extend [ObjectInput].
//
// The [FormError] constraint on [E] means every error carries a
// machine-readable [FormError.code] and a localisable
// [FormError.message], enabling analytics mapping and clean UI
// rendering without a switch in every widget.
//
// Usage:
//   enum UserRole { admin, editor, viewer }
//   enum RoleError implements FormError {
//     required('required');
//     @override final String code;
//     const RoleError(this.code);
//     @override String message([dynamic context]) => switch (this) {
//       RoleError.required => 'Please select a role',
//     };
//   }
//
//   class RoleInput extends ObjectInput<UserRole?, RoleError>
//       with InputMixin<UserRole?, RoleError, RoleInput> {
//     const RoleInput.untouched() : super.untouched(value: null);
//     const RoleInput.touched({super.value}) : super.touched();
//     RoleInput._(super.data) : super.fromData();
//
//     @override
//     List<Validator<UserRole?, RoleError>> get validators => [
//       ObjectValidator.predicate(
//         (r) => r != null,
//         RoleError.required,
//       ),
//     ];
//
//     @override
//     RoleInput update({
//       UserRole? value,
//       InputStatus? status,
//       ValidationMode? mode,
//       RoleError? remoteError,
//     }) => RoleInput._(prepareUpdate(
//       value: value, status: status, mode: mode, remoteError: remoteError,
//     ));
//   }
// ─────────────────────────────────────────────────────────────
abstract class ObjectInput<T, E extends FormError> extends FormInput<T, E> {
  const ObjectInput.untouched({
    required super.value,
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const ObjectInput.touched({
    required super.value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  @protected
  ObjectInput.fromData(super.data) : super.fromData();

  @override
  ObjectInput<T, E> update({
    T? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  });
}

// ─────────────────────────────────────────────────────────────
// Concrete — for one-off object / enum fields that do not need
// a dedicated subclass.
//
// Accepts validators directly in the constructor so you can
// compose rules inline:
//
//   final role = SimpleObjectInput<UserRole?, RoleError>.untouched(
//     value: null,
//     validators: [
//       ObjectValidator.predicate((r) => r != null, RoleError.required),
//     ],
//   );
//
// For fields that are reused across screens or carry complex logic,
// extend [ObjectInput] instead.
// ─────────────────────────────────────────────────────────────
final class SimpleObjectInput<T, E extends FormError> extends ObjectInput<T, E>
    with InputMixin<T, E, SimpleObjectInput<T, E>> {
  final List<Validator<T, E>> _validators;

  const SimpleObjectInput.untouched({
    required super.value,
    super.mode,
    super.errorCache,
    List<Validator<T, E>> validators = const [],
  }) : _validators = validators,
       super.untouched();

  const SimpleObjectInput.touched({
    required super.value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    List<Validator<T, E>> validators = const [],
  }) : _validators = validators,
       super.touched();

  SimpleObjectInput._(super.data, this._validators) : super.fromData();

  @override
  List<Validator<T, E>> get validators => _validators;

  @override
  SimpleObjectInput<T, E> update({
    T? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => SimpleObjectInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
    _validators,
  );
}

/// Backwards-compatibility alias for [ObjectInput].
///
/// [StandardInput] has been renamed to [ObjectInput]. This typedef keeps
/// existing code compiling during the migration window.
///
/// @deprecated Use [ObjectInput] instead. This alias will be removed in the
/// next major version.
@Deprecated('Renamed to ObjectInput. Update your code to use ObjectInput<T, E> instead.')
typedef StandardInput<T, E extends FormError> = SimpleObjectInput<T, E>;
