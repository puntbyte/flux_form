# Flux Form

**Flux Form** is a modular, type-safe, and declarative form state management library for Dart and 
Flutter. It eliminates the boilerplate of manual validation logic by using **Composition**, 
**Immutable State**, and **Smart UI Logic**.

Heavily inspired by the **`formz`** package, Flux Form builds upon the pattern of immutable inputs 
but significantly expands the ecosystem with built-in validators, sanitization pipelines, and 
intelligent form groups.

Designed to be **state-management agnostic**, it works seamlessly with: **Bloc, Riverpod, Provider, 
Signals, MobX, Vanilla `setState`**

![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)

---

## 🚀 Key Features

- **⚡️ "Batteries Included" Validators:** Comprehensive validation library including 
  `FormatValidator` (Email, URL, UUID, Credit Cards), `ComparableValidator` (Dates, Numbers), 
  `FileValidator`, `LogicValidator` (conditional logic), and standard text rules.

- **🏗 FormSchema Architecture:** Group inputs into strongly-typed schemas that handle aggregate 
  validity (`isValid`), serialization (`values`), and error aggregation automatically.

- **🧼 Sanitization Pipeline:** Namespace-based sanitizers (`StringSanitizer.trim()`, 
  `NumberSanitizer.clamp()`, `ListSanitizer.unique()`) transform data *before* validation.

- **🎯 FormSubmitter Utility:** Encapsulates submission lifecycles with `onStart`, `onSuccess`, 
  and `onError` hooks for clean async handling.

- **🧠 Smart Validation Modes:** Built-in support for `live` (while typing), `deferred` 
  (submit-only), and `blur` validation logic without complex UI code.

- **📋 Complex Collections:** First-class support for `ListInput` (arrays with item-level 
  validation) and `MapInput` (key-value collections) with O(1) error lookups.

- **☁️ Server Error Handling:** Intelligent remote error injection that automatically clears when 
  users modify fields to fix them.

- **🔌 Validation Hooks:** `ValidatorPipeline.validateWithHooks()` enables logging, analytics, or 
  debugging during the validation cycle.

