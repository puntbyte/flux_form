## 0.5.0

🏗️ **The Schema & Composition Update**

This is a major release. It completes the input type hierarchy, introduces
cross-schema architecture primitives, adds a fluent builder API, and ships
a comprehensive async validation pipeline. Every change is a clean break —
no deprecation period.

---

### ⚠️ Breaking Changes

#### Input Hierarchy Renamed

All concrete list and object inputs have been renamed for consistency with
the rest of the input family.

| 0.4.x                                   | 0.5.0                                                                 |
|-----------------------------------------|-----------------------------------------------------------------------|
| `ListInput` (abstract base)             | `BaseListInput`                                                       |
| `SimpleListInput` (concrete)            | `ListInput`                                                           |
| `StandardInput<T, E extends FormError>` | `ObjectInput<T, E>` (abstract) + `SimpleObjectInput<T, E>` (concrete) |
| `GenericInput<T, E>`                    | Removed — use `SimpleObjectInput` or the builder API                  |

#### All Primitive Input Bases Are Now Truly Abstract

`StringInput`, `NumberInput`, `BoolInput`, `DateTimeInput`, and `MapInput`
were previously marked `final`. They are now `abstract` so user-defined
domain inputs can extend them via `InputMixin`. Each has a corresponding
`Simple*` concrete class for composition without subclassing.

#### `FormSchema` — `touchAll()` and `reset()` Are Now Abstract

Both methods must be implemented in every concrete schema. This was
previously optional; it is now enforced at compile time.

#### `FormSchema.reset()` Must Increment `formKey`

`FormSchema` now carries an immutable `int formKey` field. The `reset()`
implementation must pass `nextFormKey` to the constructor. This enables
stateless widget reset (see below).

#### `FormSubmitter` Signature Simplified

`FormSubmitter.submit([bool isValid])` — the `isValid` parameter is removed.
Validity checking is the caller's responsibility. `onInvalid` is also
removed.

#### Chain API Removed

`ValidatorBuilder`, `SanitizerBuilder`, `ValidatorChain`, and
`SanitizerChain` are removed. Use the new per-type builder classes instead.

#### `ComparableValidator.oneOf` / `notOneOf` Removed

Use `ObjectValidator.oneOf` / `notOneOf` — these work for any `T`, not just
`Comparable<T>`.

---

### ✨ New Features

#### `FormSchema` — Schema-Level Architecture

- **`formKey`** (`int`) — a generation counter, incremented by `reset()` via
  `nextFormKey`. Use as a `ValueKey` prefix on `TextField` widgets to force
  Flutter to recreate them on reset, clearing visible text without a
  `TextEditingController` or `StatefulWidget`.
- **`nestedSchemas`** (`Map<String, FormSchema>`) — embed sub-schemas (e.g.,
  `AddressSchema` inside `ProfileSchema`). Nested schemas participate in
  `isValid`, `isTouched`, `isModified`, `values`, and `changedValues`
  automatically.
- **`schemaValidators`** (`List<SchemaValidator<E>>`) — cross-field
  validation rules that receive the whole schema. Failures are surfaced via
  `schemaErrors` and included in `isValid`.
- **`populateFrom(Map<String, dynamic>)`** — pre-fill the form from a server
  response map (edit flows). Override in concrete schemas.
- **`touchAll()`** — marks every input touched. Now abstract.
- **`reset()`** — resets every input to its `initialValue` and
  `InputStatus.untouched`, and increments `formKey`. Now abstract.
- **`validate()`** — calls `touchAll()` then checks `isValid`. Returns the
  Dart record `(FormSchema touched, bool isValid)`.
- **`changedValues`** — like `values` but only includes inputs where
  `isDirty == true`. Nested schemas appear under their key only when
  `isModified`. Use for PATCH API calls.
- **`isModified`** — `true` when any input or nested schema has a value
  different from its `initialValue`.
- **`namedErrors`** — `Map<String, dynamic>` of `{fieldKey: error}` for
  every invalid input. Useful for server-error mapping.
