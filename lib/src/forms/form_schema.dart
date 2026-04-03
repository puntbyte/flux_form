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
/// 4. [reset] — resets every input to its initial value **and increments
///    [formKey]** via your `copyWith`.
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
///     super.formKey,
///   });
///
///   @override
///   Map<String, FormInput> get namedInputs =>
///       {'email': email, 'password': password};
///
///   LoginSchema copyWith({
///     EmailInput? email,
///     PasswordInput? password,
///     int? formKey,
///   }) => LoginSchema(
///     email: email ?? this.email,
///     password: password ?? this.password,
///     formKey: formKey ?? this.formKey,
///   );
///
///   @override
///   LoginSchema touchAll() => copyWith(
///     email: email.markTouched(),
///     password: password.markTouched(),
///     // formKey unchanged — touchAll is not a reset
///   );
///
///   @override
///   LoginSchema reset() => LoginSchema(
///     // nextFormKey increments the counter → triggers widget recreation.
///     formKey: nextFormKey,
///   );
/// }
/// ```
///
/// ## Using formKey to reset visible text without controllers
///
/// `TextField(onChanged: ...)` owns its text internally and ignores
/// programmatic value changes after the first build. The only way to reset
/// the visible text without a [TextEditingController] is to change the
/// widget's [key], which causes Flutter to destroy and recreate it.
///
/// Pass `formKey` as a [ValueKey] prefix on every text field:
///
/// ```dart
/// // StatelessWidget — no TextEditingController, no StatefulWidget needed.
/// TextField(
///   key: ValueKey('${state.schema.formKey}_email'),
///   onChanged: cubit.emailChanged,
///   decoration: InputDecoration(
///     errorText: state.schema.email.displayError(state.status)?.message(context),
///   ),
/// )
/// ```
///
/// When [reset] is called the cubit emits a schema with an incremented
/// `formKey`. Flutter sees a new key, destroys the old `TextField`, and
/// creates a fresh one — visible text cleared, no controllers required.
abstract class FormSchema {
  // ── formKey ───────────────────────────────────────────────────────────────

  /// A monotonically increasing integer, incremented each time [reset] is
  /// called.
  ///
  /// Use as a [ValueKey] prefix on `TextField` / `TextFormField` widgets to
  /// force Flutter to recreate them (clearing visible text) when the form
  /// is programmatically reset — without needing a [TextEditingController]:
  ///
  /// ```dart
  /// TextField(
  ///   key: ValueKey('${state.schema.formKey}_email'),
  ///   onChanged: cubit.emailChanged,
  /// )
  /// ```
  ///
  /// Increment it inside your [reset] implementation via [nextFormKey].
  /// Leave it unchanged inside [touchAll] and `copyWith` — only a full
  /// reset should trigger widget recreation.
  final int formKey;

  const FormSchema({this.formKey = 0});

  /// Returns `formKey + 1`.
  ///
  /// Pass this to your schema constructor inside [reset] so that the counter
  /// advances and widgets bound to it are recreated:
  ///
  /// ```dart
  /// @override
  /// LoginSchema reset() => LoginSchema(formKey: nextFormKey);
  /// ```
  int get nextFormKey => formKey + 1;

  // ── Required overrides ────────────────────────────────────────────────────

  /// Maps serialization keys to their respective input instances.
  ///
  /// Key order determines the order of [inputs], [errors], [invalidInputs],
  /// and [namedErrors].
  Map<String, FormInput<dynamic, dynamic>> get namedInputs;

  /// Returns a new schema with every input marked [InputStatus.touched].
  ///
  /// Do **not** increment [formKey] here — `touchAll` is not a reset.
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
  /// and [InputStatus.untouched], **and with [formKey] incremented**.
  ///
  /// Increment [formKey] via [nextFormKey] so that `TextField` widgets keyed
  /// on it are recreated and their visible text is cleared automatically:
  ///
  /// ```dart
  /// @override
  /// LoginSchema reset() => LoginSchema(formKey: nextFormKey);
  ///                        //             ^^^ key incremented here
  /// ```
  FormSchema reset();

