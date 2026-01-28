# Flux Form

**Flux Form** is a modular, type-safe, and declarative form state management library for Dart and 
Flutter. It eliminates the boilerplate of manual validation logic by using **Composition**, 
**Immutable State**, and **Smart UI Logic**.

Heavily inspired by the **`formz`** package, Flux Form builds upon the pattern of immutable inputs 
but significantly expands the ecosystem with built-in validators, sanitization pipelines, and 
intelligent form groups.

Designed to be **state-management agnostic**, it works seamlessly with:
<br>**Bloc • Riverpod • Provider • Signals • MobX • Vanilla `setState`**

![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)

---

## 🚀 Key Features

- **⚡️ "Batteries Included" Validators:** A rich library of pre-built rules (`Required`, `Email`, 
  `MinLength`, `Match`, `When`, `Any`, etc.) so you don't have to write Regex manually.

- **🏗 FormSchema Architecture:** Group inputs together to handle overall validity (`isValid`), 
  "Touched" status, and serialization (`values`) automatically.

- **🧼 Sanitization Pipeline:** Automatically `Trim`, `LowerCase`, `RemoveSpaces`, or format inputs
  *before* they reach validation or state.

- **🧠 Smart Validation Modes:** Built-in support for `Live` (while typing), `Deferred` (show only 
  after submit), and `Blur` validation logic without complex UI code.

- **📋 Dynamic Lists:** First-class support for array inputs (e.g., Tags, Shopping Lists) with 
  **O(1)** read performance and independent item-level validation.

- **☁️ Server Error Handling:** Intelligent logic to inject API errors (e.g., "Email taken") that 
  automatically clear as soon as the user modifies the field to fix it.

> #### 💡 Inspiration & Acknowledgment
> This package owes a debt of gratitude to [**formz**](https://pub.dev/packages/formz).
> Flux Form was created to solve specific pain points encountered while using `formz` in 
> large-scale production apps—specifically the need for reduced boilerplate, dynamic collections, 
> and a standard library of validators. If you like `formz`, you will feel right at home here.

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flux_form: ^0.2.0
```

---

## 🏃 Quick Start: The Setup

Flux Form is designed to be flexible. You can start simple or architect for scale from day one.

### 1. Type-Safe Errors (Recommended)
While you *can* use simple `String` errors, we strongly recommend creating a specific Enum that 
implements `FormError`. This provides type safety, API error mapping, and easy localization.

```dart
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
```

### 2. Define Inputs
Inputs are the atomic units of your form. You have two implementation choices:

1.  **Primitive Bases (Recommended):** Extend `StringInput`, `BoolInput`, `ListInput`, etc. These come with pre-configured generic types and helpers.
2.  **Generic FormInput:** Extend `FormInput<T, E>` directly for complex custom objects.

You must also mix in `InputMixin`.

#### Why `InputMixin`?
The mixin provides the fluent API (e.g., `email.replaceValue('new')`) and ensures strict type safety. It forces the return type of update operations to be `EmailInput` rather than a generic `FormInput`.

#### The `update` Pattern
To handle immutability, the input needs a way to clone itself. The cleanest approach is using a **Private Constructor**.

```dart
// inputs/email_input.dart

// 1. Extend StringInput<E> instead of FormInput<String, E> to save boilerplate
class EmailInput extends StringInput<AuthError> 
    with InputMixin<String, AuthError, EmailInput> {
  
  // Public constructors for initial state
  const EmailInput.untouched({super.value = ''}) : super.untouched();
  const EmailInput.touched({super.value = '', super.remoteError}) : super.touched();

  // 2. Private constructor used by the 'update' method
  EmailInput._(super.data) : super.fromData();

  @override
  List<Validator<String, AuthError>> get validators => [
    const RequiredValidator(AuthError.required),
    const EmailValidator(AuthError.invalidEmail),
  ];
  
  // 3. The Update Implementation
  // This bridges the internal logic (prepareUpdate) with your concrete class.
  @override
  EmailInput update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    AuthError? remoteError,
  }) {
    // Usage of the private constructor keeps this clean
    return EmailInput._(prepareUpdate(
      value: value, 
      status: status, 
      mode: mode, 
      remoteError: remoteError,
    ));
  }
}
```

> **Note on `update`**: If you prefer not to use a private constructor, you can implement `update` using a switch/if statement to return `EmailInput.touched(...)` or `EmailInput.untouched(...)` manually, but passing `InputData` to a private constructor is significantly less error-prone.

### 3. Define the Schema (Optional)
Grouping inputs into a `FormSchema` is **optional**.

*   **When to skip:** If you have a single search bar or a simple toggle.
*   **When to use:** For Login forms, Profiles, or Wizards.

Using a group provides:
1.  **Aggregated Validity:** `form.isValid` checks all inputs at once.
2.  **Serialization:** `form.values` automatically generates `{'email': '...', 'pass': '...'}`.
3.  **Clean State:** Your Bloc/Provider state only needs to hold one variable (`LoginForm`) instead of many.

```dart
class LoginForm extends FormSchema {
  final EmailInput email;
  final PasswordInput password;