> #### 💡 Inspiration & Acknowledgment
> This package owes a debt of gratitude to [**formz**](https://pub.dev/packages/formz).
> Flux Form was created to solve specific points encountered while using `formz` in 
> large-scale production apps—specifically the need for reduced boilerplate, dynamic collections, 
> and a standard library of validators and sanitizers. If you like `formz`, you will feel right at 
> home here.

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flux_form: ^0.4.1
```

> #### ⚠️ Note on Stability: 
> This package is in its early lifecycle (0.x.x). It might/will contain breaking changes to the 
> public API. Please pin your dependency version if you require absolute stability.

---

## 🏃 Quick Start: The Setup

Flux Form is designed to be flexible. You can start simple or architect for scale from day one.

### 1. Type-Safe Errors
Flux Form is fully generic (`FormInput<Value, Error>`). This means you can use **any** data type to
represent validation errors. Choose the approach that fits your app's complexity.

#### 1.1 Option A: Simple Strings (Prototyping)
The fastest way to get started. You pass the error message directly to the validator.

- **Best for:** MVP apps, internal tools, or apps with only one language.

```dart
// Define input with <String, String>
class NameInput extends StringInput<String> ... {
  @override
  List<Validator<String, String>> get validators => [
    StringValidator.required('Name is required'),
    StringValidator.minLength(3, 'Name is too short'),
  ];
}
```

#### 1.2 Option B: Custom Enum (Strict Typing)

You can use a plain Dart `enum` to strictly define every possible error state. This decouples logic
from text, allowing the UI to decide how to format messages.

- **Best for:** Apps requiring strict type safety but handling localization purely in the UI layer.

```dart
// 1. Define plain enum
enum MyError { empty, tooShort, invalid }

// 2. Define input with <String, MyError>
class NameInput extends StringInput<MyError> ... {
  @override
  List<Validator<String, MyError>> get validators => [
    StringValidator.required(MyError.empty),
    StringValidator.minLength(3, MyError.tooShort),
  ];
}

// 3. Handle translation in UI
Text(
  switch (form.name.displayError(state.status)) {
    MyError.empty => 'Please enter a name',
    MyError.tooShort => 'Too short',
    null => '',
  }
)
```

#### 1.3 Option C: Implementing `FormError` (Recommended)

For the best experience, implementation the `FormError` interface on your enum. This provides a 
standardized contract for accessing error codes (for analytics/API mapping) and localized messages.

- **Best for:** Production apps, Multi-language support, and clean UI code.

```dart
// 1. Implement FormError
enum AuthError implements FormError {
  required('required'),
  invalidEmail('invalid_email'),
  tooShort('too_short'),
  unknown('unknown');

  // The code used for API error matching or analytics
  @override
  final String code;

  const AuthError(this.code);

  // Helper to map API strings to this Enum
  static AuthError fromCode(String? code) {
    if (code == null) return unknown;
    return values.firstWhere(
      (e) => e.code == code, 
      orElse: () => unknown,
    );
  }

  // Easy localization integration
  @override
  String message(BuildContext context) => switch (this) {
    AuthError.required => AppLocalizations.of(context).reqField,
    AuthError.invalidEmail => AppLocalizations.of(context).badEmail,
    AuthError.tooShort => AppLocalizations.of(context).shortPass,
    AuthError.unknown => 'Unknown Error',
  };
}

// 2. Usage in UI is much cleaner
Text(
  // displayError returns AuthError?, so we can call .message() directly
  form.email.displayError(state.status)?.message(context) ?? ''
)
```

---

### 2. Define Inputs

Inputs are the atomic units of your form. Every field in Flux Form extends `FormInput<T, E>`, where:
- **`T` (Type):** The data type of the input's value (e.g., `String`, `bool`, `List<String>`).
- **`E` (Error):** The data type used to represent validation failures (e.g., `String`, 
  `AuthError`).

#### 2.1 Input State & Lifecycle (Enums)

An input's behavior is driven by two core enums that manage its lifecycle and UI visibility.

**`InputStatus` (The Interaction State)**
- **`untouched` (Pristine):** The initial state. The user has not interacted with this field yet. 
  Even if the value is invalid (e.g., empty required field), errors are usually hidden in the UI to 
  avoid "shouting" at the user immediately.
- **`touched` (Dirty):** The user has interacted with the field (focused, typed, or blurred). In 
  this state, validation errors are revealed.
- **`validating` (Async):** An asynchronous check (like a server API call) is in progress.

**`ValidationMode` (The Display Rules)**
Controls *when* an error is revealed via the `displayError()` method.
- **`live`:** Errors appear immediately as the user types, provided the field is `touched`.
- **`deferred`:** Errors are hidden until the global `FormStatus` becomes `failed` (e.g., the user 
  clicks "Submit").
- **`blur`:** Logically identical to `live`, but indicates intent to trigger validation on focus 
  loss.

#### 2.2 Core Properties and Methods

Inputs are immutable. You access state via properties and mutate state via methods (provided by the
`InputMixin`).

**Key Properties (Getters)**

| Getter                      | Description                                                                                 |
|:----------------------------|:--------------------------------------------------------------------------------------------|
| `value`                     | The current value of type `T`.                                                              |
| `isValid`                   | Returns `true` if there are no local or remote errors.                                      |
| `isNotValid`                | Convenience getter for `!isValid`.                                                          |
| `isTouched` / `isUntouched` | Checks the current `InputStatus`.                                                           |
| `error`                     | Returns the active error (`E?`). Remote errors take precedence over local errors.           |
| `detailedErrors`            | Returns a `List<E>` of *all* failing validation rules (great for Password Strength meters). |

**Key Methods (Mutators from `InputMixin`)**

| Method              | Description                                                                                   |
|:--------------------|:----------------------------------------------------------------------------------------------|
| `replaceValue(T)`   | Updates the value, runs validation, and marks the input as `touched`.                         |
| `reset()`           | Reverts the input to its `initialValue` and marks it `untouched`.                             |
| `markTouched()`     | Sets status to `touched` without changing the value.                                          |
| `setRemoteError(E)` | Injects an external error (e.g., "Email taken" from an API). Auto-clears when the user types. |
| `markValidating()`  | Sets status to `validating` before an async operation.                                        |

#### 2.3 Option A: Use Built-in "Simple" Inputs (Composition)

For inputs that don't require reusable logic (like a single-use Search bar or a Toggle), use the 
concrete `Simple` classes. These accept validators directly in the constructor.

**Available Types:** `SimpleStringInput`, `SimpleNumberInput`, `SimpleBoolInput`, 
`SimpleDateTimeInput`, `SimpleListInput`, `SimpleMapInput`, and `GenericInput<T, E>`.

```dart
// Example: One-off Search Field
final search = SimpleStringInput.untouched(
  value: '',
  validators: [StringValidator.required('Search term required')],
);

// Example: One-off Terms Toggle
final acceptTerms = SimpleBoolInput.untouched(
  value: false,
  validators: [BoolValidator.isTrue('You must accept terms')],
);
```

#### 2.4 Option B: Create Custom Inputs (Inheritance - Recommended)
For domain-specific logic (Email, Password, Username), extend the **Abstract Base Classes** 
(`StringInput`, `NumberInput`, etc.). This keeps your rules encapsulated and reusable across 
screens.

```dart
class EmailInput extends StringInput<AuthError> 
    with InputMixin<String, AuthError, EmailInput> {
  
  // 1. Initial State Constructors
  const EmailInput.untouched({super.value = ''}) : super.untouched();
  const EmailInput.touched({super.value = '', super.remoteError}) : super.touched();

  // 2. Define Sanitizers and Validators internally
  @override
  List<Sanitizer<String>> get sanitizers => [StringSanitizer.toLowerCase()];

  @override
  List<Validator<String, AuthError>> get validators => [
    StringValidator.required(AuthError.required),
    FormatValidator.email(AuthError.invalidEmail),
  ];
  
  // ... update implementation (see section 2.8) ...
}
```

#### 2.5 Sanitizers: Clean Data First
Sanitizers transform input data **before** it reaches the validators or the state.

**Built-in Sanitizers (Namespaced):**
- `StringSanitizer`: `.trim()`, `.toLowerCase()`, `.digitsOnly()`, `.removeSpaces()`, 
  `.capitalize()`.
- `NumberSanitizer`: `.round()`, `.ceil()`, `.clamp(min, max)`.
- `ListSanitizer`: `.unique()`, `.sort()`.

**Custom Sanitizer Example:**
```dart
/// Removes currency symbols (e.g., "$1,200.00" -> "1200.00")
class CurrencySanitizer implements Sanitizer<String> {
  const CurrencySanitizer();

  @override
  String sanitize(String value) => value.replaceAll(RegExp(r'[$,]'), ''); 
}
```

#### 2.6 Validators: Rule Definition
Validators are pure functions that take a value and return `E?` (null means valid).

**Built-in Validators (Namespaced):**
- `StringValidator`: `.required()`, `.minLength()`, `.pattern()`.
- `FormatValidator`: `.email()`, `.url()`, `.creditCard()`, `.hexColor()`.
- `NumberValidator`: `.min()`, `.max()`, `.positive()`.
- `LogicValidator`: Reactive flow control (`.when()`, `.any()`).

**Reactive Logic Example (`LogicValidator`):**
Validators can evaluate external conditions lazily at runtime.
```dart
validators: [
  LogicValidator.when(
    // Evaluates every time the user types
    condition: () => schema.isCompany.value, 
    validator: StringValidator.required(AuthError.taxIdRequired),
  ),
]
```

**Custom Validator Example:**
```dart
class ProfanityValidator<E> extends Validator<String, E> {
  const ProfanityValidator(super.error);

  @override
  E? validate(String value) {
    return value.contains('badword') ? error : null;
  }
}
```

#### 2.7 Why `InputMixin`?
You will notice the `with InputMixin<T, E, I>` syntax. This is required for two reasons:
1. **Fluent API:** It injects the mutator methods (`replaceValue`, `reset`).
2. **Type Safety:** It forces these methods to return your specific class (`EmailInput`) rather 
   than a generic `FormInput`, allowing you to chain methods safely.

#### 2.8 The `update` Pattern

Since Flux Form inputs are **immutable**, changing a value requires creating a new instance. The 
`update` method handles this cloning process.

**Option 1: The Private Constructor (Recommended)**

This is the cleanest and safest approach. You define a private constructor `._()` that accepts the 
calculated `InputData` object directly.

```dart
class EmailInput extends StringInput<String> with InputMixin<String, String, EmailInput> {
  // ... public constructors ...

  // Private constructor
  EmailInput._(super.data) : super.fromData();

  @override
  EmailInput update({
    String? value, 
    InputStatus? status, 
    ValidationMode? mode, 
    String? remoteError
  }) {
    // prepareUpdate calculates the new state (running sanitizers/validators)
    return EmailInput._(prepareUpdate(
      value: value, 
      status: status, 
      mode: mode, 
      remoteError: remoteError,
    ));
  }
}
```

**Option 2: Manual Factory (Verbose)**

If you prefer not to use a private constructor, you must manually unpack the data and switch on the 
status.

```dart
class EmailInput extends ... {
  // ...public constructors only ...
  
  @override
  EmailInput update({
    String? value, 
    InputStatus? status, 
    ValidationMode? mode, 
    String? remoteError
  }) {
    final data = prepareUpdate(
      value: value, 
      status: status, 
      mode: mode, 
      remoteError: remoteError
    );
    
    return switch (data.status) {
      InputStatus.untouched => EmailInput.untouched(value: data.value),
      InputStatus.touched => EmailInput.touched(value: data.value, remoteError: data.remoteError),
      InputStatus.validating => throw UnimplementedError('Needs private constructor'),
    };
  }
}
```
---

### 3. Define the Schema (Optional)

The `FormSchema` serves as the central contract for your form. It aggregates multiple inputs into a 
single, cohesive unit. While **optional**, it is highly recommended for any form with more than one
field.

- **When to skip:** Single-input UIs (e.g., a standalone Search Bar or Toggle).
- **When to use:** Login screens, Registration wizards, Profile editors, or any form requiring API 
  submission.

#### 3.1 Implementation

To create a schema, extend `FormSchema` and implement the `namedInputs` getter. This getter acts as 
the bridge between your inputs and the automatic serialization logic.

```dart
class LoginSchema extends FormSchema {
  final EmailInput email;
  final PasswordInput password;

  const LoginForm({
    this.email = const EmailInput.untouched(),
    this.password = const PasswordInput.untouched(),
  });

  // 🔑 Key Configuration
  // The keys defined here ('email', 'password') will be used 
  // as the keys in the generated JSON/Map output.
  @override
  Map<String, FormInput> get namedInputs => {
    'email': email,
    'password': password,
  };

  // Boilerplate: standard copyWith to update state
  LoginForm copyWith({EmailInput? email, PasswordInput? password}) {
    return LoginForm(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
```

#### 3.2 Key Capabilities (API Reference)

By extending `FormSchema`, your form automatically gains the following properties without writing 
any extra logic:

| Property          | Type                   | Description                                                                                                                                                                 |
|:------------------|:-----------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **`namedInputs`** | `Map<String, Input>`   | **(Abstract)** You must override this. It maps serialization keys to their respective input instances.                                                                      |
| **`inputs`**      | `List<Input>`          | A flattened list of all inputs in the schema. Useful for iterating over fields to check status.                                                                             |
| **`values`**      | `Map<String, dynamic>` | **Serialization.** Automatically generates a Key-Value map of your form data using the keys from `namedInputs`. <br>Example: `{'email': 'user@co.com', 'password': '123'}`. |
| **`isValid`**     | `bool`                 | Returns `true` if **every** input in the schema is valid.                                                                                                                   |
| **`isNotValid`**  | `bool`                 | Convenience getter for `!isValid`.                                                                                                                                          |
| **`isTouched`**   | `bool`                 | Returns `true` if **at least one** input has been interacted with by the user.                                                                                              |
| **`isUntouched`** | `bool`                 | Returns `true` if **no** inputs have been touched yet.                                                                                                                      |
| **`firstError`**  | `dynamic`              | Returns the error of the first invalid input found. Useful for showing a general "Snackbar" error if the form is long.                                                      |

---

## 4. State Management Integrations 🔌

Flux Form is architecture-agnostic. It provides the **data structure**, while your state management
library handles the **data flow**.

Before diving into code, there are two key helpers you should know to manage submission logic.

### 4.1 Core Concepts

#### 1. `FormStatus` (Enum)

Tracks the lifecycle of a form submission. You usually store this alongside your form in your state.

- `initial`: Form hasn't been submitted yet.
- `submitting`: Async action in progress (show spinner).
- `succeeded`: Action completed successfully.
- `failed`: Action failed (show validation errors).
- `canceled`: User canceled the action.

#### 2. `FormSubmitter` (Utility)

A helper class to standardize the submission flow (try/catch, status updates).

```dart
final submitter = FormSubmitter<void>(
  onStart: () => emit(state.copyWith(status: FormStatus.submitting)),
  onSubmit: () => repository.login(state.form.values),
  onSuccess: (_) => emit(state.copyWith(status: FormStatus.succeeded)),
  onError: (e, s) => emit(state.copyWith(status: FormStatus.failed)),
);
await submitter.submit();
```

---

### 4.2 Implementation Strategies

You can implement Flux Form in two ways depending on complexity:

1. **Using `FormSchema` (Recommended):** Best for scaling. Validation, "Touched" status, and 
   Serialization are handled automatically.
2. **Using Individual Inputs:** Good for very simple forms where you don't need group-level logic.

Below are examples for the most popular state management libraries.

### 4.2.1 🧊 Cubit (Bloc Library)

#### Option A: Using FormSchema

The State holds the `LoginForm`. Validation checks are clean (`state.isValid`).

```dart
class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void emailChanged(String value) {
    // Update Input -> Update Schema -> Emit
    emit(state.copyWith(
      form: state.form.copyWith(email: state.form.email.replaceValue(value))
    ));
  }

  Future<void> submit() async {
    // 1. Check Validity
    if (state.form.isNotValid) {
      // Mark all inputs as touched to reveal errors
      emit(state.copyWith(status: FormStatus.failed)); 
      return;
    }

    // 2. Use FormSubmitter for clean async logic
    final submitter = FormSubmitter(
      onStart: () => emit(state.copyWith(status: FormStatus.submitting)),
      onSubmit: () => api.login(state.form.values), // Automatic serialization
      onSuccess: (_) => emit(state.copyWith(status: FormStatus.succeeded)),
      onError: (e, s) => emit(state.copyWith(status: FormStatus.failed)),
    );

    await submitter.submit();
  }
}
```

#### Option B: Individual Inputs

The State holds inputs manually. You must manually aggregate validity.

```dart
class LoginState {
  final EmailInput email;
  final PasswordInput password;

  const LoginState({
    this.email = const EmailInput.untouched(), 
    this.password = const PasswordInput.untouched()
  });

  // Manual validity aggregation required
  bool get isValid => email.isValid && password.isValid;
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void emailChanged(String value) {
    emit(state.copyWith(
      email: state.email.replaceValue(value)
    ));
  }
}
```

### 4.2.2 🧱 Bloc (Event-Driven)

#### Option A: Using FormSchema

```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<EmailChanged>((event, emit) {
      emit(state.copyWith(
        form: state.form.copyWith(email: state.form.email.replaceValue(event.val))
      ));
    });

    on<SubmitForm>((event, emit) async {
      if (state.form.isNotValid) {
        emit(state.copyWith(status: FormStatus.failed));
        return;
      }
      
      emit(state.copyWith(status: FormStatus.submitting));
      try {
        await api.login(state.form.values);
        emit(state.copyWith(status: FormStatus.succeeded));
      } catch (_) {
        emit(state.copyWith(status: FormStatus.failed));
      }
    });
  }
}
```

#### Option B: Individual Inputs

```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<EmailChanged>((event, emit) {
      emit(state.copyWith(
        email: state.email.replaceValue(event.val)
      ));
    });

    on<SubmitForm>((event, emit) {
      // Manual Check
      if (state.email.isNotValid || state.password.isNotValid) return;
      
      api.login({
        'email': state.email.value,
        'password': state.password.value,
      });
    });
  }
}
```

### 4.2.3 💧 Riverpod

#### Option A: Using FormSchema

The `Notifier` manages the Schema directly.

```dart
class LoginNotifier extends Notifier<LoginForm> {
  @override
  LoginForm build() => const LoginForm();

