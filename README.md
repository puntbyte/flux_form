# Flux Form

**Flux Form** is a modular, type-safe, declarative form state management library for Dart and
Flutter. It eliminates the boilerplate of manual validation logic through **Composition**,
**Immutable State**, **Smart UI Logic**, and a rich built-in library of validators and sanitizers.

Designed to be **state-management agnostic** — works with Bloc, Riverpod, Provider, Signals,
MobX, or vanilla `setState`.

![Version](https://img.shields.io/badge/version-0.5.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)

> Heavily inspired by [**formz**](https://pub.dev/packages/formz). Flux Form builds upon its
> immutable-input pattern and expands it with built-in validators, sanitization pipelines,
> schema-level cross-field rules, multi-step wizards, and async validation.

---

## Table of Contents

1. [Installation](#installation)
2. [Core Concepts](#core-concepts)
3. [Error Types](#error-types)
4. [Inputs](#inputs)
    - [Abstract Bases vs Simple Concretes](#abstract-bases-vs-simple-concretes)
    - [Defining Custom Inputs](#defining-custom-inputs)
    - [Builder API](#builder-api)
    - [Input Lifecycle](#input-lifecycle)
    - [Validation Modes](#validation-modes)
    - [InputMixin Methods](#inputmixin-methods)
5. [Validators](#validators)
6. [Sanitizers](#sanitizers)
7. [FormSchema](#formschema)
    - [Defining a Schema](#defining-a-schema)
    - [Schema API Reference](#schema-api-reference)
    - [Nested Schemas](#nested-schemas)
    - [Cross-Field Validation](#cross-field-validation)
    - [Edit Flows — populateFrom](#edit-flows--populatefrom)
    - [PATCH APIs — changedValues](#patch-apis--changedvalues)
    - [Stateless Widget Reset — formKey](#stateless-widget-reset--formkey)
8. [FormMixin](#formmixin)
9. [MultiStepSchema](#multistepschema)
10. [Async Validation](#async-validation)
11. [State Management Integration](#state-management-integration)
12. [UI Integration](#ui-integration)
13. [FormSubmitter](#formsubmitter)
14. [Composition Utilities](#composition-utilities)
15. [Complete API Reference](#complete-api-reference)

---

## Installation

```yaml
dependencies:
  flux_form: ^0.5.0
```

```dart
import 'package:flux_form/flux_form.dart';
```

---

## Core Concepts

Flux Form is built on four principles:

**Immutable inputs** — Every `FormInput` is an immutable value object. Mutation returns a new
instance. This guarantees correct `==` equality for Bloc/Riverpod state comparisons.

**Pipeline architecture** — Sanitizers run before validators. Each pipeline is a `List` of
composable, independently testable rules.

**Typed errors** — `FormInput<T, E>` is generic over both value type `T` and error type `E`.
You choose: raw `String`, a plain `enum`, or an `enum implements FormError` for full
localisation support.

**Schema aggregation** — `FormSchema` groups inputs into a cohesive unit that handles aggregate
validity, serialization, cross-field rules, and UI reset — without coupling to any framework.

---

## Error Types

### Option A — `String` errors (prototyping)

```dart
class EmailInput extends StringInput<String> ... {
  @override
  List<Validator<String, String>> get validators => [
    StringValidator.required('This field is required'),
    FormatValidator.email('Invalid email address'),
  ];
}
```

### Option B — Plain `enum` (strict typing, UI handles localisation)

```dart
enum AuthError { required, invalidEmail, tooShort, usernameTaken }

class EmailInput extends StringInput<AuthError> ... {
  @override
  List<Validator<String, AuthError>> get validators => [
    StringValidator.required(AuthError.required),
    FormatValidator.email(AuthError.invalidEmail),
  ];
}

// UI:
errorText: switch (input.displayError(status)) {
  AuthError.required     => 'This field is required',
  AuthError.invalidEmail => 'Invalid email',
  null                   => null,
}
```

### Option C — `enum implements FormError` (recommended for production)

`FormError` requires two members: `String get code` (machine-readable, for API mapping /
analytics) and `String message([dynamic context])` (human-readable, supports localisation).

```dart
enum AuthError implements FormError {
  required('required'),
  invalidEmail('invalid_email'),
  tooShort('too_short'),
  usernameTaken('username_taken'),
  unknown('unknown');

  @override final String code;
  const AuthError(this.code);

  static AuthError fromCode(String? code) => AuthError.values.firstWhere(
    (e) => e.code == code,
    orElse: () => AuthError.unknown,
  );

  @override
  String message([dynamic context]) => switch (this) {
    AuthError.required      => 'This field is required',
    AuthError.invalidEmail  => 'Please enter a valid email address',
    AuthError.tooShort      => 'Must be at least 8 characters',
    AuthError.usernameTaken => 'This username is already taken',
    AuthError.unknown       => 'An unknown error occurred',
  };
}

// UI — no switch needed:
errorText: input.displayError(status)?.message(context)
```

---

## Inputs

### Abstract Bases vs Simple Concretes

Every input type comes in two forms.

| Abstract base (for inheritance) | Concrete (for composition) |
|---|---|
| `StringInput<E>` | `SimpleStringInput<E>` |
| `NumberInput<T extends num, E>` | `SimpleNumberInput<T, E>` |
| `BoolInput<E>` | `SimpleBoolInput<E>` |
| `DateTimeInput<E>` | `SimpleDateTimeInput<E>` |
| `BaseListInput<T, E>` | `ListInput<T, E>` |
| `MapInput<K, V, E>` | `SimpleMapInput<K, V, E>` |
| `ObjectInput<T, E extends FormError>` | `SimpleObjectInput<T, E>` |

**Extend the abstract base** when the same rules apply across multiple screens
(EmailInput, PasswordInput, UsernameInput). Rules are locked in once.

**Use the concrete class** for one-off fields that don't need a dedicated type. Rules are
passed via constructor arguments or built with the [Builder API](#builder-api).

### Defining Custom Inputs

Extend the abstract base and mix in `InputMixin<T, E, ConcreteType>`:

```dart
class EmailInput extends StringInput<AuthError>
    with InputMixin<String, AuthError, EmailInput> {

  const EmailInput.untouched({super.value = ''})
      : super.untouched(mode: ValidationMode.deferred);

  const EmailInput.touched({super.value = '', super.remoteError})
      : super.touched(mode: ValidationMode.deferred);

  // Private constructor — receives fully computed InputData from prepareUpdate.
  EmailInput._(super.data) : super.fromData();

  @override
  List<Sanitizer<String>> get sanitizers => [
    const StringSanitizer.trim(),
    const StringSanitizer.toLowerCase(),
  ];

  @override
  List<Validator<String, AuthError>> get validators => [
    StringValidator.required(AuthError.required),
    FormatValidator.email(AuthError.invalidEmail),
  ];

  @override
  EmailInput update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    AuthError? remoteError,
  }) => EmailInput._(
    prepareUpdate(value: value, status: status, mode: mode, remoteError: remoteError),
  );
}
```

**Why `InputMixin<T, E, ConcreteType>`?** It injects fluent mutator methods
(`replaceValue`, `setValue`, `reset`, `markTouched`, etc.) that return the concrete type
rather than the abstract `FormInput<T, E>`. Without it the methods would return a less-useful
base type.

**The `._()` private constructor pattern** is the recommended approach. `prepareUpdate`
calculates the next `InputData` (running sanitizers, validators, and resolving remote errors)
and the private constructor stores it directly. This is the most concise and safe `update`
implementation.

### Builder API

For one-off inputs that don't need a dedicated class, the builder API produces a fully
configured `Simple*` input in a single fluent expression:

```dart
// StringInputBuilder<E>
final email = StringInputBuilder<AuthError>()
    .trim()
    .toLowerCase()
    .required(AuthError.required)
    .email(AuthError.invalidEmail)
    .mode(ValidationMode.deferred)
    .buildUntouched();

// NumberInputBuilder<T, E>
final quantity = NumberInputBuilder<int, String>()
    .min(1, 'At least 1 required')
    .max(99, 'Maximum 99')
    .buildUntouched(value: 1);

// BoolInputBuilder<E>
final acceptTerms = BoolInputBuilder<String>()
    .isTrue('You must accept the Terms of Service')
    .mode(ValidationMode.deferred)
    .buildUntouched();

// DateTimeInputBuilder<E>
final checkIn = DateTimeInputBuilder<BookingError>()
    .required(BookingError.required)
    .after(DateTime.now(), BookingError.mustBeFuture)
    .mode(ValidationMode.blur)
    .buildUntouched();

// ListInputBuilder<T, E>
final tags = ListInputBuilder<String, String>()
    .minLength(1, 'Add at least one tag')
    .maxLength(10, 'Too many tags')
    .unique('Tags must be unique')
    .itemValidate(StringValidator.required('Tag cannot be empty'))
    .itemSanitize(StringSanitizer.trim())
    .buildUntouched();

// MapInputBuilder<K, V, E>
final metadata = MapInputBuilder<String, String, String>()
    .notEmpty('At least one entry required')
    .valueValidate(StringValidator.required('Value cannot be empty'))
    .buildUntouched();
```

All builders expose `.validate(Validator)` and `.sanitize(Sanitizer)` escape hatches for
rules not covered by named shortcuts.

### Input Lifecycle

Every `FormInput<T, E>` carries these read-only fields:

| Field            | Type             | Description                                 |
|------------------|------------------|---------------------------------------------|
| `value`          | `T`              | Current value                               |
| `initialValue`   | `T`              | Value at construction time                  |
| `status`         | `InputStatus`    | `untouched`, `touched`, or `validating`     |
| `mode`           | `ValidationMode` | `live`, `deferred`, or `blur`               |
| `error`          | `E?`             | Remote error (if set) ?? local error        |
| `localError`     | `E?`             | Result of running `validators`              |
| `isTouched`      | `bool`           | `status == InputStatus.touched`             |
| `isUntouched`    | `bool`           | `status == InputStatus.untouched`           |
| `isValid`        | `bool`           | `localError == null && remoteError == null` |
| `isNotValid`     | `bool`           | `!isValid`                                  |
| `isPristine`     | `bool`           | `value == initialValue`                     |
| `isDirty`        | `bool`           | `!isPristine`                               |
| `isValidating`   | `bool`           | `status == InputStatus.validating`          |
| `detailedErrors` | `List<E>`        | All failing validators (not just first)     |

### Validation Modes

`ValidationMode` controls when `displayError(SubmissionStatus)` returns a non-null error.

| Mode       | Error visible when                                    | Best for               |
|------------|-------------------------------------------------------|------------------------|
| `live`     | Field is touched (user has typed)                     | Password, search bar   |
| `deferred` | `SubmissionStatus.failure` only                       | Email, login forms     |
| `blur`     | Field is touched (UI must call `markTouched` on blur) | Username, date pickers |

`blur` mode is identical to `live` at runtime. The difference is a **UI contract**:
call `setValue()` in `onChanged` (no touch, error hidden while typing) and `markTouched()`
in `onEditingComplete` or a focus-lost callback (error revealed after leaving the field).

```dart
// blur mode contract in a Cubit:
void usernameChanged(String v) =>
    emit(state.copyWith(username: state.schema.username.setValue(v)));

void usernameBlurred() =>
    emit(state.copyWith(username: state.schema.username.markTouched()));

// Widget:
TextField(
  onChanged: cubit.usernameChanged,
  onEditingComplete: cubit.usernameBlurred,
)
```

### InputMixin Methods

All methods return the **concrete** input type (e.g., `EmailInput`, not `FormInput`).

| Method                                      | Description                                                                      |
|---------------------------------------------|----------------------------------------------------------------------------------|
| `replaceValue(T value)`                     | Updates value + marks touched. Standard `onChanged` handler.                     |
| `setValue(T value)`                         | Updates value, preserves current `InputStatus`. Use in blur mode `onChanged`.    |
| `reset()`                                   | Reverts to `initialValue`, marks untouched, clears remote error.                 |
| `markTouched()`                             | Sets status to touched without changing value. Use in blur mode blur handler.    |
| `markUntouched()`                           | Sets status to untouched.                                                        |
| `markValidating()`                          | Sets status to `validating`. Use before async checks.                            |
| `setRemoteError(E error)`                   | Injects a server-side error. Auto-cleared when value changes.                    |
| `clearRemoteError()`                        | Clears the remote error.                                                         |
| `setMode(ValidationMode)`                   | Changes validation mode dynamically.                                             |
| `resolveAsyncValidation(E? error)`          | Resolves async check: sets remote error (if non-null) and marks touched.         |
| `runAsync({task, onValidating})`            | Full async lifecycle: calls `onValidating` synchronously, awaits task, resolves. |
| `runBuiltInAsyncValidation({onValidating})` | Runs `asyncValidators` via `runAsync`.                                           |

`displayError(SubmissionStatus status)` → `E?` — the bridge between logic and UI. Returns
the error to display based on the field's mode and the form's submission status.

---

## Validators

All validators are `@immutable` classes implementing `Validator<T, E>`. They return `null`
for valid input and `E` for invalid input. Most built-in rules skip empty/null values
(returning `null`) — pair with `StringValidator.required` to also catch blanks.

### `StringValidator<E>` — `Validator<String, E>`

| Factory                                                          | Fails when                                                     |
|------------------------------------------------------------------|----------------------------------------------------------------|
| `required(E)`                                                    | `value.trim().isEmpty`                                         |
| `trimmedRequired(E)`                                             | Same as `required` — explicit alias documenting trim behaviour |
| `notEmpty(E)`                                                    | `value.isEmpty` (no trimming — whitespace is valid content)    |
| `minLength(int, E)`                                              | `value.length < min`                                           |
| `maxLength(int, E)`                                              | `value.length > max`                                           |
| `exactLength(int, E)`                                            | Non-empty and `value.length != length`                         |
| `lengthBetween(int min, int max, E)`                             | Non-empty and length outside `[min, max]`                      |
| `pattern(RegExp, E)`                                             | Non-empty and regex does not match                             |
| `isNumeric(E)`                                                   | Non-empty and cannot be parsed as `num`                        |
| `numericMin(num, E)`                                             | Parsed number `< min`                                          |
| `numericMax(num, E)`                                             | Parsed number `> max`                                          |
| `contains(String, E)`                                            | Does not contain substring                                     |
| `notContains(String, E)`                                         | Contains substring                                             |
| `startsWith(String, E)`                                          | Does not start with prefix                                     |
| `endsWith(String, E)`                                            | Does not end with suffix                                       |
| `noWhitespace(E)`                                                | Contains any whitespace character                              |
| `noLeadingTrailingWhitespace(E)`                                 | Has leading or trailing whitespace                             |
| `asciiOnly(E)`                                                   | Contains code point > 127                                      |
| `printableAscii(E)`                                              | Contains code point outside 32–126                             |
| `hasUppercase(E)`                                                | No A–Z character                                               |
| `hasLowercase(E)`                                                | No a–z character                                               |
| `hasDigit(E)`                                                    | No 0–9 character                                               |
| `hasSpecialChar(E)`                                              | No non-alphanumeric character                                  |
| `minUniqueChars(int, E)`                                         | Unique character count < min                                   |
| `passwordStrength(minUpper, minLower, minDigits, minSpecial, E)` | Any minimum not met                                            |

### `FormatValidator<E>` — `Validator<String, E>`

| Factory                          | Validates                                                    |
|----------------------------------|--------------------------------------------------------------|
| `email(E)`                       | RFC-style email format                                       |
| `url(E, {bool requireProtocol})` | HTTP/HTTPS URL; `requireProtocol: false` allows bare domains |
| `uuid(E)`                        | UUID (any version, 8-4-4-4-12 hex groups)                    |
| `creditCard(E)`                  | Luhn algorithm                                               |
| `hexColor(E)`                    | `#FFF` or `#FFFFFF`                                          |
| `alpha(E)`                       | Only A–Z / a–z                                               |
| `alphaNumeric(E)`                | Only A–Z / a–z / 0–9                                         |
| `ipv4(E)`                        | IPv4 dotted-decimal                                          |
| `ipv6(E)`                        | IPv6 full form (8 groups)                                    |
| `ip(E)`                          | IPv4 or IPv6                                                 |
| `domain(E)`                      | Domain name (labels + TLD ≥ 2 chars)                         |
| `e164Phone(E)`                   | E.164 international phone (`+12345678900`)                   |
| `slug(E)`                        | kebab-case (`[a-z0-9]+(-[a-z0-9]+)*`)                        |
| `base64(E)`                      | Valid Base64 string                                          |
| `json(E)`                        | Parseable JSON                                               |
| `iso8601(E)`                     | Parseable `DateTime.parse` string                            |
| `macAddress(E)`                  | `00:11:22:33:44:55` or `00-11-22-33-44-55`                   |
| `fileExtension(List<String>, E)` | Extension is in allowed list                                 |

### `NumberValidator<E>` — `Validator<num, E>`

| Factory                                             | Fails when               |
|-----------------------------------------------------|--------------------------|
| `min(num, E)`                                       | `value < min`            |
| `max(num, E)`                                       | `value > max`            |
| `positive(E)`                                       | `value < 0`              |
| `negative(E)`                                       | `value >= 0`             |
| `nonZero(E)`                                        | `value == 0`             |
| `between(num min, num max, E, {bool inclusive})`    | Outside `[min, max]`     |
| `notBetween(num min, num max, E, {bool inclusive})` | Inside `[min, max]`      |
| `integer(E)`                                        | `value % 1 != 0`         |
| `multipleOf(num, E)`                                | Not a multiple of factor |
| `even(E)`                                           | Not an even integer      |
| `odd(E)`                                            | Not an odd integer       |

### `BoolValidator<E>` — `Validator<bool, E>`

| Factory                    | Fails when          |
|----------------------------|---------------------|
| `isTrue(E)`                | `!value`            |
| `isFalse(E)`               | `value`             |
| `equals(bool expected, E)` | `value != expected` |

### `ComparableValidator<T extends Comparable<T>, E>` — `Validator<T, E>`

| Factory                                         | Fails when       |
|-------------------------------------------------|------------------|
| `greaterThan(T, E)`                             | `value <= other` |
| `lessThan(T, E)`                                | `value >= other` |
| `min(T, E)`                                     | `value < min`    |
| `max(T, E)`                                     | `value > max`    |
| `between(T min, T max, E, {bool inclusive})`    | Outside range    |
| `notBetween(T min, T max, E, {bool inclusive})` | Inside range     |

Use for `DateTime`, `Duration`, or any `Comparable<T>`. For membership checks, use
`ObjectValidator.oneOf` — it works for any type, not just `Comparable`.

### `ListValidator<T, E>` — `Validator<List<T>, E>`

| Factory                          | Fails when                 |
|----------------------------------|----------------------------|
| `notEmpty(E)`                    | `value.isEmpty`            |
| `minLength(int, E)`              | `value.length < min`       |
| `maxLength(int, E)`              | `value.length > max`       |
| `unique(E)`                      | Duplicate items exist      |
| `contains(T, E)`                 | Item not present           |
| `containsAll(List<T>, E)`        | Any candidate not present  |
| `containsNone(List<T>, E)`       | Any forbidden item present |
| `allMatch(bool Function(T), E)`  | Any item fails predicate   |
| `noneMatch(bool Function(T), E)` | Any item passes predicate  |
| `every(Validator<T, E>)`         | Any item fails validator   |
| `minUnique(int, E)`              | Unique count < min         |
| `maxUnique(int, E)`              | Unique count > max         |

### `MapValidator<K, V, E>` — `Validator<Map<K, V>, E>`

| Factory                              | Fails when                |
|--------------------------------------|---------------------------|
| `notEmpty(E)`                        | `value.isEmpty`           |
| `minLength(int, E)`                  | `value.length < min`      |
| `maxLength(int, E)`                  | `value.length > max`      |
| `containsKey(K, E)`                  | Key absent                |
| `requiresKeys(List<K>, E)`           | Any required key absent   |
| `allValues(bool Function(V), E)`     | Any value fails predicate |
| `allEntries(bool Function(K, V), E)` | Any entry fails predicate |

### `ObjectValidator<T, E>` — `Validator<T, E>`

| Factory                          | Fails when              |
|----------------------------------|-------------------------|
| `match(T, E)`                    | `value != other`        |
| `notMatch(T, E)`                 | `value == other`        |
| `oneOf(List<T>, E)`              | Value not in list       |
| `notOneOf(List<T>, E)`           | Value in list           |
| `predicate(bool Function(T), E)` | Predicate returns false |

### `LogicValidator<T, E>` — conditional / combinational validators

| Factory                          | Behaviour                                                 |
|----------------------------------|-----------------------------------------------------------|
| `when({condition, validator})`   | Apply validator only when `condition()` returns true      |
| `unless({condition, validator})` | Apply validator only when `condition()` returns false     |
| `where({predicate, validator})`  | Apply validator only when `predicate(value)` returns true |
| `any(List<Validator>, E)`        | Valid if AT LEAST ONE validator passes                    |
| `all(List<Validator>, E)`        | Valid if ALL validators pass                              |
| `none(List<Validator>, E)`       | Valid if NONE pass                                        |
| `xor(List<Validator>, E)`        | Valid if EXACTLY ONE passes                               |
| `custom(E? Function(T))`         | Delegates to a callback                                   |

`condition` is `bool Function()` — evaluated lazily at validation time, enabling reactive
cross-field logic by closing over other inputs.

### `FileValidator<E>` — `Validator<File, E>`

| Factory                          | Fails when                                      |
|----------------------------------|-------------------------------------------------|
| `sizeMax(int bytes, E)`          | File size > max                                 |
| `sizeMin(int bytes, E)`          | File size < min                                 |
| `sizeRange(int min, int max, E)` | File size outside range                         |
| `extension(List<String>, E)`     | Extension not in allowed list                   |
| `exists(E)`                      | File does not exist                             |
| `notEmpty(E)`                    | File size == 0                                  |
| `namePattern(RegExp, E)`         | Filename does not match pattern                 |
| `mimeTypes(List<String>, E)`     | Mime type not in allowed list (extension-based) |

### `ExternalValidator<T, E>` — adapting third-party validators

Adapts validators that follow the Flutter `String? Function(T? value)` signature
(e.g., `form_builder_validators`):

| Factory                                           | Description                             |
|---------------------------------------------------|-----------------------------------------|
| `ExternalValidator.delegate(rule)`                | Uses the external string error directly |
| `ExternalValidator.override(rule, E)`             | Uses external logic but your error type |
| `ExternalValidator.map(rule, E Function(String))` | Maps external string to your type       |

### `Validator.compose` — named, reusable pipelines

```dart
final passwordRules = Validator.compose<String, AuthError>([
  StringValidator.required(AuthError.required),
  StringValidator.minLength(8, AuthError.tooShort),
  StringValidator.hasUppercase(AuthError.noUppercase),
  StringValidator.hasDigit(AuthError.noDigit),
  StringValidator.hasSpecialChar(AuthError.noSpecialChar),
]);

// Drop the composed rule into any input's validators list:
class PasswordInput extends StringInput<AuthError> ... {
  @override List<Validator<String, AuthError>> get validators => [passwordRules];
}
```

`Validator.compose` runs validators in order and returns the first error — identical
behaviour to a plain `List` but named, reusable, and expressible as a single constant.

`AsyncValidator.compose` does the same for async validators (sequential execution).

---

## Sanitizers

Sanitizers run **before** validators on every value update. They transform values but never
produce errors. All sanitizers are `@immutable`.

### `StringSanitizer` — `Sanitizer<String>`

| Factory                    | Transformation                                         |
|----------------------------|--------------------------------------------------------|
| `trim()`                   | Remove leading/trailing whitespace                     |
| `collapseWhitespace()`     | Trim + reduce internal whitespace runs to single space |
| `removeSpaces()`           | Remove ALL whitespace characters                       |
| `toLowerCase()`            | Lowercase all characters                               |
| `toUpperCase()`            | Uppercase all characters                               |
| `capitalize()`             | First char uppercase, rest lowercase                   |
| `digitsOnly()`             | Remove all non-digit characters                        |
| `replace(Pattern, String)` | Replace pattern with replacement string                |
| `truncate(int maxLength)`  | Silently cap to max characters                         |

### `NumberSanitizer` — `Sanitizer<num>`

| Factory                   | Transformation           |
|---------------------------|--------------------------|
| `round()`                 | Round to nearest integer |
| `ceil()`                  | Round up                 |
| `floor()`                 | Round down               |
| `abs()`                   | Absolute value           |
| `clamp(num min, num max)` | Clamp to range           |

Use `.adapt<T>()` to narrow `Sanitizer<num>` to `Sanitizer<int>` or `Sanitizer<double>`
when your input is typed to a `num` subtype.

### `ListSanitizer<T>` — `Sanitizer<List<T>>`

| Factory                         | Transformation                                |
|---------------------------------|-----------------------------------------------|
| `unique()`                      | Remove duplicates (preserves insertion order) |
| `remove(T value)`               | Remove all occurrences of a specific value    |
| `removeWhere(bool Function(T))` | Remove items matching predicate               |
| `sort()`                        | Sort (requires `T` to be `Comparable`)        |

### `Sanitizer.compose` — named, reusable pipelines

```dart
final emailSanitizers = Sanitizer.compose<String>([
  const StringSanitizer.trim(),
  const StringSanitizer.toLowerCase(),
]);

class EmailInput extends StringInput<AuthError> ... {
  @override List<Sanitizer<String>> get sanitizers => [emailSanitizers];
}
```

### `Sanitizer.adapt<S extends T>()` — subtype narrowing

Adapts a `Sanitizer<T>` to accept a subtype `S`. Used internally by `NumberInputBuilder`
to narrow `NumberSanitizer` (which targets `num`) to `Sanitizer<int>` or `Sanitizer<double>`.

---

## FormSchema

### Defining a Schema

Extend `FormSchema` and implement four things:

```dart
class LoginSchema extends FormSchema {
  final EmailInput email;
  final PasswordInput password;

  const LoginSchema({
    this.email = const EmailInput.untouched(),
    this.password = const PasswordInput.untouched(),
    super.formKey, // thread formKey through every constructor
  });

  // 1. namedInputs — keys become the keys in values / namedErrors / changedValues.
  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'email':    email,
    'password': password,
  };

  // 2. copyWith — field-level mutation. Can be hand-written or generated by Freezed.
  LoginSchema copyWith({EmailInput? email, PasswordInput? password, int? formKey}) =>
      LoginSchema(
        email:    email    ?? this.email,
        password: password ?? this.password,
        formKey:  formKey  ?? this.formKey,
      );

  // 3. touchAll — mark every input touched (reveal deferred errors on submit).
  //    Do NOT increment formKey here.
  @override
  LoginSchema touchAll() => copyWith(
    email:    email.markTouched(),
    password: password.markTouched(),
  );

  // 4. reset — revert to initial values AND increment formKey.
  //    nextFormKey causes keyed TextFields to be recreated by Flutter.
  @override
  LoginSchema reset() => LoginSchema(formKey: nextFormKey);
}
```

### Schema API Reference

#### Validity

| Getter          | Type   | Description                                                   |
|-----------------|--------|---------------------------------------------------------------|
| `isValid`       | `bool` | All inputs valid + all nested schemas valid + `isSchemaValid` |
| `isNotValid`    | `bool` | `!isValid`                                                    |
| `isSchemaValid` | `bool` | All `schemaValidators` pass (cross-field only)                |
| `isTouched`     | `bool` | Any input or nested schema has been interacted with           |
| `isUntouched`   | `bool` | No inputs have been touched                                   |
| `isModified`    | `bool` | Any input or nested schema is dirty (`isDirty`)               |

#### Serialization

| Getter          | Type                   | Description                                                |
|-----------------|------------------------|------------------------------------------------------------|
| `values`        | `Map<String, dynamic>` | All current values keyed by `namedInputs`                  |
| `changedValues` | `Map<String, dynamic>` | Only dirty inputs; nested schemas appear when `isModified` |

#### Error Access

| Getter / Method     | Type                   | Description                                                |
|---------------------|------------------------|------------------------------------------------------------|
| `firstError`        | `dynamic`              | Error from first invalid input; `null` if all valid        |
| `firstErrorOf<E>()` | `E?`                   | Typed `firstError` when all inputs share error type `E`    |
| `errors`            | `List<dynamic>`        | All non-null errors from all inputs in `namedInputs` order |
| `schemaErrors`      | `List<dynamic>`        | Errors from `schemaValidators`                             |
| `invalidInputs`     | `List<FormInput>`      | All invalid inputs in `namedInputs` order                  |
| `namedErrors`       | `Map<String, dynamic>` | `{fieldKey: error}` for every invalid input                |

#### Submit Guard

```dart
Future<void> submit() async {
  // validate() = touchAll() + check isValid, returned as a record.
  final (touched, isValid) = state.schema.validate();
  if (!isValid) {
    emit(state.copyWith(schema: touched, status: SubmissionStatus.failure));
    return;
  }
  await FormSubmitter<void>(
    onStart:   () => emit(state.copyWith(status: SubmissionStatus.inProgress)),
    onSubmit:  () => api.login(state.schema.values),
    onSuccess: (_) => emit(state.copyWith(status: SubmissionStatus.success)),
    onError:   (_, __) => emit(state.copyWith(status: SubmissionStatus.failure)),
  ).submit();
}
```

### Nested Schemas

Override `nestedSchemas` to embed a sub-schema. It participates in all aggregate properties
automatically.

```dart
class RegisterSchema extends FormSchema {
  final NameInput name;
  final AddressSchema address; // sub-schema

  @override
  Map<String, FormSchema> get nestedSchemas => {'address': address};

  @override
  RegisterSchema touchAll() => copyWith(
    name:    name.markTouched(),
    address: address.touchAll() as AddressSchema, // cascade
  );

  @override
  RegisterSchema reset() => RegisterSchema(formKey: nextFormKey);
}
```

Nested schemas appear as nested maps in `values` and `changedValues`:
`{'name': 'Alice', 'address': {'city': 'London', 'post_code': 'EC1A 1BB'}}`.

### Cross-Field Validation

Override `schemaValidators` and return `SchemaValidator.of<ConcreteSchema, E>(fn)`:

```dart
@override
List<SchemaValidator<dynamic>> get schemaValidators => [
  SchemaValidator.of<BookingSchema, BookingError>((s) {
    if (s.checkIn.value == null || s.checkOut.value == null) return null;
    return s.checkOut.value!.isAfter(s.checkIn.value!)
        ? null
        : BookingError.checkOutBeforeCheckIn;
  }),
];
```

Schema errors surface via `schema.schemaErrors` and make `isValid` return `false`.
Display them separately from per-field errors:

```dart
if (schema.schemaErrors.firstOrNull case BookingError e)
  Text(e.message(context));
```

### Edit Flows — `populateFrom`

Override `populateFrom(Map<String, dynamic>)` to pre-fill the form from a server response:

```dart
@override
ProfileSchema populateFrom(Map<String, dynamic> data) => copyWith(
  displayName: displayName.replaceValue(data['display_name'] as String? ?? ''),
  bio:         bio.replaceValue(data['bio'] as String? ?? ''),
  address:     address.populateFrom(data['address'] as Map<String, dynamic>? ?? {}),
);
```

Call in the Cubit constructor to open the form pre-filled:

```dart
EditProfileCubit() : super(const EditProfileState()) {
  final populated = const ProfileSchema().populateFrom(_serverData);
  emit(state.copyWith(schema: populated as ProfileSchema));
}
```

For partial population (PATCH workflows — only overwrite keys present in the map):
```dart
schema.populateFrom({
  for (final entry in partialData.entries)
    if (schema.namedInputs.containsKey(entry.key)) entry.key: entry.value,
});
```

### PATCH APIs — `changedValues`

`changedValues` returns only inputs where `isDirty == true`:

```dart
// Only sends fields the user actually changed:
await api.patchProfile(state.schema.changedValues);
```

Track whether anything changed:
```dart
if (schema.isModified)
  Chip(label: Text('Unsaved changes'))
```

Track whether a specific field changed:
```dart
if (schema.displayName.isDirty)
  Text('✏ Modified')
```

### Stateless Widget Reset — `formKey`

`TextField(onChanged: ...)` owns its text internally and ignores external value changes
after the first build. The only way to reset visible text **without a
`TextEditingController` or `StatefulWidget`** is to change the widget's `key`.

`FormSchema.formKey` is an immutable `int` that `reset()` increments via `nextFormKey`.
Use it as a `ValueKey` prefix:

```dart
// Stateless — no controller, no StatefulWidget:
TextField(
  key: ValueKey('${state.schema.formKey}_email'),
  onChanged: cubit.emailChanged,
  decoration: InputDecoration(
    errorText: state.schema.email.displayError(state.status)?.message(context),
  ),
)
```

When the cubit emits a reset schema, `formKey` has changed. Flutter destroys the old
`TextField` and creates a fresh one — visible text cleared automatically.

**Rules:**
- `reset()` must pass `nextFormKey` to the constructor.
- `touchAll()` must NOT increment `formKey`.
- `copyWith()` must thread `formKey` through as a passable parameter.
- Use a unique string prefix per field: `'${schema.formKey}_email'`, `'${schema.formKey}_password'`.

---

## FormMixin

`FormMixin` is the Formz-style alternative for state classes that manage inputs individually
rather than through a `FormSchema`. Mix it into your state class and implement `inputs`:

```dart
class LoginState extends Equatable with FormMixin {
  final EmailInput email;
  final PasswordInput password;
  final SubmissionStatus status;

  @override
  List<FormInput<dynamic, dynamic>> get inputs => [email, password];
}
```

`FormMixin` provides the same computed properties as `FormSchema`:
`isValid`, `isNotValid`, `isTouched`, `isUntouched`, `invalidInputs`, `errors`.

`touchAll()` and `reset()` return `List<FormInput>` (not a reconstructed state), so you
must unpack them manually into `copyWith`. If this becomes burdensome, migrate to
`FormSchema` which handles reconstruction automatically via `touchAll()` and `reset()`.

---

## MultiStepSchema

`MultiStepSchema` models a multi-step form wizard. It is a concrete, immutable class — not
abstract, not extended.

```dart
final wizard = MultiStepSchema(steps: [
  PersonalStep(),
  AccountStep(),
  PreferencesStep(),
]);
```

### Navigation

All navigation methods return a new `MultiStepSchema` — the current instance is never mutated.

| Method                | Returns           | Description                                |
|-----------------------|-------------------|--------------------------------------------|
| `advance()`           | `MultiStepSchema` | Move to next step; no-op on last step      |
| `back()`              | `MultiStepSchema` | Move to previous step; no-op on first step |
| `goToStep(int index)` | `MultiStepSchema` | Jump to index (clamped to valid range)     |

### Mutation

| Method                          | Returns           | Description                               |
|---------------------------------|-------------------|-------------------------------------------|
| `updateCurrentStep(FormSchema)` | `MultiStepSchema` | Replace current step with updated version |
| `updateStep(int, FormSchema)`   | `MultiStepSchema` | Replace step at index                     |

### Validation

| Method                  | Returns                   | Description                        |
|-------------------------|---------------------------|------------------------------------|
| `validateCurrentStep()` | `(MultiStepSchema, bool)` | Touch + validate current step only |
| `validateAll()`         | `(MultiStepSchema, bool)` | Touch + validate all steps         |

```dart
// Guard before advancing:
void next() {
  final (validated, isValid) = state.wizard.validateCurrentStep();
  if (!isValid) {
    emit(state.copyWith(wizard: validated, status: SubmissionStatus.failure));
    return;
  }
  emit(state.copyWith(wizard: validated.advance(), status: SubmissionStatus.idle));
}
```

### Properties

| Property             | Type                   | Description                          |
|----------------------|------------------------|--------------------------------------|
| `currentStep`        | `FormSchema`           | The active step                      |
| `currentStepIndex`   | `int`                  | Zero-based index                     |
| `currentStepNumber`  | `int`                  | One-based display index              |
| `totalSteps`         | `int`                  | Total number of steps                |
| `isFirstStep`        | `bool`                 | At step 0                            |
| `isLastStep`         | `bool`                 | At final step                        |
| `isCurrentStepValid` | `bool`                 | Current step passes all validators   |
| `allStepsValid`      | `bool`                 | Every step passes all validators     |
| `progress`           | `double`               | `currentStepNumber / totalSteps`     |
| `completedSteps`     | `int`                  | Count of valid steps                 |
| `values`             | `Map<String, dynamic>` | Merged values from all steps         |
| `changedValues`      | `Map<String, dynamic>` | Merged changed values from all steps |

`touchAll()` cascades into all steps. `reset()` cascades and returns to step 0.

---

## Async Validation

### Declaring async validators on the input

```dart
class UsernameInput extends StringInput<AuthError>
    with InputMixin<String, AuthError, UsernameInput> {

  @override
  List<AsyncValidator<String, AuthError>> get asyncValidators => [
    _UsernameAvailabilityValidator(),
  ];
}

class _UsernameAvailabilityValidator extends AsyncValidator<String, AuthError> {
  _UsernameAvailabilityValidator() : super(AuthError.usernameTaken);

  @override
  Future<AuthError?> validate(String value) async {
    await Future.delayed(const Duration(milliseconds: 800));
    const taken = {'admin', 'root', 'test'};
    return taken.contains(value.toLowerCase()) ? error : null;
  }
}
```

### Running async validation with `runAsync`

`runAsync` handles the full lifecycle without boilerplate:

```dart
Future<void> usernameBlurred() async {
  final touched = state.username.markTouched();
  emit(state.copyWith(username: touched));
  if (!touched.isValid) return; // skip async if sync already fails

  // 1. onValidating fires synchronously — emit spinner state immediately.
  // 2. Awaits task — your API call.
  // 3. Returns resolved input — error set or cleared.
  final resolved = await state.username.runAsync(
    task: () => _checkAvailability(state.username.value),
    onValidating: (v) => emit(state.copyWith(username: v)),
  );
  emit(state.copyWith(username: resolved));
}
```

### Running built-in `asyncValidators` via `runBuiltInAsyncValidation`

```dart
final resolved = await state.username.runBuiltInAsyncValidation(
  onValidating: (v) => emit(state.copyWith(username: v)),
);
emit(state.copyWith(username: resolved));
```

### Parallel async validation

`ValidatorPipeline.validateAsyncParallel` fires all validators simultaneously and returns the
first error in **declaration order** (not completion order):

```dart
final error = await ValidatorPipeline.validateAsyncParallel<String, String>(
  username,
  [AvailabilityCheck(), BannedWordsCheck()],
);
```

Both validators run in parallel via `Future.wait`. If `BannedWordsCheck` (300 ms) finishes
before `AvailabilityCheck` (700 ms), the results are still scanned in declaration order —
`AvailabilityCheck`'s error wins if both fail.

### Debouncing

Flux Form does not provide a built-in debouncer. Use `dart:async Timer`,
`rxdart`, `easy_debounce`, or `stream_transform` — `runAsync` is fully
scheduling-agnostic:

```dart
// dart:async Timer — zero dependencies:
Timer? _timer;

void usernameChanged(String v) {
  emit(state.copyWith(username: state.username.setValue(v)));
  _timer?.cancel();
  _timer = Timer(const Duration(milliseconds: 500), () async {
    final resolved = await state.username.runAsync(
      task: () => api.checkUsername(state.username.value),
      onValidating: (v) => emit(state.copyWith(username: v)),
    );
    emit(state.copyWith(username: resolved));
  });
}

@override
Future<void> close() {
  _timer?.cancel();
  return super.close();
}
```

---

## State Management Integration

Flux Form provides the **data structure**. Your state management layer provides **data flow**.
The pattern is identical across all libraries.

### Cubit / Bloc (flutter_bloc)

```dart
class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void emailChanged(String v) => emit(state.copyWith(
    schema: state.schema.copyWith(email: state.schema.email.replaceValue(v)),
    status: SubmissionStatus.idle,
  ));

  Future<void> submit() async {
    final (touched, isValid) = state.schema.validate();
    if (!isValid) {
      emit(state.copyWith(schema: touched, status: SubmissionStatus.failure));
      return;
    }
    await FormSubmitter<void>(
      onStart:   () => emit(state.copyWith(status: SubmissionStatus.inProgress)),
      onSubmit:  () => api.login(state.schema.values),
      onSuccess: (_) => emit(state.copyWith(status: SubmissionStatus.success)),
      onError:   (_, __) => emit(state.copyWith(status: SubmissionStatus.failure)),
    ).submit();
  }
}
```

### Riverpod (Notifier)

```dart
class LoginNotifier extends Notifier<LoginSchema> {
  @override
  LoginSchema build() => const LoginSchema();

  void emailChanged(String v) =>
      state = state.copyWith(email: state.email.replaceValue(v));

  void submit() {
    if (state.isValid) api.login(state.values);
  }
}
```

### Provider (ChangeNotifier)

```dart
class LoginProvider extends ChangeNotifier {
  LoginSchema _schema = const LoginSchema();
  LoginSchema get schema => _schema;

  void emailChanged(String v) {
    _schema = _schema.copyWith(email: _schema.email.replaceValue(v));
    notifyListeners();
  }
}
```

### Vanilla `setState`

```dart
class _LoginScreen extends State<LoginScreen> {
  LoginSchema _schema = const LoginSchema();

  void _emailChanged(String v) => setState(() {
    _schema = _schema.copyWith(email: _schema.email.replaceValue(v));
  });
}
```

---

## UI Integration

### Standard text field

```dart
// StatelessWidget — no TextEditingController needed.
TextField(
  key: ValueKey('${state.schema.formKey}_email'), // enables stateless reset
  onChanged: cubit.emailChanged,
  decoration: InputDecoration(
    labelText: 'Email',
    // displayError respects ValidationMode automatically.
    errorText: state.schema.email.displayError(state.status)?.message(context),
    suffixIcon: state.schema.email.isValid
        ? const Icon(Icons.check_circle_outline, color: Colors.green)
        : null,
  ),
)
```

### Bool / checkbox

`BoolInput` has no built-in `errorText` property in Flutter. Display the error manually:

```dart
Column(children: [
  CheckboxListTile(
    title: const Text('I accept the Terms of Service'),
    value: state.schema.acceptTerms.value,
    onChanged: (v) => cubit.acceptTermsChanged(v ?? false),
  ),
  if (state.schema.acceptTerms.displayError(state.status) != null)
    Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Text(
        state.schema.acceptTerms.displayError(state.status)!,
        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
      ),
    ),
])
```

### Date picker (blur mode)

Selecting a date is the "blur event" — update value and mark touched in one chain:

```dart
onTap: () async {
  final d = await showDatePicker(...);
  if (d != null) cubit.checkInSelected(d);
}

// Cubit:
void checkInSelected(DateTime d) => emit(state.copyWith(
  schema: state.schema.copyWith(
    checkIn: state.schema.checkIn.setValue(d).markTouched(),
  ),
));
```

### Password strength meter (`detailedErrors`)

```dart
// detailedErrors runs ALL validators — not just the first — and returns every
// failing error. Use for requirement checklists and strength indicators.
Column(
  children: [
    (AuthError.tooShort,      'At least 8 characters'),
    (AuthError.noUppercase,   'One uppercase letter'),
    (AuthError.noDigit,       'One digit'),
    (AuthError.noSpecialChar, 'One special character'),
  ].map((req) {
    final met = !state.schema.password.detailedErrors.contains(req.$1);
    return Row(children: [
      Icon(met ? Icons.check_circle : Icons.radio_button_unchecked,
           color: met ? Colors.green : Colors.grey),
      Text(req.$2),
    ]);
  }).toList(),
)
```

### Submit button

```dart
ElevatedButton(
  onPressed: state.status.isInProgress ? null : cubit.submit,
  child: state.status.isInProgress
      ? const CircularProgressIndicator(color: Colors.white)
      : const Text('Submit'),
)
```

---

## FormSubmitter

Encapsulates the full async submission lifecycle — try/catch, status transitions, result
routing — so the Cubit handler stays flat:

```dart
await FormSubmitter<UserDto>(
  onStart:   () => emit(state.copyWith(status: SubmissionStatus.inProgress)),
  onSubmit:  () => api.register(state.schema.values),
  onSuccess: (user) => emit(state.copyWith(user: user, status: SubmissionStatus.success)),
  onError:   (error, stack) => emit(state.copyWith(status: SubmissionStatus.failure)),
).submit();
```

For architectures where the actual async work is delegated to another Bloc:

```dart
await FormSubmitter.delegated(onValid: () => authBloc.add(LoginRequested())).submit();
```

`SubmissionStatus` values: `idle`, `inProgress`, `success`, `failure`, `canceled`.
Helper getters: `isIdle`, `isInProgress`, `isSuccess`, `isFailure`, `isCanceled`,
`isCommitted` (`isInProgress || isSuccess`), `isFinalized` (`isSuccess || isFailure || isCanceled`).

---

## Composition Utilities

### `Validator.compose<T, E>`

```dart
final rules = Validator.compose<String, AuthError>([v1, v2, v3]);
```

Runs validators in order, returns first error. Behaves identically to a plain `List` used as
`validators`, but is named, storable as a constant, and composable with other composed rules.

### `Sanitizer.compose<T>`

```dart
final pipeline = Sanitizer.compose<String>([s1, s2, s3]);
```

Pipes value through sanitizers in sequence. Output of each sanitizer is input to the next.

### `AsyncValidator.compose<T, E>`

```dart
final asyncRules = AsyncValidator.compose<String, AuthError>([av1, av2]);
```

Runs async validators sequentially, returns first error.

### `ValidatorPipeline` — static helpers

| Method                                                                | Description                                             |
|-----------------------------------------------------------------------|---------------------------------------------------------|
| `validate<T, E>(value, validators)`                                   | Run sync validators, return first error                 |
| `validateWithHooks(value, validators, {onStart, onError, onSuccess})` | Same with lifecycle hooks                               |
| `validateAll<T, E>(value, validators)`                                | Run ALL validators, return list of ALL errors           |
| `validateAsync<T, E>(value, asyncValidators)`                         | Sequential async, return first error                    |
| `validateAsyncParallel<T, E>(value, asyncValidators)`                 | Parallel async, return first error in declaration order |

### `Validator.adapt<S extends T>()`

Narrows a `Validator<T, E>` to `Validator<S, E>` for extension types or `num` subtypes:

```dart
// NumberValidator<E> validates num. Adapt to Validator<int, E>:
NumberValidator.min(0, AuthError.negative).adapt<int>()
```

### `Sanitizer.adapt<S extends T>()`

Same concept for sanitizers:

```dart
NumberSanitizer.round().adapt<int>()  // Sanitizer<num> → Sanitizer<int>
```

---

## Complete API Reference

### Input Type Summary

| Input                                                             | Value Type      | Key features                                                               |
|-------------------------------------------------------------------|-----------------|----------------------------------------------------------------------------|
| `StringInput<E>` / `SimpleStringInput<E>`                         | `String`        | All string validators, sanitizers                                          |
| `NumberInput<T extends num, E>` / `SimpleNumberInput<T, E>`       | `T extends num` | `increment`, `decrement`; works for `int` and `double`                     |
| `BoolInput<E>` / `SimpleBoolInput<E>`                             | `bool`          | `toggle()` helper                                                          |
| `DateTimeInput<E>` / `SimpleDateTimeInput<E>`                     | `DateTime?`     | Nullable; `isAfter`, `isBefore`, `daysDifference` helpers                  |
| `BaseListInput<T, E>` / `ListInput<T, E>`                         | `List<T>`       | `addItem`, `setItem`, `removeItemAt`; two-tier validation (list + item)    |
| `MapInput<K, V, E>` / `SimpleMapInput<K, V, E>`                   | `Map<K, V>`     | `putItem`, `removeItem`, `valueErrorAt`; two-tier validation (map + value) |
| `ObjectInput<T, E extends FormError>` / `SimpleObjectInput<T, E>` | Any `T`         | For enum, DTO, sealed class; requires `FormError` error type               |

### `ListInput<T, E>` — List-specific API

| Method              | Returns           | Description                                             |
|---------------------|-------------------|---------------------------------------------------------|
| `addItem(T)`        | `ListInput<T, E>` | Sanitize + append + mark touched                        |
| `setItem(int, T)`   | `ListInput<T, E>` | Sanitize + replace at index + mark touched              |
| `removeItemAt(int)` | `ListInput<T, E>` | Remove at index + mark touched                          |
| `itemError`         | `E?`              | First item-level error (O(1) — cached from last update) |
| `itemErrorAt(int)`  | `E?`              | Item-level error at index (recomputed each call)        |

### `MapInput<K, V, E>` — Map-specific API

| Method            | Returns             | Description                              |
|-------------------|---------------------|------------------------------------------|
| `putItem(K, V)`   | `MapInput<K, V, E>` | Sanitize + insert/replace + mark touched |
| `removeItem(K)`   | `MapInput<K, V, E>` | Remove key + mark touched                |
| `valueErrorAt(K)` | `E?`                | Error for value at key                   |

### `AsyncValidator<T, E>`

```dart
abstract class AsyncValidator<T, E> {
  final E? error;
  const AsyncValidator([this.error]);
  Future<E?> validate(T value);
  static AsyncValidator<T, E> compose<T, E>(List<AsyncValidator<T, E>> validators);
}
```

### `SchemaValidator<E>`

```dart
abstract class SchemaValidator<E> {
  E? validate(FormSchema schema);

  // Typed factory — fn receives the concrete schema type S.
  static SchemaValidator<E> of<S extends FormSchema, E>(E? Function(S) fn);
}
```

### `FormError` interface

```dart
abstract interface class FormError {
  String get code;
  String message([covariant dynamic context]);
}
```

### `InputStatus` enum

`untouched` — initial state, no interaction. `touched` — user has interacted.
`validating` — async check in progress.

### `SubmissionStatus` enum

`idle` · `inProgress` · `success` · `failure` · `canceled`

Helper getters: `isIdle` · `isInProgress` · `isSuccess` · `isFailure` · `isCanceled` ·
`isCommitted` (`inProgress || success`) · `isFinalized` (`success || failure || canceled`).

### `ValidationMode` enum

`live` — error shown when touched. `deferred` — error hidden until `failure`.
`blur` — identical to `live` at runtime; UI contract: `setValue` on change, `markTouched` on blur.

---

## ❤️ Contributing

Issues and Pull Requests are welcome. Flux Form aims to be the standard for clean,
maintainable forms in Dart.

Repository: https://github.com/puntbyte/flux_form