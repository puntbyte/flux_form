// lib/src/forms/schema_validator.dart



import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/form_schema.dart';
import 'package:meta/meta.dart';

/// A validation rule that operates on an entire [FormSchema] rather than
/// a single input.
///
/// Use [SchemaValidator] for **cross-field** rules — rules that require reading
/// two or more inputs simultaneously:
///
/// - Password confirmation must match password.
/// - Check-out date must be after check-in date.
/// - At least one of phone or email must be provided.
/// - Tax ID is required when the "is company" checkbox is ticked.
///
/// ## Usage
///
/// Override [FormSchema.schemaValidators] in your concrete schema:
///
/// ```dart
/// class BookingSchema extends FormSchema {
///   final SimpleDateTimeInput<BookingError> checkIn;
///   final SimpleDateTimeInput<BookingError> checkOut;
///
///   // ... namedInputs, touchAll, reset, copyWith ...
///
///   @override
///   List<SchemaValidator<BookingError>> get schemaValidators => [
///     SchemaValidator.of<BookingSchema, BookingError>((s) {
///       if (s.checkIn.value == null || s.checkOut.value == null) return null;
///       return s.checkOut.value!.isAfter(s.checkIn.value!)
///           ? null
///           : BookingError.checkOutBeforeCheckIn;
///     }),
///   ];
/// }
/// ```
///
/// Schema errors are exposed via [FormSchema.schemaErrors], and
/// [FormSchema.isValid] returns false when any schema validator fails.
///
/// ## Error display
///
/// Schema-level errors are not tied to a specific input, so they are not
/// surfaced by [FormInput.displayError]. Display them explicitly in the UI:
///
/// ```dart
/// final schemaError = state.schema.schemaErrors.firstOrNull;
/// if (schemaError != null) {
///   Text(schemaError.message(context)); // if E implements FormError
/// }
/// ```
@immutable
abstract class SchemaValidator<E> {
  const SchemaValidator();

  /// Validates the [schema] and returns an error of type [E], or null if valid.
  E? validate(FormSchema schema);

  /// Creates a [SchemaValidator] from a typed callback.
  ///
  /// [S] is the **concrete** schema type. The internal cast from [FormSchema]
  /// to [S] is safe as long as you register this validator on — and only on —
  /// a schema whose runtime type is [S] (which is always the case when you
  /// declare it in [FormSchema.schemaValidators]).
  ///
  /// ```dart
  /// SchemaValidator.of<BookingSchema, BookingError>((booking) {
  ///   // `booking` is statically typed as BookingSchema — no cast needed.
  ///   if (booking.checkIn.value == null || booking.checkOut.value == null) {
  ///     return null; // let individual inputs report the required error
  ///   }
  ///   return booking.checkOut.value!.isAfter(booking.checkIn.value!)
  ///       ? null
  ///       : BookingError.checkOutBeforeCheckIn;
  /// })
  /// ```
  static SchemaValidator<E> of<S extends FormSchema, E>(
    E? Function(S schema) fn,
  ) => _TypedSchemaValidator<S, E>(fn);
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────────────────────────────────────

class _TypedSchemaValidator<S extends FormSchema, E> extends SchemaValidator<E> {
  final E? Function(S) _fn;

  const _TypedSchemaValidator(this._fn);

  @override
  E? validate(FormSchema schema) => _fn(schema as S);
}