  void onEmailChanged(String val) {
    state = state.copyWith(email: state.email.replaceValue(val));
  }

  void submit() {
    if (state.isValid) {
      api.login(state.values);
    }
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginForm>(LoginNotifier.new);
```

#### Option B: Individual Inputs

The State is a plain class holding the inputs.

```dart
class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void onEmailChanged(String val) {
    state = state.copyWith(email: state.email.replaceValue(val));
  }

  void submit() {
    if (state.email.isValid && state.password.isValid) {
      api.login(state.email.value, state.password.value);
    }
  }
}
```

### 4.2.4 🐹 MobX

#### Option A: Using FormSchema

Treat the `FormSchema` as an observable. Since FluxForm inputs are immutable, you replace the form
instance on updates.

```dart
class LoginStore = _LoginStore with _$LoginStore;

abstract class _LoginStore with Store {
  @observable
  LoginForm form = const LoginForm();

  @action
  void setEmail(String value) {
    form = form.copyWith(email: form.email.replaceValue(value));
  }

  @action
  Future<void> submit() async {
    if (form.isValid) {
      await api.login(form.values);
    }
  }
}
```

#### Option B: Individual Inputs

Each input is an observable.

```dart
abstract class _LoginStore with Store {
  @observable
  EmailInput email = const EmailInput.untouched();

