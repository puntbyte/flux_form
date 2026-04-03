// lib/features/booking/forms/booking_schema.dart
//
// Demonstrates:
//   • DateTimeInput — nullable DateTime? for date pickers
//   • Custom per-type Validators (non-const, nullable-aware)
//   • SchemaValidator — cross-field: checkOut must be after checkIn
//   • NumberInputBuilder — stepper for guest count

import 'package:example/errors/auth_error.dart';
import 'package:flux_form/flux_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Nullable-aware date validators
//
// ComparableValidator requires a non-nullable Comparable<T>. For nullable
// DateTime? inputs, we write small bespoke validators that short-circuit on
// null (returning null = valid) and let a separate .required() check handle
// the "no date selected" case.
// ─────────────────────────────────────────────────────────────────────────────

class _RequiredDateValidator extends Validator<DateTime?, BookingError> {
  const _RequiredDateValidator() : super(BookingError.required);

  @override
  BookingError? validate(DateTime? v) => v == null ? error : null;
}

class _NotInPastValidator extends Validator<DateTime?, BookingError> {
  const _NotInPastValidator() : super(BookingError.invalidDate);

  @override
  BookingError? validate(DateTime? v) {
    if (v == null) return null; // let _RequiredDateValidator handle this
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return v.isBefore(todayOnly) ? error : null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DateTimeInput subclasses
// ─────────────────────────────────────────────────────────────────────────────

class CheckInInput extends DateTimeInput<BookingError>
    with InputMixin<DateTime?, BookingError, CheckInInput> {
  const CheckInInput.untouched() : super.untouched(mode: ValidationMode.blur);

  const CheckInInput.touched({super.value, super.remoteError})
    : super.touched(mode: ValidationMode.blur);

  CheckInInput._(super.data) : super.fromData();

  @override
  List<Validator<DateTime?, BookingError>> get validators => const [
    _RequiredDateValidator(),
    _NotInPastValidator(),
  ];

  @override
  CheckInInput update({
    DateTime? value,
    InputStatus? status,
    ValidationMode? mode,
    BookingError? remoteError,
  }) => CheckInInput._(
    prepareUpdate(value: value, status: status, mode: mode, remoteError: remoteError),
  );
}

class CheckOutInput extends DateTimeInput<BookingError>
    with InputMixin<DateTime?, BookingError, CheckOutInput> {
  const CheckOutInput.untouched() : super.untouched(mode: ValidationMode.blur);

  const CheckOutInput.touched({super.value, super.remoteError})
    : super.touched(mode: ValidationMode.blur);

  CheckOutInput._(super.data) : super.fromData();

  @override
  List<Validator<DateTime?, BookingError>> get validators => const [
    _RequiredDateValidator(),
  ];

  @override
  CheckOutInput update({
    DateTime? value,
    InputStatus? status,
    ValidationMode? mode,
    BookingError? remoteError,
  }) => CheckOutInput._(
    prepareUpdate(value: value, status: status, mode: mode, remoteError: remoteError),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BookingSchema
// ─────────────────────────────────────────────────────────────────────────────

class BookingSchema extends FormSchema {
  final CheckInInput checkIn;
  final CheckOutInput checkOut;
  final SimpleNumberInput<int, String> guests;

  BookingSchema({
    CheckInInput? checkIn,
    CheckOutInput? checkOut,
    SimpleNumberInput<int, String>? guests,
  }) : checkIn = checkIn ?? const CheckInInput.untouched(),
       checkOut = checkOut ?? const CheckOutInput.untouched(),
       guests =
           guests ??
           NumberInputBuilder<int, String>()
               .min(1, 'At least 1 guest required')
               .max(10, 'Maximum 10 guests per booking')
               .buildUntouched(value: 1);

  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'check_in': checkIn,
    'check_out': checkOut,
    'guests': guests,
  };

  /// SchemaValidator — cross-field validation rules that span multiple inputs.
  ///
  /// These cannot live inside CheckOutInput because CheckOutInput has no
  /// reference to CheckInInput. SchemaValidator receives the whole schema.
  @override
  List<SchemaValidator<dynamic>> get schemaValidators => [
    SchemaValidator.of<BookingSchema, BookingError>((s) {
      final ci = s.checkIn.value;
      final co = s.checkOut.value;
      if (ci == null || co == null) return null; // inputs handle null

      if (!co.isAfter(ci)) return BookingError.checkOutBeforeCheckIn;

      final nights = co.difference(ci).inDays;
      if (nights < 1) return BookingError.tooShort;
      if (nights > 30) return BookingError.tooLong;

      return null;
    }),
  ];

  BookingSchema copyWith({
    CheckInInput? checkIn,
    CheckOutInput? checkOut,
    SimpleNumberInput<int, String>? guests,
  }) => BookingSchema(
    checkIn: checkIn ?? this.checkIn,
    checkOut: checkOut ?? this.checkOut,
    guests: guests ?? this.guests,
  );

  @override
  BookingSchema touchAll() => copyWith(
    checkIn: checkIn.markTouched(),
    checkOut: checkOut.markTouched(),
    guests: guests.markTouched(),
  );

  @override
  BookingSchema reset() => BookingSchema();

  int? get nightCount {
    if (checkIn.value == null || checkOut.value == null) return null;
    final n = checkOut.value!.difference(checkIn.value!).inDays;
    return n > 0 ? n : null;
  }
}