  const LoginForm({
    this.email = const EmailInput.untouched(),
    this.password = const PasswordInput.untouched(),
  });

  // Defining this map enables the automatic serialization and validation logic
  @override
  Map<String, FormInput> get namedInputs => {
    'email': email,
    'password': password,
  };

  LoginForm copyWith({EmailInput? email, PasswordInput? password}) {
    return LoginForm(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
```

---

## 🔌 State Management Integrations

Flux Form is architecture-agnostic. It provides the **data structure**, while your state management library handles the **data flow**.

Below are examples showing two approaches:
1.  **Using `FormSchema` (Recommended):** Best for scaling. Validation and serialization are handled automatically.
2.  **Using Individual Inputs:** Good for simple forms or when you don't need group-level logic.

### 1. 🧊 Cubit (Bloc Library)

#### Option A: Using FormSchema
The State holds the `LoginForm`. Validation checks are cleaner (`state.isValid`).

```dart
class LoginCubit extends Cubit<LoginForm> {
  LoginCubit() : super(const LoginForm());

  void emailChanged(String value) {
    // Update the specific input, then update the form
    emit(state.copyWith(
      email: state.email.replaceValue(value)
    ));
  }

  void submit() {
    if (state.isValid) {
      api.login(state.values); // Automatic serialization
    } else {
      // Mark all as touched to show errors
      emit(state.copyWith(
        email: state.email.markTouched(),
        password: state.password.markTouched(),
      ));
    }
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

  // Manual validity aggregation
  bool get isValid => email.isValid && password.isValid;

  LoginState copyWith(...) => ...;
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

---

### 2. 🧱 Bloc (Event-Driven)

#### Option A: Using FormSchema

```dart
class LoginBloc extends Bloc<LoginEvent, LoginForm> {
  LoginBloc() : super(const LoginForm()) {
    on<EmailChanged>((event, emit) {
      emit(state.copyWith(email: state.email.replaceValue(event.val)));
    });

    on<SubmitForm>((event, emit) {
      if (state.isNotValid) return; 
      api.login(state.values);
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
      // Manual check
      if (state.email.isNotValid || state.password.isNotValid) return;
      
      api.login({
        'email': state.email.value,
        'password': state.password.value,
      });
    });
  }
}
```

---

### 3. 💧 Riverpod

#### Option A: Using FormSchema
The `Notifier` manages the `LoginForm` directly.

```dart
class LoginNotifier extends Notifier<LoginForm> {
  @override
  LoginForm build() => const LoginForm();

  void onEmailChanged(String val) {
    state = state.copyWith(email: state.email.replaceValue(val));
  }

  void submit() {
    if (state.isValid) api.login(state.values);
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

---

### 4. 🐹 MobX

#### Option A: Using FormSchema
You treat the `FormSchema` as an observable. Since FluxForm inputs are immutable, you replace the form instance on updates.

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

---

### 5. 📡 Signals

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

---

### 6. 🏗 Provider (ChangeNotifier)

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

---

### 7. 🍦 Vanilla (setState)

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

## 🎨 User Interface (UI) Integration

Flux Form is designed to be **UI-Agnostic**. Your logic lives in your State Management layer (Cubit, Provider, etc.), and your UI simply "renders" that state.

This separation of concerns means you stop writing `validator: (val) { ... }` inside your widgets and start using a declarative approach.

### 1. The Magic of `displayError`

The core bridge between your logic and the UI is the `displayError(FormStatus)` method available on every input.

It intelligently decides **whether or not** to show an error based on:
1.  **Validation Mode:** Is the field set to `Live`, `Deferred` (submit only), or `Blur`?
2.  **Interaction Status:** Has the user touched the field?
3.  **Form Status:** Has the user attempted to submit?

```dart
// ❌ The Old Way (Logic in UI)
validator: (value) {
  if (value == null || value.isEmpty) return 'Required';
  return null;
}

// ✅ The Flux Form Way (Logic in State)
// Automatically respects "Show only on submit" or "Show while typing" settings
errorText: form.email.displayError(state.status),
```

---

### 2. Text Inputs (`StringInput`, `NumberInput`)

You can use `TextField` or `TextFormField`. Since validation is handled externally, you do **not** use the `validator` property.

```dart
TextField(
  // 1. Bind actions
  onChanged: (val) => context.read<LoginCubit>().emailChanged(val),
  
  // 2. Bind styling & errors
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'user@example.com',
    
    // 3. Display error (returns String? or null)
    // If using Enum Errors: .displayError(...)?.translate(context)
    errorText: state.form.email.displayError(state.status),
    
    // 4. Optional: Visual cues for valid states
    suffixIcon: state.form.email.isValid 
        ? const Icon(Icons.check, color: Colors.green) 
        : null,
  ),
)
```

> **💡 Pro Tip: Text Controllers**
> When using state management, you generally **do not** need a `TextEditingController` unless you need to manipulate the cursor or clear the text programmatically. The `onChanged` callback is sufficient to keep your state in sync.

---

### 3. Toggles & Checkboxes (`BoolInput`)

Boolean inputs often don't have a built-in `errorText` property. You can wrap them or display the error below.

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

---

### 4. Custom & Generic Inputs (Dropdowns)

For inputs like `GenericInput` or `StandardInput` used with Dropdowns.

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

---

### 5. Submission Buttons

You can disable the button based on validity or show a loading indicator based on status.

```dart
FloatingActionButton(
  // Disable button if form is invalid (Optional style)
  // Or keep enabled to let 'displayError' show errors on click
  onPressed: state.form.isValid 
      ? () => cubit.submit() 
      : null,
      
  child: state.status.isSubmitting
      ? const CircularProgressIndicator(color: Colors.white)
      : const Icon(Icons.arrow_forward),
)
```

---

### 6. Integration with Flutter's `Form` Widget

**Do I need the `Form` widget?**
Strictly speaking, **no**. Flux Form handles validation independently.

However, you *may* still wrap your fields in a `Form` widget to utilize **Focus Management** (e.g., the "Next" button on the keyboard moving focus automatically).

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
*   **Why?** That triggers Flutter's internal mutable state validation.
*   **Instead:** Check `state.form.isValid` in your business logic.

---

### 7. Stateless vs Stateful

Because Flux Form moves state out of the widget tree:

1.  **Prefer `StatelessWidget`:** Your form screen should ideally be stateless, rebuilding only when your State Manager (Bloc/Riverpod/etc.) emits a new state.
2.  **Use `StatefulWidget` only if:**
    *   You are managing the form using vanilla `setState`.
    *   You need to manage `FocusNode`s or `ScrollController`s for complex UI interactions (e.g., "Scroll to first error").

---

## 📖 Deep Dive

### 1. Enums & State Management
Flux Form relies on three core enums to manage the lifecycle of forms and inputs. Understanding these is key to mastering the UI logic.

#### `FormStatus`
Represents the overall state of a `FormSchema` submission.
*   `initial`: The form has not been touched or submitted.
*   `submitting`: Async action in progress (show spinner).
*   `succeeded`: Action completed (navigate away).
*   `failed`: Action failed (show validation errors).
*   `canceled`: User backed out.

#### `InputStatus`
Tracks the interaction history of a specific `FormInput`.
*   `untouched`: The user has not interacted with this field yet.
*   `touched`: The user has focused/typed/blurred the field.
*   `validating`: An async validator (e.g., API check) is currently running.

#### `ValidationMode`
Controls *when* an error is revealed to the user via `displayError()`.
*   **`ValidationMode.live`**: Errors appear immediately as the user types, *if* the field is touched.
*   **`ValidationMode.deferred`**: Errors are suppressed until the `FormStatus` becomes `failed` (e.g., user presses Submit). Great for "Login" screens where red text early on is annoying.
*   **`ValidationMode.blur`**: Logically identical to `live`, but indicates intent to only mark the field as `touched` on focus loss (managed in UI via FocusNode).

---

### 2. Inputs Architecture
Every field in Flux Form extends `FormInput<T, E>`, where `T` is the value type and `E` is the error type.

#### Built-in Inputs
*   **`StringInput`**: Standard text.
*   **`BoolInput`**: Checkboxes, switches.
*   **`NumberInput`**: `int` or `double` handling.
*   **`DateTimeInput`**: Date pickers (nullable support).
*   **`ListInput<T, E>`**: Dynamic arrays (see below).
*   **`MapInput<K, V, E>`**: Key-Value collections.
*   **`GenericInput<T, E>`**: For quick one-off fields without creating a class.

#### Creating Custom Inputs
You should create custom classes for domain-specific logic (e.g., `EmailInput`, `MoneyInput`).

To do this, extend `FormInput` and mix in `InputMixin`. The mixin provides the fluent API (`replaceValue`, `reset`, `markTouched`).

```dart
// 1. Extend FormInput and use InputMixin
class MoneyInput extends FormInput<double, String> 
    with InputMixin<double, String, MoneyInput> {

  // 2. Constructors
  const MoneyInput.untouched({super.value = 0.0}) : super.untouched();
  
  const MoneyInput.touched({
    super.value = 0.0, 
    super.remoteError
  }) : super.touched();

  // 3. Private constructor for updates
  MoneyInput._(super.data) : super.fromData();

  // 4. Define Rules
  @override
  List<Validator<double, String>> get validators => [
    const MinNumberValidator(0, 'Cannot be negative'),
  ];

  // 5. Boilerplate: Connect the update method to the private constructor
  // This allows the Mixin to return the correct concrete type (MoneyInput)
  @override
  MoneyInput update({
    double? value,
    InputStatus? status,
    ValidationMode? mode,
    String? remoteError,
  }) {
    return MoneyInput._(prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ));
  }
}
```

#### Dynamic Lists (`ListInput`)
`ListInput` is designed for performance. It separates **Structure Validation** (e.g., "Must have 3 items") from **Item Validation** (e.g., "Item 2 is invalid").

*   **`validators`**: Validates the `List` itself.
*   **`itemValidators`**: Validates each item `T`.
*   **`itemErrorAt(index)`**: Returns the error for a specific index in O(1) time (cached during the update cycle).

---

### 3. Validators
Validators are pure functions that take a value and return `E?` (null means valid).

#### Textual & Numeric
*   `RequiredValidator`, `NotEmptyValidator`
*   `EmailValidator`, `RegexValidator`
*   `MinLengthValidator`, `MaxLengthValidator`
*   `MinNumberValidator`, `MaxNumberValidator`
*   `IsNumericStringValidator` (Checks if String parses to number)

#### Logic Validators (Advanced)
These allow you to conditionalize rules without cluttering your UI code.

*   **`WhenValidator`**: Runs the rule *only if* `condition` is true.
    ```dart
    // Only require reason if "Other" is selected
    WhenValidator(
      condition: state.isOtherSelected, 
      validator: RequiredValidator('Reason is required'),
    )
    ```
*   **`UnlessValidator`**: Runs the rule *unless* `condition` is true.
*   **`AnyValidator`**: Valid if *at least one* child validator passes.
*   **`MatchValidator`**: Checks if value matches another (e.g., Confirm Password).

---

### 4. Sanitizers
Sanitizers transform input data *before* it reaches the validators or the state. This ensures your data is always clean.

#### How it works
When you call `input.replaceValue('  Start  ')`, the pipeline runs:
`Input -> Sanitizers -> Validators -> State`

#### Examples
*   **`TrimSanitizer`**: `'  text  '` -> `'text'`
*   **`ToLowerCaseSanitizer`**: `'User@Email.com'` -> `'user@email.com'`
*   **`RemoveSpaceSanitizer`**: `'12 34 56'` -> `'123456'` (Great for credit cards/phones)

#### Custom Sanitizer
```dart
class CurrencySanitizer implements Sanitizer<String> {
  const CurrencySanitizer();

  @override
  String sanitize(String value) {
    // Remove '$' and ','
    return value.replaceAll(RegExp(r'[$,]'), ''); 
  }
}
```

---

### 5. Mixins
Mixins allow Flux Form to provide a fluent API while maintaining strict immutability.

#### `InputMixin<T, E, I>`
This is the engine room of custom inputs.
*   **Why use it?** It provides methods like `replaceValue`, `reset`, `markValidating`, and `setRemoteError`.
*   **Type Safety:** It takes generic `I` (Implementation) to ensure that `emailInput.replaceValue(...)` returns an `EmailInput`, not a generic `FormInput`.

#### `FormMixin`
*   **Use Case:** If you are not using `FormSchema` and are manually adding inputs to a Bloc state.
*   **Function:** It provides `isValid`, `isTouched`, and `invalidInputs` getters by iterating over a list of inputs you define.

---

### 6. Form Errors (Localization)
Using Strings for errors (`Validator<String, String>`) is simple, but bad for multi-language apps.

Flux Form supports **Type-Safe Errors** using Enums or Classes.

#### Step 1: Define the Error Enum
Implement `FormError` to ensure it works with standard inputs.

```dart
enum AuthError implements FormError {
  required('required'),
  invalidEmail('invalid_email'),
  tooShort('too_short'),
  unknown();
  
  // For analytics/logging/error from api
  final String? code;
  
  const AuthError([this.code])
  
  // Extension method for easy UI translation
  @override
  String message(BuildContext context) => switch (this) {
    AuthError.required => AppLocalizations.of(context).reqField,
    AuthError.invalidEmail => AppLocalizations.of(context).badEmail,
    AuthError.tooShort => AppLocalizations.of(context).shortPass,
    AuthError.unknown => '',
  };
}
```

#### Step 2: Use in Input
Define the input with `FormInput<T, AuthError>`.

```dart
class EmailInput extends FormInput<String, AuthError> 
    with InputMixin<String, AuthError, EmailInput> {
    
  @override
  List<Validator<String, AuthError>> get validators => [
    const RequiredValidator(AuthError.required),
    const EmailValidator(AuthError.invalidEmail),
  ];
  
  // ... boilerplate update ...
}
```

#### Step 3: Use in UI
```dart
Text(
  // displayError returns AuthError?
  form.email.displayError(state.status)?.message(context) ?? '',
  style: TextStyle(color: Colors.red),
)
```

---

## 🏗 Integration with Flutter Widgets

Flux Form is designed to decouple validation logic from the UI. This changes how you interact with standard Flutter widgets.

### 1. Do I need Flutter's `Form` widget?
**No, you do not need it for validation.**

*   **Flutter's Approach:** Uses `GlobalKey<FormState>`, `_formKey.currentState.validate()`, and `TextFormField`. State is mutable and locked inside the widget tree.
*   **Flux Form's Approach:** State is immutable and lives in your Business Logic (Cubit/Provider). You already know if the form is valid via `state.form.isValid`.

**When to use `Form` anyway?**
You can still wrap your inputs in a `Form` widget purely for **Focus Management** (e.g., handling "Next" and "Done" on the keyboard automatically). However, you should **not** use `_formKey.validate()`.

### 2. `TextField` vs `TextFormField`
Flux Form works with both, but the configuration is slightly different from standard Flutter forms.

**❌ The Standard Way (Don't do this):**
Do not use the `validator` callback. This runs validation inside the UI render phase, which Flux Form tries to avoid.
```dart
TextFormField(
  // ❌ Don't use this. Logic shouldn't be in the UI.
  validator: (value) {
    if (value == null) return 'Error';
    return null;
  },
)
```

**✅ The Flux Form Way:**
Use the `errorText` property. Flux Form calculates the error *before* the UI builds.
```dart
TextField(
  // ✅ Correct. The error is already calculated in your state.
  decoration: InputDecoration(
    errorText: form.email.displayError(state.status), 
  ),
  onChanged: (val) => cubit.emailChanged(val),
)
```

### 3. Stateless vs. Stateful Widgets
Because Flux Form moves state management *out* of the widget tree and into your State Manager (Bloc, Riverpod, etc.), your Form Screens should ideally be **StatelessWidgets**.

*   **StatelessWidget (Recommended):** Use this with Bloc, Riverpod, or Provider. The widget simply renders the current state provided by the stream/notifier.
*   **StatefulWidget:** Use this only if:
    1.  You are using **Vanilla `setState`** to manage the Flux Form.
    2.  You need local `TextEditingControllers` (though Flux Form usually eliminates the need for controllers unless you need specific cursor manipulation).

### Summary Table

| Feature               | Standard Flutter Form             | Flux Form                            |
|:----------------------|:----------------------------------|:-------------------------------------|
| **Widget Type**       | `StatefulWidget` (usually)        | `StatelessWidget` (preferred)        |
| **Validation Source** | `validator: (val) => ...`         | `field.validators` list              |
| **Error Display**     | Triggered by `formKey.validate()` | `errorText: field.displayError(...)` |
| **Form State**        | `GlobalKey<FormState>`            | `FormSchema` class                   |
| **Controllers**       | Required for text access          | Optional (Value is in State)         |

---

## ❤️ Contributing

Issues and Pull Requests are welcome!
Flux Form aims to be the standard for clean, maintainable forms in Dart.