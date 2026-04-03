// lib/features/wizard/forms/wizard_steps.dart
//
// Demonstrates:
//   • MultiStepSchema — step-by-step form navigation
//   • StringInputBuilder — fluent builder API
//   • BoolInputBuilder — builder for toggles
//   • FormSchema touchAll / reset / validate per step

import 'package:flux_form/flux_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Personal details (builder API)
// ─────────────────────────────────────────────────────────────────────────────

class PersonalStep extends FormSchema {
  final SimpleStringInput<String> firstName;
  final SimpleStringInput<String> lastName;
  final SimpleStringInput<String> phone;

  PersonalStep({
    SimpleStringInput<String>? firstName,
    SimpleStringInput<String>? lastName,
    SimpleStringInput<String>? phone,
  }) : firstName = firstName ?? _firstNameBuilder.buildUntouched(),
       lastName = lastName ?? _lastNameBuilder.buildUntouched(),
       phone = phone ?? _phoneBuilder.buildUntouched();

  // ── Builder API ────────────────────────────────────────────────────────────
  // StringInputBuilder composes validators, sanitizers, and mode in one
  // fluent chain and produces a SimpleStringInput directly.
  static final StringInputBuilder<String> _firstNameBuilder = StringInputBuilder<String>()
      .trim()
      .capitalize()
      .required('First name is required')
      .minLength(2, 'Too short');

  static final StringInputBuilder<String> _lastNameBuilder = StringInputBuilder<String>()
      .trim()
      .capitalize()
      .required('Last name is required')
      .minLength(2, 'Too short');

  // collapseWhitespace → new StringSanitizer that trims + collapses internal spaces
  static final StringInputBuilder<String> _phoneBuilder = StringInputBuilder<String>()
      .digitsOnly() // sanitizer: strip non-digit chars
      .required('Phone number is required')
      .minLength(10, 'Enter a valid phone number')
      .maxLength(15, 'Phone number is too long')
      .mode(ValidationMode.deferred);

  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
  };

  PersonalStep copyWith({
    SimpleStringInput<String>? firstName,
    SimpleStringInput<String>? lastName,
    SimpleStringInput<String>? phone,
  }) => PersonalStep(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone ?? this.phone,
  );

  @override
  PersonalStep touchAll() => copyWith(
    firstName: firstName.markTouched(),
    lastName: lastName.markTouched(),
    phone: phone.markTouched(),
  );

  @override
  PersonalStep reset() => copyWith(
    firstName: firstName.reset(),
    lastName: lastName.reset(),
    phone: phone.reset(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Account (builder API + Validator.compose)
// ─────────────────────────────────────────────────────────────────────────────

class AccountStep extends FormSchema {
  final SimpleStringInput<String> email;
  final SimpleStringInput<String> password;
  final SimpleStringInput<String> confirmPassword;

  AccountStep({
    SimpleStringInput<String>? email,
    SimpleStringInput<String>? password,
    SimpleStringInput<String>? confirmPassword,
  }) : email = email ?? _emailBuilder.buildUntouched(),
       password = password ?? _passwordBuilder.buildUntouched(),
       confirmPassword = confirmPassword ?? _confirmBuilder.buildUntouched();

  // Validator.compose — a named, reusable password rule set.
  static final Validator<String, String> _passwordRules = Validator.compose<String, String>([
    const StringValidator.required('Password is required'),
    const StringValidator.minLength(8, 'At least 8 characters'),
    const StringValidator.hasUppercase('One uppercase letter'),
    const StringValidator.hasDigit('One digit'),
    const StringValidator.hasSpecialChar('One special character'),
  ]);

  static final StringInputBuilder<String> _emailBuilder = StringInputBuilder<String>()
      .trim()
      .toLowerCase()
      .required('Email is required')
      .email('Enter a valid email')
      .mode(ValidationMode.deferred);

  static final StringInputBuilder<String> _passwordBuilder = StringInputBuilder<String>()
      .validate(_passwordRules) // drop the composed rule set in
      .mode(ValidationMode.live);

  // Confirm password shares same base rules + custom check.
  // The cross-field check (must equal password) lives in AccountStep.schemaValidators.
  static final StringInputBuilder<String> _confirmBuilder = StringInputBuilder<String>()
      .required('Confirm password is required')
      .mode(ValidationMode.live);

  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'email': email,
    'password': password,
    'confirm_password': confirmPassword,
  };

  /// Cross-field validator — confirm must match password.
  /// Demonstrates [SchemaValidator] on a step-level schema.
  @override
  List<SchemaValidator<dynamic>> get schemaValidators => [
    SchemaValidator.of<AccountStep, String>((s) {
      if (s.password.value.isEmpty || s.confirmPassword.value.isEmpty) return null;
      return s.confirmPassword.value == s.password.value ? null : 'Passwords do not match';
    }),
  ];

  AccountStep copyWith({
    SimpleStringInput<String>? email,
    SimpleStringInput<String>? password,
    SimpleStringInput<String>? confirmPassword,
  }) => AccountStep(
    email: email ?? this.email,
    password: password ?? this.password,
    confirmPassword: confirmPassword ?? this.confirmPassword,
  );

  @override
  AccountStep touchAll() => copyWith(
    email: email.markTouched(),
    password: password.markTouched(),
    confirmPassword: confirmPassword.markTouched(),
  );

  @override
  AccountStep reset() => AccountStep();
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Preferences (BoolInputBuilder + ObjectValidator)
// ─────────────────────────────────────────────────────────────────────────────

class PreferencesStep extends FormSchema {
  final SimpleBoolInput<String> acceptTerms;
  final SimpleBoolInput<String> subscribeNewsletter;

  PreferencesStep({
    SimpleBoolInput<String>? acceptTerms,
    SimpleBoolInput<String>? subscribeNewsletter,
  }) : acceptTerms = acceptTerms ?? _termsBuilder.buildUntouched(),
       subscribeNewsletter = subscribeNewsletter ?? _newsletterBuilder.buildUntouched();

  static final BoolInputBuilder<String> _termsBuilder = BoolInputBuilder<String>()
      .isTrue('You must accept the Terms of Service')
      .mode(ValidationMode.deferred);

  // Newsletter is optional — no validators, always valid.
  static final _newsletterBuilder = BoolInputBuilder<String>();

  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'accept_terms': acceptTerms,
    'subscribe_newsletter': subscribeNewsletter,
  };

  PreferencesStep copyWith({
    SimpleBoolInput<String>? acceptTerms,
    SimpleBoolInput<String>? subscribeNewsletter,
  }) => PreferencesStep(
    acceptTerms: acceptTerms ?? this.acceptTerms,
    subscribeNewsletter: subscribeNewsletter ?? this.subscribeNewsletter,
  );

  @override
  PreferencesStep touchAll() => copyWith(
    acceptTerms: acceptTerms.markTouched(),
    subscribeNewsletter: subscribeNewsletter.markTouched(),
  );

  @override
  PreferencesStep reset() => PreferencesStep();
}
