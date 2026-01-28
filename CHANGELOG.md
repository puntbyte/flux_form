## 0.3.0

✨ **The Schema Update**

This release addresses a common naming collision in the Flutter ecosystem. By renaming `FormGroup` to `FormSchema`, we create a clear separation between your UI Widgets (e.g., `LoginForm`) and your Data Logic (`LoginSchema`).

### ⚠️ Breaking Changes
- **Core Architecture**:
    - **Renamed `FormGroup` to `FormSchema`**.
    - All forms should now extend `FormSchema` and implement the `namedInputs` getter.
- **ListInput API**:
    - Renamed `getItemError(index)` to **`itemErrorAt(index)`** to align with Dart standards.
    - Renamed `getValueError(key)` in `MapInput` to **`valueErrorAt(key)`**.
- **Sanitization**:
    - `ListInput` and `MapInput` now override `sanitize`. When replacing the entire collection value, the **items** inside are now passed through the sanitizer pipeline (e.g., trimming all strings in a list automatically).

### 🚀 New Features
- **Async Validation Workflow**:
    - Added `markValidating()` and `resolveAsyncValidation(error)` to `InputMixin`.
    - Makes handling server-side checks (like "Username Availability") declarative and clean.
- **Detailed Errors**:
    - Added `detailedErrors` getter to `FormInput`.
    - Returns *all* failing validation rules, not just the first one. Perfect for **Password Strength Meters**.

### ⚡️ Improvements & Fixes
- **ListInput Performance**:
    - Validation now runs in a **Single Pass**. It calculates structure validity (e.g., Min Length) and Item validity (e.g., Item #3 empty) simultaneously.
    - `itemErrorAt(index)` is now an **O(1)** operation, using cached results from the update cycle.
- **Immutability Hardening**:
    - `ListInput` mutation helpers (`addItem`, `removeItem`) and `MapInput` helpers (`putItem`) now explicitly create new instances (`List.of`, `Map.of`). This guarantees that `==` equality checks correctly trigger UI rebuilds in Bloc/Riverpod.
- **Serialization Fix**:
    - Fixed an issue where `FormSchema.values` could throw a type error. It now strictly returns `Map<String, dynamic>`.
- **Remote Error Logic**:
    - Refined `prepareUpdate` logic. Resetting a field to `untouched` now correctly clears any lingering API/Remote errors.


## 0.2.0

🚀 **The Architecture Update**

This release introduces major architectural improvements, bringing `FormGroup` for aggregation and renaming core classes to better align with standard form terminology.

### ⚠️ Breaking Changes
- **Renaming**:
    - `Field` class is now **`FormInput`**.
    - `StringField` → **`StringInput`**, `ListField` → **`ListInput`**, etc.
    - `ValidationMode.onInteraction` → **`ValidationMode.live`**.
    - `ValidationMode.onSubmit` → **`ValidationMode.deferred`**.
    - `ValidationMode.onUnfocus` → **`ValidationMode.blur`**.
- **Mixins**:
    - `FieldCacheMixin` has been removed. Caching logic is now built natively into `FormInput`.
    - Added `InputMixin` to provide fluent API methods (`replaceValue`, `markTouched`).

### ✨ New Features
- **FormGroup**:
    - A new base class to aggregate multiple inputs.
    - Automatically handles `isValid`, `isTouched`, and serialization via the `values` getter.
- **New Inputs**:
    - **`MapInput`**: Support for Key-Value collections validation.
    - **`GenericInput`**: A concrete implementation for creating one-off inputs without subclassing.
- **Sanitization**:
    - `sanitize` method is now customizable in subclasses and runs automatically during `update`.
- **Async Workflow**:
    - Added `markValidating()` and `resolveAsyncValidation()` helpers to `InputMixin`.

### 🐞 Fixes
- **Remote Errors**: Logic updated to automatically clear "Server Errors" (e.g., *Email Taken*) as soon as the user modifies the input.
- **Immutability**: `ListInput` and `MapInput` mutation helpers (`addItem`, `putItem`) now correctly create new instances to ensure state equality checks work.

## 0.1.0

🚀 **Initial Release**

FluxForm is a modular, composition-based form state management library designed to replace boilerplate with type-safe fields and declarative validation pipelines.

### Core Features
- **Generic Fields**:
    - `StringField`: Optimized for text inputs.
    - `ListField`: First-class support for dynamic arrays with O(1) read performance.
    - `StandardField`: Generic field support for Enums or Objects.
- **Validation Pipeline**:
    - Decoupled `Validator<T, E>` architecture.
    - Built-in library of validators (Textual, Numeric, Logic, Comparison).
- **Sanitization Pipeline**:
    - Transform data before validation (e.g., `Trim`, `ToLowerCase`).
- **Smart UI State**:
    - `displayError(status)`: Automatically resolves whether to show errors based on the form's lifecycle.