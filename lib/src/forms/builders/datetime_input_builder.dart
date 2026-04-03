// lib/src/forms/builders/datetime_input_builder.dart

import 'package:flux_form/flux_form.dart';

/// A fluent builder that composes validators into a [SimpleDateTimeInput].
///
/// All built-in shortcuts accept nullable `DateTime?` and return null (valid)
/// when the value is null, letting [StringValidator.required] / a custom
/// required check handle the empty case separately.
///
/// ```dart
/// final checkIn = DateTimeInputBuilder<BookingError>()
///   .required(BookingError.required)
///   .after(DateTime.now(), BookingError.mustBeFuture)
///   .mode(ValidationMode.blur)
///   .buildUntouched();
/// ```
class DateTimeInputBuilder<E> {
  final List<Validator<DateTime?, E>> _validators = [];
  ValidationMode _mode = ValidationMode.live;

  // ── Built-in date shortcuts ───────────────────────────────

  /// Fails when the value is null (field is empty).
  DateTimeInputBuilder<E> required(E error) => _v(_RequiredDateValidator(error));

  /// Fails when the value is not strictly after [date].
  /// Passes (returns null) when the value is null.
  DateTimeInputBuilder<E> after(DateTime date, E error) => _v(_AfterDateValidator(date, error));

  /// Fails when the value is not strictly before [date].
  /// Passes (returns null) when the value is null.
  DateTimeInputBuilder<E> before(DateTime date, E error) => _v(_BeforeDateValidator(date, error));

  /// Fails when the value is not on or after [date].
  DateTimeInputBuilder<E> onOrAfter(DateTime date, E error) =>
      _v(_OnOrAfterDateValidator(date, error));

  /// Fails when the value is not on or before [date].
  DateTimeInputBuilder<E> onOrBefore(DateTime date, E error) =>
      _v(_OnOrBeforeDateValidator(date, error));

  /// Fails when the value falls outside the range [[from], [to]] (inclusive).
  DateTimeInputBuilder<E> between(DateTime from, DateTime to, E error) =>
      _v(_BetweenDateValidator(from, to, error));

  // ── LogicValidator shortcuts ──────────────────────────────

  DateTimeInputBuilder<E> when({
    required bool Function() condition,
    required Validator<DateTime?, E> validator,
  }) => _v(LogicValidator.when(condition: condition, validator: validator));

  DateTimeInputBuilder<E> unless({
    required bool Function() condition,
    required Validator<DateTime?, E> validator,
  }) => _v(LogicValidator.unless(condition: condition, validator: validator));

  // ── Escape hatch ──────────────────────────────────────────

  DateTimeInputBuilder<E> validate(Validator<DateTime?, E> validator) => _v(validator);

  // ── Mode ──────────────────────────────────────────────────

  DateTimeInputBuilder<E> mode(ValidationMode mode) {
    _mode = mode;
    return this;
  }

  // ── Build ─────────────────────────────────────────────────

  SimpleDateTimeInput<E> buildUntouched({DateTime? value}) => SimpleDateTimeInput.untouched(
    value: value,
    validators: List.unmodifiable(_validators),
    mode: _mode,
  );

  SimpleDateTimeInput<E> buildTouched({DateTime? value, E? remoteError}) =>
      SimpleDateTimeInput.touched(
        value: value,
        validators: List.unmodifiable(_validators),
        mode: _mode,
        remoteError: remoteError,
      );

  DateTimeInputBuilder<E> _v(Validator<DateTime?, E> v) {
    _validators.add(v);
    return this;
  }
}

// ── Private nullable-aware validator implementations ──────────────────────────

class _RequiredDateValidator<E> extends Validator<DateTime?, E> {
  const _RequiredDateValidator(super.error);

  @override
  E? validate(DateTime? value) => value == null ? error : null;
}

class _AfterDateValidator<E> extends Validator<DateTime?, E> {
  final DateTime target;

  const _AfterDateValidator(this.target, super.error);

  @override
  E? validate(DateTime? value) {
    if (value == null) return null;
    return value.isAfter(target) ? null : error;
  }
}

class _BeforeDateValidator<E> extends Validator<DateTime?, E> {
  final DateTime target;

  const _BeforeDateValidator(this.target, super.error);

  @override
  E? validate(DateTime? value) {
    if (value == null) return null;
    return value.isBefore(target) ? null : error;
  }
}

class _OnOrAfterDateValidator<E> extends Validator<DateTime?, E> {
  final DateTime target;

  const _OnOrAfterDateValidator(this.target, super.error);

  @override
  E? validate(DateTime? value) {
    if (value == null) return null;
    return !value.isBefore(target) ? null : error;
  }
}

class _OnOrBeforeDateValidator<E> extends Validator<DateTime?, E> {
  final DateTime target;

  const _OnOrBeforeDateValidator(this.target, super.error);

  @override
  E? validate(DateTime? value) {
    if (value == null) return null;
    return !value.isAfter(target) ? null : error;
  }
}

class _BetweenDateValidator<E> extends Validator<DateTime?, E> {
  final DateTime from;
  final DateTime to;

  const _BetweenDateValidator(this.from, this.to, super.error);

  @override
  E? validate(DateTime? value) {
    if (value == null) return null;
    final lower = from.isBefore(to) ? from : to;
    final upper = from.isBefore(to) ? to : from;
    return (!value.isBefore(lower) && !value.isAfter(upper)) ? null : error;
  }
}
