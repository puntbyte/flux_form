## 0.1.0

🚀 **Initial Release**

FluxForm is a modular, composition-based form state management library designed to replace 
boilerplate with type-safe fields and declarative validation pipelines.

### Core Features
- **Generic Fields**:
    - `StringField`: Optimized for text inputs with built-in sanitization hooks.
    - `ListField`: First-class support for dynamic arrays with O(1) read performance using smart caching.
    - `StandardField`: Generic field support for Enums, Objects, or custom types.
- **Validation Pipeline**:
    - Decoupled `Validator<T, E>` architecture.
    - Support for Synchronous and Asynchronous validation.
    - Built-in library of validators:
        - **Textual**: `Required`, `Email`, `MinLength`, `MaxLength`, `Regex`, `NotEmpty`.
        - **Numeric**: `MinNumber`, `MaxNumber`, `NonNegative`, `IsNumericString`.
        - **Logic**: `When` (Conditional), `Any` (OR logic).
        - **Comparison**: `Match`, `GreaterThan`, `LessThan`.
- **Sanitization Pipeline**:
    - Automatically transform data before validation (e.g., `Trim`, `ToLowerCase`).
- **Smart UI State**:
    - `ValidationMode`: Control visibility of errors (`onInteraction`, `onSubmit`, `onUnfocus`).
    - `displayError(status)`: Automatically resolves whether to show errors based on the form's lifecycle.
- **Mixins**:
    - `FormMixin`: Aggregates form state (`isValid`, `isTouched`) for easy integration with BLoC/Provider.
    - `FieldCacheMixin`: Enforces single-pass validation for complex fields to improve performance.