  // ── Optional overrides ────────────────────────────────────────────────────

  /// Sub-schemas embedded in this schema (address, billing, etc.).
  ///
  /// Nested schemas participate in [isValid], [isTouched], [isUntouched],
  /// [isModified], [values], and [changedValues] automatically.
  /// Include them in your [touchAll] and [reset] implementations explicitly.
  Map<String, FormSchema> get nestedSchemas => const {};

  /// Cross-field validation rules.
  ///
  /// These run in addition to per-input validators. Failures cause [isValid]
  /// to return false and are exposed via [schemaErrors].
  List<SchemaValidator<dynamic>> get schemaValidators => const [];

  /// Pre-fills all inputs from [data] and marks them touched.
  ///
  /// Not implemented by default — throws [UnimplementedError].
  FormSchema populateFrom(Map<String, dynamic> data) => throw UnimplementedError(
    '$runtimeType.populateFrom() is not implemented. '
    'Override it to support pre-filling from a data map.',
  );

  // ── Derived list ──────────────────────────────────────────────────────────

  List<FormInput<dynamic, dynamic>> get inputs => namedInputs.values.toList();

  // ── Aggregate validity ────────────────────────────────────────────────────

  bool get isValid =>
      FormValidator.validate(inputs) &&
      nestedSchemas.values.every((s) => s.isValid) &&
      isSchemaValid;

  bool get isNotValid => !isValid;

  bool get isSchemaValid => schemaErrors.isEmpty;

  bool get isTouched =>
      FormValidator.isTouched(inputs) || nestedSchemas.values.any((s) => s.isTouched);

  bool get isUntouched =>
      FormValidator.isUntouched(inputs) && nestedSchemas.values.every((s) => s.isUntouched);

  bool get isModified =>
      inputs.any((i) => i.isDirty) || nestedSchemas.values.any((s) => s.isModified);

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> get values => {
    for (final e in namedInputs.entries) e.key: e.value.value,
    for (final e in nestedSchemas.entries) e.key: e.value.values,
  };

  Map<String, dynamic> get changedValues => {
    for (final e in namedInputs.entries)
      if (!e.value.isPristine) e.key: e.value.value,
    for (final e in nestedSchemas.entries)
      if (e.value.isModified) e.key: e.value.changedValues,
  };

  // ── Error access ──────────────────────────────────────────────────────────

  dynamic get firstError => FormValidator.firstError(inputs);

  E? firstErrorOf<E>() => FormValidator.firstError<E>(
    inputs.whereType<FormInput<dynamic, E>>().toList(),
  );

  List<dynamic> get errors => inputs.map((i) => i.error).whereType<Object>().toList();

  List<dynamic> get schemaErrors =>
      schemaValidators.map((v) => v.validate(this)).whereType<Object>().toList();

  List<FormInput<dynamic, dynamic>> get invalidInputs => FormValidator.validateGranularly(inputs);

  Map<String, dynamic> get namedErrors => {
    for (final e in namedInputs.entries)
      if (e.value.isNotValid) e.key: e.value.error,
  };

  // ── Submit guard ──────────────────────────────────────────────────────────

  /// Touches all inputs then checks validity — the canonical submit guard.
  ///
  /// Returns `(touched, isValid)`. The touched schema should be emitted so
  /// the UI reveals all pending errors.
  ///
  /// ```dart
  /// Future<void> submit() async {
  ///   final (touched, isValid) = state.schema.validate();
  ///   if (!isValid) {
  ///     emit(state.copyWith(schema: touched, status: SubmissionStatus.failure));
  ///     return;
  ///   }
  ///   // ...
  /// }
  /// ```
  (FormSchema touched, bool isValid) validate() {
    final touched = touchAll();
    return (touched, touched.isValid);
  }
}