  @observable
  PasswordInput password = const PasswordInput.untouched();

  @computed
  bool get isValid => email.isValid && password.isValid;

  @action
  void setEmail(String value) {
    email = email.replaceValue(value);
  }
}
```

### 4.2.5 📡 Signals

#### Option A: Using FormSchema

```dart
final loginForm = signal(const LoginForm());

void onEmailChanged(String val) {
  // Update the signal with a new form instance
  loginForm.value = loginForm.value.copyWith(
    email: loginForm.value.email.replaceValue(val),
  );
}

void submit() {
  if (loginForm.value.isValid) {
    api.login(loginForm.value.values);
  }
}
```

#### Option B: Individual Inputs

```dart
final email = signal(const EmailInput.untouched());
final password = signal(const PasswordInput.untouched());

// Computed signal for validity
final isValid = computed(() => email.value.isValid && password.value.isValid);

void onEmailChanged(String val) {
  email.value = email.value.replaceValue(val);
}
```

### 4.2.6 📱 Provider (`ChangeNotifier`)

#### Option A: Using FormSchema

```dart
class LoginProvider extends ChangeNotifier {
  LoginForm _form = const LoginForm();
  LoginForm get form => _form;

  void emailChanged(String val) {
    _form = _form.copyWith(email: _form.email.replaceValue(val));
    notifyListeners();
  }
}
```

#### Option B: Individual Inputs

```dart
class LoginProvider extends ChangeNotifier {
  EmailInput _email = const EmailInput.untouched();
  EmailInput get email => _email;

