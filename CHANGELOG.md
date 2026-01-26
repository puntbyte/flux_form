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

---

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