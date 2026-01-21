# Flux Form

A modular, type-safe, and declarative form state management library for Flutter. **FluxForm** 
removes the boilerplate associated with form validation by using **Composition over Inheritance** 
and smart UI state management.

![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 🚀 Key Features

- **Zero Boilerplate:** Use `StringField` or `StandardField` to create validated inputs without 
  creating a new class for every field.
- **Composition API:** Define `validators` and `sanitizers` via getters, keeping your logic clean 
  and reusable.
- **Smart UI Logic:** Built-in `ValidationMode` handles the complex "Show error only after submit"
  vs "Show error while typing" logic automatically.
- **Dynamic Lists:** First-class support for array inputs (e.g., Tags, Shopping Lists) via 
  `ListField` with O(1) read performance.
- **Sanitization:** Automatically `Trim`, `LowerCase`, or format inputs before they are validated 
  or stored.
- **Form Mixin:** A simple mixin for your BLoC/Cubit state that aggregates `isValid`, `isTouched`, 
  and `status`.
- **Type-Safe Errors:** Support for String errors, Enums (for localization), or custom Failure 
  objects.

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flux_form: ^0.1.0
```

---

## ⚡ Quick Start

### 1. Define your State
Create a class extending `StringField` to define your rules, then use it in your State.

```dart
// 1. Define the Field logic
class EmailField extends StringField {
  const EmailField.untouched({super.value}) : super.untouched();
  const EmailField.touched({super.value}) : super.touched();

  @override
  List<Validator<String, String>> get validators => [
    const RequiredValidator('Email is required'),
    const EmailValidator('Invalid email format'),
  ];
  
  // Optional: Clean data before validation
  @override
  List<Sanitizer<String>> get sanitizers => [const TrimSanitizer()];
}

// 2. Use in State
class LoginState extends Equatable with FormMixin {
  final EmailField email;
  final FormStatus status;

  const LoginState({
    this.email = const EmailField.untouched(),
    this.status = FormStatus.initial,
  });

  @override
  List<Field> get inputs => [email]; // Registers field for isValid checks
  
  // ... copyWith & props
}
```

### 2. Update Logic (Cubit)
Update the field using `copyWith`. The state remains immutable.

```dart
class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void emailChanged(String value) {
    // Calling copyWith automatically runs Sanitizers -> Validators
    emit(state.copyWith(
      email: state.email.copyWith(value: value, isTouched: true),
    ));
  }

  void submit() {
    if (state.isValid) {
      emit(state.copyWith(status: FormStatus.succeeded));
    } else {
      // Setting status to failed triggers errors to show on all fields
      emit(state.copyWith(status: FormStatus.failed));
    }
  }
}
```

### 3. Build UI
Use `displayError` to handle the UI state automatically based on the `ValidationMode`.

```dart
TextField(
  onChanged: context.read<LoginCubit>().emailChanged,
  decoration: InputDecoration(
    labelText: 'Email',
    // Shows error based on Interaction or Submit status
    errorText: state.email.displayError(state.status), 
  ),
)
```

---

## 📚 Core Concepts

### 1. The Field
The atomic unit of a form. `Field<T, E>` holds the value (`T`) and the error (`E`).
- **`StringField`**: Optimized for text inputs.
- **`ListField`**: Optimized for lists/arrays.
- **`StandardField`**: Generic field for custom types (e.g. Enums, Objects).

### 2. Validation Modes
Control *when* errors appear without complex `if/else` logic in your UI.

- **`ValidationMode.onInteraction`**: (Default) Shows errors as soon as the user modifies the field 
  (`isTouched`). Ideal for live validation.
- **`ValidationMode.onSubmit`**: Errors are hidden until `FormStatus` becomes `failed`. Ideal for 
  Login forms.
- **`ValidationMode.onUnfocus`**: Logically similar to `onInteraction`, used for fields that 
  validate when focus is lost.

### 3. Mixins
- **`FormMixin`**: logic for the entire form (`isValid`, `isTouched`).
- **`FieldCacheMixin`**: Apply this to fields with heavy validation logic (e.g., complex Regex or 
  large Lists). It ensures validation runs **once** per state change (O(1) reads).

---

## 🛠 Built-in Validators

FluxForm comes with a suite of common validators.

| Category        | Validator                  | Description                                           |
|:----------------|:---------------------------|:------------------------------------------------------|
| **Textual**     | `RequiredValidator`        | Checks if string is not empty (trims by default).     |
|                 | `NotEmptyValidator`        | Checks if string is strictly not empty (no trim).     |
|                 | `EmailValidator`           | Validates standard email format.                      |
|                 | `MinLengthValidator`       | Validates minimum character length.                   |
|                 | `MaxLengthValidator`       | Validates maximum character length.                   |
|                 | `RegexValidator`           | Validates against a custom RegExp.                    |
| **Numeric**     | `MinNumberValidator`       | Number must be `>=` value.                            |
|                 | `MaxNumberValidator`       | Number must be `<=` value.                            |
|                 | `NonNegativeValidator`     | Number must be `>= 0`.                                |
|                 | `IsNumericStringValidator` | Checks if a String can be parsed to num.              |
| **Comparables** | `GreaterThanValidator`     | Value > other.                                        |
|                 | `LessThanValidator`        | Value < other.                                        |
|                 | `MatchValidator`           | Value == other (e.g., Confirm Password).              |
| **Logic**       | `WhenValidator`            | Runs a child validator only `if (condition)`.         |
|                 | `AnyValidator`             | Valid (returns null) if *any* child validator passes. |

---

## 🧼 Built-in Sanitizers

Sanitizers transform data *before* it is validated or stored.

| Sanitizer              | Description                               |
|:-----------------------|:------------------------------------------|
| `TrimSanitizer`        | Removes leading/trailing whitespace.      |
| `ToLowerCaseSanitizer` | Converts string to lower case.            |
| `ToUpperCaseSanitizer` | Converts string to upper case.            |
| `RemoveSpaceSanitizer` | Removes *all* whitespace from the string. |

---

## 🔥 Advanced Usage

### Dynamic Arrays (`ListField`)
Validate the list structure (e.g., "Min 3 items") AND the items inside (e.g., "Item cannot be 
empty").

```dart
class GroceryList extends ListField<String, String> {
  // ... constructors ...

  @override
  List<Validator<List<String>, String>> get validators => [
    const ListMinLengthValidator(3, 'Buy at least 3 items'),
  ];

  @override
  List<Validator<String, String>> get itemValidators => [
    const RequiredValidator('Item cannot be empty'),
  ];
  
  // Necessary to maintain type when using addItem/removeItem
  @override
  GroceryList copyWith(...) => ...
}
```

### Typed Errors (Localization)
Use Enums instead of Strings for easier localization.

```dart
enum AuthError { empty, invalid }

class AuthField extends StandardField<String> { 
  @override
  List<Validator<String, FormError>> get validators => [
    const RequiredValidator(AuthError.empty),
  ];
}

// UI
state.email.displayError(state.status)?.translate(context);
```

### Conditional Logic
Run validators only if specific conditions are met.

```dart
// In your Cubit/State construction logic
StandardField.touched(
  value: companyName,
  validators: [
    WhenValidator(
      condition: isEmployed, // Boolean from state
      validator: const RequiredValidator('Company name is required'),
    ),
  ],
);
```