  void emailChanged(String val) {
    _email = _email.replaceValue(val);
    notifyListeners();
  }

  bool get isValid => _email.isValid; // Add other fields manually
}
```

### 4.2.7 🍦 Vanilla (`setState`)

#### Option A: Using FormSchema

```dart
class _LoginScreenState extends State<LoginScreen> {
  LoginForm form = const LoginForm();

  void _onEmailChanged(String val) {
    setState(() {
      form = form.copyWith(email: form.email.replaceValue(val));
    });
  }
}
```

#### Option B: Individual Inputs

```dart
class _LoginScreenState extends State<LoginScreen> {
  EmailInput email = const EmailInput.untouched();

  void _onEmailChanged(String val) {
    setState(() {
      email = email.replaceValue(val);
    });
  }
}
```

---

## 5. User Interface (UI) Integration 🎨

Flux Form is designed to be **UI-Agnostic**. Your logic lives in your State Management layer 
(Cubit, Provider, etc.), and your UI simply "renders" that state.

This separation of concerns means you stop writing `validator: (val) { ... }` inside your widgets 
and start using a declarative approach via `displayError`.

### 5.1 The Core Mechanism: `displayError`

The bridge between your logic and the UI is the `displayError(FormStatus)` method. You call this on 
any input to get the error message (or `null`).

It intelligently decides **whether or not** to reveal the error based on the input's **Validation 
Mode**:

| Mode                          | Behavior                                                                                   | Best Use Case                           |
|:------------------------------|:-------------------------------------------------------------------------------------------|:----------------------------------------|
| **`ValidationMode.live`**     | Errors appear immediately while typing, but *only* if the field is **touched** (dirty).    | Passwords, Search Bars.                 |
| **`ValidationMode.deferred`** | Errors are hidden until the global `FormStatus` is **failed** (i.e., user pressed Submit). | Emails, Login Forms (less annoying).    |
| **`ValidationMode.blur`**     | Validates when the field loses focus.                                                      | Usernames (API checks), complex inputs. |

```dart
// ❌ The Old Way (Logic in UI)
validator: (value) => value.isEmpty ? 'Required' : null;

// ✅ The Flux Form Way (Logic in State)
// Automatically respects the modes defined above
errorText: form.email.displayError(state.status),
```

### 5.2 Text Inputs (`StringInput`, `NumberInput`)

Use standard `TextField` or `TextFormField` widgets. Since validation is calculated in your state, 
you do **not** use the `validator` property.

```dart
TextField(
  // 1. Bind actions
  onChanged: (val) => context.read<LoginCubit>().emailChanged(val),
  
  // 2. Bind styling & errors
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'user@example.com',
    
    // 3. Display error (returns String? or null)
    // If using Enum Errors: .displayError(...)?.message(context)
    errorText: state.form.email.displayError(state.status),
    
    // 4. Optional: Visual cues for valid states
    suffixIcon: state.form.email.isValid 
        ? const Icon(Icons.check, color: Colors.green) 
        : null,
  ),
)
```

> **💡 Pro Tip: Text Controllers**
> When using state management, you generally **do not** need a `TextEditingController` unless you 
> need to manipulate the cursor or clear the text programmatically. The `onChanged` callback is 
> sufficient to keep your state in sync.

### 5.3 Toggles & Checkboxes (`BoolInput`)

Boolean inputs often don't have a built-in `errorText` property in Flutter. You can wrap them or 
conditionally display the error text below.

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    CheckboxListTile(
      title: const Text('I accept the Terms of Service'),
      value: state.form.acceptTerms.value,
      onChanged: (val) => cubit.termsChanged(val ?? false),
    ),
    
    // Manually render the error if it exists
    if (state.form.acceptTerms.displayError(state.status) != null)
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text(
          state.form.acceptTerms.displayError(state.status)!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
  ],
)
```

