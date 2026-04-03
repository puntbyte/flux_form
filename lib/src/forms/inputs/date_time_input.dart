// lib/src/forms/inputs/date_time_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────
// Abstract base — extend this for domain-specific date/time
// inputs such as BirthDateInput, CheckInInput, etc.
//
// [DateTime?] is nullable by design: date fields typically start
// empty and a null value signals "not yet selected".
//
// Usage:
//   class CheckInInput extends DateTimeInput<BookingError>
//       with InputMixin<DateTime?, BookingError, CheckInInput> {
//     const CheckInInput.untouched() : super.untouched();
//     const CheckInInput.touched({super.value}) : super.touched();
//     CheckInInput._(super.data) : super.fromData();
//
//     @override
//     List<Validator<DateTime?, BookingError>> get validators => [
//       ComparableValidator.greaterThan(
//         DateTime.now(),
//         BookingError.mustBeFuture,
//       ),
//     ];
//
//     @override
//     CheckInInput update({...}) => CheckInInput._(prepareUpdate(...));
//   }
// ─────────────────────────────────────────────────────────────
abstract class DateTimeInput<E> extends FormInput<DateTime?, E> {
  const DateTimeInput.untouched({
    super.value,
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const DateTimeInput.touched({
    super.value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  @protected
  DateTimeInput.fromData(super.data) : super.fromData();

  // ── Convenience helpers ───────────────────────────────────

  /// Returns true if [value] is after [other]. Returns false when value is null.
  bool isAfter(DateTime other) => value?.isAfter(other) ?? false;

  /// Returns true if [value] is before [other]. Returns false when value is null.
  bool isBefore(DateTime other) => value?.isBefore(other) ?? false;

  /// Returns the number of whole days between [value] and [other].
  /// Returns null when [value] is null.
  int? daysDifference(DateTime other) => value?.difference(other).inDays.abs();

  @override
  DateTimeInput<E> update({
    DateTime? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  });
}

// ─────────────────────────────────────────────────────────────
// Concrete — use directly for one-off date / time picker fields.
//
// Usage:
//   final appointmentDate = SimpleDateTimeInput.untouched(
//     validators: [
//       ComparableValidator.greaterThan(DateTime.now(), 'Must be in the future'),
//     ],
//   );
// ─────────────────────────────────────────────────────────────
final class SimpleDateTimeInput<E> extends DateTimeInput<E>
    with InputMixin<DateTime?, E, SimpleDateTimeInput<E>> {
  final List<Validator<DateTime?, E>> _validators;

  const SimpleDateTimeInput.untouched({
    super.value,
    super.mode,
    super.errorCache,
    List<Validator<DateTime?, E>> validators = const [],
  }) : _validators = validators,
       super.untouched();

  const SimpleDateTimeInput.touched({
    super.value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
    List<Validator<DateTime?, E>> validators = const [],
  }) : _validators = validators,
       super.touched();

  SimpleDateTimeInput._(super.data, this._validators) : super.fromData();

  @override
  List<Validator<DateTime?, E>> get validators => _validators;

  @override
  SimpleDateTimeInput<E> update({
    DateTime? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => SimpleDateTimeInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
    _validators,
  );
}
