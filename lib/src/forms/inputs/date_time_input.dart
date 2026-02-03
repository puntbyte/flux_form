// lib/src/forms/inputs/date_time_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:meta/meta.dart';

abstract class DateTimeInput<T extends DateTime, E> extends FormInput<T?, E> {
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
}

/// A specialized input for [DateTime] values.
///
/// Handles nullable [DateTime?] because date fields often start empty.
/// [E] is the error type (e.g. String, Enum).
final class SimpleDateTimeInput<E> extends DateTimeInput<DateTime, E>
    with InputMixin<DateTime?, E, SimpleDateTimeInput<E>> {
  const SimpleDateTimeInput.untouched({
    super.value,
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const SimpleDateTimeInput.touched({
    super.value,
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  SimpleDateTimeInput._(super.data) : super.fromData();

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