### 5.4 Custom & Generic Inputs (Dropdowns)

For inputs like `GenericInput` or `StandardInput` used with Dropdowns, the pattern remains 
identical.

```dart
DropdownButtonFormField<UserRole>(
  value: state.form.role.value,
  items: UserRole.values.map((role) => DropdownMenuItem(
    value: role, 
    child: Text(role.name),
  )).toList(),
  
  onChanged: (val) => cubit.roleChanged(val),
  
  // Works exactly the same!
  decoration: InputDecoration(
    labelText: 'Role',
    errorText: state.form.role.displayError(state.status),
  ),
)
```

### 5.5 Submission Buttons

You can control your submit button state based on the form's validity or submission status.

```dart
FloatingActionButton(
  // Option A: Disable button if invalid
  // Option B: Keep enabled, and let 'displayError' reveal errors on click (Recommended)
  onPressed: state.status.isSubmitting 
      ? null 
      : () => cubit.submit(),
      
  child: state.status.isSubmitting
      ? const CircularProgressIndicator(color: Colors.white)
      : const Icon(Icons.arrow_forward),
)
```

### 5.6 Integration with Flutter's `Form` Widget

**Do I need the `Form` widget?**
Strictly speaking, **no**. Flux Form handles validation independently.

However, you *may* still wrap your fields in a `Form` widget to utilize **Focus Management** (e.g.,
the "Next" button on the keyboard moving focus automatically).

