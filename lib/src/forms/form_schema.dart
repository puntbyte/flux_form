// lib/src/forms/form_schema.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/forms/form_validator.dart';
import 'package:flux_form/src/forms/schema_validator.dart';

/// A base class for strongly-typed, aggregate form schemas.
///
/// ## What you must implement
///
/// 1. [namedInputs] — maps serialization keys to input instances.
/// 2. `copyWith` — field-level mutation (manual, Freezed, or build_runner).
/// 3. [touchAll] — marks every input touched via your `copyWith`.
/// 4. [reset] — resets every input to its initial value via your `copyWith`.
///
/// ## What you may override
///
/// - [nestedSchemas] — embed sub-schemas for sections (address, billing…).
/// - [schemaValidators] — cross-field validation rules.
/// - [populateFrom] — pre-fill from a data map for edit flows.
///
/// ## Minimal example
///
/// ```dart
/// class LoginSchema extends FormSchema {
///   final EmailInput email;
///   final PasswordInput password;
///
///   const LoginSchema({
///     this.email = const EmailInput.untouched(),
///     this.password = const PasswordInput.untouched(),
///   });
///
///   @override
///   Map<String, FormInput> get namedInputs =>
///       {'email': email, 'password': password};
///
///   LoginSchema copyWith({EmailInput? email, PasswordInput? password}) =>
///       LoginSchema(email: email ?? this.email, password: password ?? this.password);
///
///   @override
///   LoginSchema touchAll() => copyWith(
///     email: email.markTouched(), password: password.markTouched());
///
///   @override
///   LoginSchema reset() => copyWith(
///     email: email.reset(), password: password.reset());
/// }
/// ```
abstract class FormSchema {
  const FormSchema();

  // ── Required overrides ────────────────────────────────────

  /// Maps serialization keys to their respective input instances.
  ///
  /// Key order determines the order of [inputs], [errors], [invalidInputs],
  /// and [namedErrors].
  Map<String, FormInput<dynamic, dynamic>> get namedInputs;

  /// Returns a new schema with every input marked [InputStatus.touched].
  ///
  /// Implement by calling your `copyWith`, passing each input through
  /// [InputMixin.markTouched]. If the schema has [nestedSchemas], cascade
  /// into them explicitly:
  ///
  /// ```dart
  /// @override
  /// LoginSchema touchAll() => copyWith(
  ///   email: email.markTouched(),
  ///   password: password.markTouched(),
  /// );
  /// ```
  FormSchema touchAll();

  /// Returns a new schema with every input reset to its [FormInput.initialValue]
  /// and [InputStatus.untouched].
  ///
  /// ```dart
  /// @override
  /// LoginSchema reset() => copyWith(
  ///   email: email.reset(),
  ///   password: password.reset(),
  /// );
  /// ```
  FormSchema reset();

  // ── Optional overrides ────────────────────────────────────

  /// Sub-schemas embedded in this schema (address, billing, etc.).
  ///
  /// Nested schemas participate in [isValid], [isTouched], [isUntouched],
  /// [isModified], [values], and [changedValues] automatically.
  /// Include them in your [touchAll] and [reset] implementations explicitly.
  ///
  /// ```dart
  /// class RegisterSchema extends FormSchema {
  ///   final NameInput name;
  ///   final AddressSchema address;
  ///
  ///   @override
  ///   Map<String, FormSchema> get nestedSchemas => {'address': address};
  ///
  ///   @override
  ///   RegisterSchema touchAll() => copyWith(
  ///     name: name.markTouched(),
  ///     address: address.touchAll() as AddressSchema,
  ///   );
  /// }
  /// ```
  Map<String, FormSchema> get nestedSchemas => const {};

  /// Cross-field validation rules.
  ///
  /// These run in addition to per-input validators. Failures cause [isValid]
  /// to return false and are exposed via [schemaErrors].
  ///
  /// ```dart
  /// @override
  /// List<SchemaValidator<BookingError>> get schemaValidators => [
  ///   SchemaValidator.of<BookingSchema, BookingError>((s) {
  ///     if (s.checkIn.value == null || s.checkOut.value == null) return null;
  ///     return s.checkOut.value!.isAfter(s.checkIn.value!)
  ///         ? null : BookingError.checkOutBeforeCheckIn;
  ///   }),
  /// ];
  /// ```
  List<SchemaValidator<dynamic>> get schemaValidators => const [];

  /// Pre-fills all inputs from [data] and marks them touched.
  ///
  /// Override to support **edit flows** — loading an existing entity and
  /// pre-populating the form:
  ///
  /// ```dart
  /// @override
  /// LoginSchema populateFrom(Map<String, dynamic> data) => copyWith(
  ///   email: email.replaceValue(data['email'] as String? ?? ''),
  ///   password: password.replaceValue(data['password'] as String? ?? ''),
  /// );
  /// ```
  ///
  /// For **partial population** (only overwrite keys present in [data]):
  /// ```dart
  /// schema.populateFrom({
  ///   for (final entry in data.entries)
  ///     if (schema.namedInputs.containsKey(entry.key)) entry.key: entry.value,
  /// });
  /// ```
  ///
  /// Not implemented by default — throws [UnimplementedError].
  FormSchema populateFrom(Map<String, dynamic> data) =>
      throw UnimplementedError(
        '${runtimeType}.populateFrom() is not implemented. '
            'Override it to support pre-filling from a data map.',
      );