- **`errors`** — flat `List<dynamic>` of all non-null errors.
- **`invalidInputs`** — `List<FormInput>` of all failing inputs.
- **`firstErrorOf<E>()`** — typed variant of `firstError` for schemas where
  all inputs share error type `E`.
- **`isSchemaValid`** — `true` when all `schemaValidators` pass (cross-field
  rules only, does not re-run per-input validators).
- **`schemaErrors`** — `List<dynamic>` of errors from `schemaValidators`.

#### `SchemaValidator<E>` — Cross-Field Validation

A new abstract class for rules that read two or more inputs simultaneously:

```dart
SchemaValidator.of<BookingSchema, BookingError>((s) {
  if (s.checkIn.value == null || s.checkOut.value == null) return null;
  return s.checkOut.value!.isAfter(s.checkIn.value!)
      ? null : BookingError.checkOutBeforeCheckIn;
})
```

#### `MultiStepSchema` — Wizard / Step-Based Forms

A concrete, immutable class wrapping an ordered list of `FormSchema` steps
with a `currentStepIndex` cursor. Key API:

- `currentStep` — the active `FormSchema`
- `advance()` / `back()` / `goToStep(int)` — navigation, all return new instances
- `updateCurrentStep(FormSchema)` / `updateStep(int, FormSchema)` — mutation
- `validateCurrentStep()` — returns `(MultiStepSchema, bool)`
- `validateAll()` — touches + validates every step
- `touchAll()` / `reset()` — cascade into all steps
- `values` — merged `Map<String, dynamic>` from all steps
- `changedValues` — merged changed values from all steps
- `progress` — `double` in `[0.0, 1.0]` based on current position
- `completedSteps` — count of valid steps
- `isFirstStep` / `isLastStep` — boundary flags

#### Builder API — Fluent Input Construction

Six per-type builder classes replace the removed chain API. Each builder
produces a fully configured `Simple*` input directly — no separate
validator/sanitizer lists needed:

- **`StringInputBuilder<E>`** — covers all `StringValidator`, `FormatValidator`,
  `StringSanitizer`, and `LogicValidator` rules as named methods.
- **`NumberInputBuilder<T extends num, E>`** — `NumberValidator` and
  `NumberSanitizer` methods, with `.adapt<T>()` applied automatically.
- **`BoolInputBuilder<E>`** — `BoolValidator` methods.
- **`DateTimeInputBuilder<E>`** — nullable-aware date validators
  (`.required()`, `.after()`, `.before()`, `.onOrAfter()`, `.onOrBefore()`,
  `.between()`).
- **`ListInputBuilder<T, E>`** — list-level and item-level validators and
  sanitizers in one builder, with `itemValidate()` / `itemSanitize()` for
  per-item rules.
- **`MapInputBuilder<K, V, E>`** — map-level and value-level rules.

All builders expose a `.validate(Validator)` / `.sanitize(Sanitizer)` escape
hatch for rules not covered by named shortcuts, and a `.mode(ValidationMode)`
call.

#### `MapValidator` — New Validator Namespace

Public namespace consistent with `StringValidator`, `NumberValidator`, etc.:

`notEmpty`, `minLength`, `maxLength`, `containsKey`, `requiresKeys`,
`allValues(predicate)`, `allEntries(predicate)`.

#### `Validator.compose` / `AsyncValidator.compose` / `Sanitizer.compose`

Static factory methods that bundle a list of validators or sanitizers into a
single named, reusable instance:

```dart
final passwordRules = Validator.compose([
  StringValidator.required(AuthError.required),
  StringValidator.minLength(8, AuthError.tooShort),
  StringValidator.hasUppercase(AuthError.noUppercase),
]);
```

#### Async Validation Pipeline

- **`FormInput.asyncValidators`** — declare async rules alongside sync rules
  on the input class.
- **`InputMixin.runAsync(task, onValidating)`** — the canonical async
  lifecycle: calls `onValidating` synchronously (for spinner), awaits the
  task, and returns the resolved input.
- **`InputMixin.runBuiltInAsyncValidation(onValidating)`** — delegates to the
  input's own `asyncValidators` getter.