```dart
// ✅ Correct Usage
Form(
  // No GlobalKey needed!
  child: Column(
    children: [
      TextField(
        textInputAction: TextInputAction.next, // Works automatically inside Form
        ...
      ),
      TextField(...),
    ],
  ),
)
```

**⚠️ Anti-Pattern:**
Do **not** use `_formKey.currentState.validate()`.
- **Why?** That triggers Flutter's internal mutable state validation.
- **Instead:** Check `state.form.isValid` in your business logic.

### 5.7 Stateless vs Stateful
Because Flux Form moves state out of the widget tree:

1. **Prefer `StatelessWidget`:** Your form screen should ideally be stateless, rebuilding only 
   when your State Manager (Bloc/Riverpod/etc.) emits a new state.
2. **Use `StatefulWidget` only if:**
   - You are managing the form using vanilla `setState`.
   - You need to manage `FocusNode`s or `ScrollController`s for complex UI interactions (e.g., 
     "Scroll to first error").

#### Summary Table

| Feature               | Standard Flutter Form             | Flux Form                            |
|:----------------------|:----------------------------------|:-------------------------------------|
| **Widget Type**       | `StatefulWidget` (usually)        | `StatelessWidget` (preferred)        |
| **Validation Source** | `validator: (val) => ...`         | `field.validators` list              |
| **Error Display**     | Triggered by `formKey.validate()` | `errorText: field.displayError(...)` |
| **Form State**        | `GlobalKey<FormState>`            | `FormSchema` class                   |
| **Controllers**       | Required for text access          | Optional (Value is in State)         |

---

## ❤️ Contributing

Issues and Pull Requests are welcome! Flux Form aims to be the standard for clean, maintainable 
forms in Dart.