  // ── Derived list ──────────────────────────────────────────

  /// Flat list of all inputs derived from [namedInputs].
  List<FormInput<dynamic, dynamic>> get inputs => namedInputs.values.toList();

  // ── Aggregate validity ────────────────────────────────────

  /// True when every input is valid, every nested schema is valid, and all
  /// [schemaValidators] pass.
  bool get isValid =>
      FormValidator.validate(inputs) &&
          nestedSchemas.values.every((s) => s.isValid) &&
          isSchemaValid;

  bool get isNotValid => !isValid;

  /// True when all [schemaValidators] pass (cross-field rules only).
  bool get isSchemaValid => schemaErrors.isEmpty;

  /// True if any input has been interacted with, including nested schemas.
  bool get isTouched =>
      FormValidator.isTouched(inputs) ||
          nestedSchemas.values.any((s) => s.isTouched);

  /// True if no inputs have been touched, including those in nested schemas.
  bool get isUntouched =>
      FormValidator.isUntouched(inputs) &&
          nestedSchemas.values.every((s) => s.isUntouched);

  /// True if any input's current value differs from its initial value,
  /// or if any nested schema is modified.
  bool get isModified =>
      inputs.any((i) => i.isDirty) ||
          nestedSchemas.values.any((s) => s.isModified);

  // ── Serialization ─────────────────────────────────────────

  /// All current values keyed by [namedInputs]. Nested schemas appear as
  /// nested maps under their [nestedSchemas] key.
  ///
  /// ```dart
  /// await api.register(state.schema.values);
  /// // {'name': 'Alice', 'address': {'city': 'London', 'zip': 'EC1A 1BB'}}
  /// ```
  Map<String, dynamic> get values => {
    for (final e in namedInputs.entries) e.key: e.value.value,
    for (final e in nestedSchemas.entries) e.key: e.value.values,
  };

  /// Only the values of inputs that differ from their [FormInput.initialValue].
  ///
  /// Use for PATCH API calls — send only what the user changed:
  /// ```dart
  /// await api.patchProfile(state.schema.changedValues);
  /// ```
  Map<String, dynamic> get changedValues => {
    for (final e in namedInputs.entries)
      if (!e.value.isPristine) e.key: e.value.value,
    for (final e in nestedSchemas.entries)
      if (e.value.isModified) e.key: e.value.changedValues,
  };

  // ── Error access ──────────────────────────────────────────

  /// The error from the first invalid input, or null. Does not include
  /// [schemaErrors]. Use [firstErrorOf] when all inputs share error type [E].
  dynamic get firstError => FormValidator.firstError(inputs);

  /// Typed [firstError] for schemas where all inputs share error type [E].
  ///
  /// ```dart
  /// final msg = state.schema.firstErrorOf<AuthError>()?.message(context);
  /// ```
  E? firstErrorOf<E>() => FormValidator.firstError<E>(
    inputs.whereType<FormInput<dynamic, E>>().toList(),
  );

  /// All non-null errors from all inputs in [namedInputs] order.
  /// Does not include [schemaErrors].
  List<dynamic> get errors =>
      inputs.map((i) => i.error).whereType<Object>().toList();

  /// Cross-field errors produced by [schemaValidators].
  ///
  /// Display where cross-field feedback belongs (e.g., below a date range):
  /// ```dart
  /// if (state.schema.schemaErrors.firstOrNull case BookingError e)
  ///   Text(e.message(context));
  /// ```
  List<dynamic> get schemaErrors => schemaValidators
      .map((v) => v.validate(this))
      .whereType<Object>()
      .toList();

  /// Every invalid input in [namedInputs] order.
  ///
  /// Useful for "scroll to first error" behaviour.
  List<FormInput<dynamic, dynamic>> get invalidInputs =>
      FormValidator.validateGranularly(inputs);

  /// `{ fieldKey → error }` for every invalid input.
  ///
  /// Useful for server-error mapping and error-summary widgets:
  /// ```dart
  /// final errs = state.schema.namedErrors;
  /// // {'email': AuthError.invalidEmail, 'password': AuthError.tooShort}
  /// ```
  Map<String, dynamic> get namedErrors => {
    for (final e in namedInputs.entries)
      if (e.value.isNotValid) e.key: e.value.error,
  };

  // ── Submit guard ──────────────────────────────────────────

  /// Touches all inputs then checks validity — the canonical submit guard.
  ///
  /// Returns `(touched, isValid)`:
  /// - `touched` — schema with every input marked [InputStatus.touched].
  /// - `isValid` — whether [isValid] returns true on the touched schema.
  ///
  /// ```dart
  /// Future<void> submit() async {
  ///   final (touched, isValid) = state.schema.validate();
  ///   if (!isValid) {
  ///     emit(state.copyWith(schema: touched, status: SubmissionStatus.failure));
  ///     return;
  ///   }
  ///   await FormSubmitter<void>(
  ///     onStart:   () => emit(state.copyWith(status: SubmissionStatus.inProgress)),
  ///     onSubmit:  () => api.submit(state.schema.values),
  ///     onSuccess: (_) => emit(state.copyWith(status: SubmissionStatus.success)),
  ///     onError:   (e, s) => emit(state.copyWith(status: SubmissionStatus.failure)),
  ///   ).submit();
  /// }
  /// ```
  (FormSchema touched, bool isValid) validate() {
    final touched = touchAll();
    return (touched, touched.isValid);
  }
}