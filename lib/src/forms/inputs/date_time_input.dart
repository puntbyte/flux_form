import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';

/// A specialized input for [DateTime] values.
///
/// Handles nullable [DateTime?] because date fields often start empty.
/// [E] is the error type (e.g. String, Enum).
class DateTimeInput<E> extends FormInput<DateTime?, E> {
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

  DateTimeInput._(super.data) : super.fromData();

  @override
  DateTimeInput<E> update({
    DateTime? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => DateTimeInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
  );

  /// Returns true if the value is after [other].
  /// Returns false if value is null.
  bool isAfter(DateTime other) {
    if (value == null) return false;
    return value!.isAfter(other);
  }

  /// Returns true if the value is before [other].
  /// Returns false if value is null.
  bool isBefore(DateTime other) {
    if (value == null) return false;
    return value!.isBefore(other);
  }
}