- **`ValidatorPipeline.validateAsyncParallel`** — fires all async validators
  simultaneously via `Future.wait`, returns results in declaration order.

#### `InputMixin.setValue(T)`

Updates the value without marking the input as `InputStatus.touched`. This
is the correct method for the blur-mode contract: call `setValue` in
`onChanged`, `markTouched` in `onEditingComplete`.

#### `FormInput.isDirty`

Alias for `!isPristine`. `true` when the current value differs from
`initialValue`. Drives `FormSchema.changedValues` and `isModified`.

#### `ValidationMode.blur` — Documented UI Contract

`blur` mode is now fully documented. At runtime it is identical to `live`
(errors appear when touched). The difference is a UI contract:
- In `onChanged` → call `setValue()` (no touch, error hidden).
- In `onEditingComplete` / blur callback → call `markTouched()` (error revealed).
  This enables "validate on focus-loss" without any library-side focus tracking.

#### `EditableSchema` Mixin

Opt-in mixin for schemas that support `populateFrom`. Mix into a schema to
signal intent and enforce the override:

```dart
class ProfileSchema extends FormSchema with EditableSchema { ... }
```

#### New `StringSanitizer` Rules

- `collapseWhitespace()` — trims and reduces internal whitespace runs to a
  single space: `"John  Doe"` → `"John Doe"`.
- `replace(Pattern, String)` — general-purpose pattern replacement.
- `truncate(int maxLength)` — silently caps string length.

#### New `ListSanitizer` Rules

- `removeWhere(bool Function(T))` — removes items matching a predicate.
- `unique()` — now preserves insertion order (first occurrence kept).

#### `StringValidator.trimmedRequired`

Explicit alias for `required`. Both trim before checking; `trimmedRequired`
makes the behaviour self-documenting when the input has no `trim` sanitizer.

#### Documented `StringValidator.required` vs `notEmpty`

| Value   | `required` / `trimmedRequired` | `notEmpty` |
|---------|--------------------------------|------------|
| `""`    | ✗ error                        | ✗ error    |
| `"   "` | ✗ error (trimmed)              | ✓ valid    |
| `"a"`   | ✓ valid                        | ✓ valid    |

---

### ⚡️ Improvements

- **`FormSubmitter`** — `onInvalid` removed; validity is always the caller's
  concern. `FormSubmitter.delegated` also simplified.
- **`ListSanitizer.unique()`** — fixed to preserve insertion order using a
  `where(seen.add)` pattern instead of `toSet().toList()` which had
  undefined iteration order.
- **`FormMixin`** — brought to full parity with `FormSchema`: `touchAll()`,
  `reset()`, `invalidInputs`, `errors` all added.
- **`DateTimeInput`** — `isAfter` / `isBefore` simplified, `daysDifference`
  helper added.
- **`NumberInput`** — `increment` / `decrement` helpers preserve `T` correctly
  for both `int` and `double` subtypes.
- **`prepareUpdate`** — nullable limitation documented: passing `value: null`
  on a nullable-typed input is indistinguishable from omitting the argument.
  Use `reset()` to revert a nullable field to its initial value.

---

### 🗑️ Removed

- `Debouncer` — use `dart:async Timer` or an external package (`rxdart`,
  `easy_debounce`, `stream_transform`). `runAsync` is scheduling-agnostic.
- `GenericInput<T, E>` — use `SimpleObjectInput<T, E>` or a builder.
- `StandardInput<T, E>` — use `ObjectInput<T, E>` / `SimpleObjectInput<T, E>`.
- `SimpleListInput<T, E>` — renamed to `ListInput<T, E>`.
- Old `ListInput<T, E>` (abstract) — renamed to `BaseListInput<T, E>`.
- `FormSubmitter.submit(bool isValid)` — validity parameter removed.
- `FormSubmitter.onInvalid` — removed.
- `ValidatorBuilder`, `SanitizerBuilder`, `ValidatorChain`, `SanitizerChain`
  — replaced by the builder API.
- `ComparableValidator.oneOf` / `notOneOf` — use `ObjectValidator.oneOf` /
  `notOneOf`.