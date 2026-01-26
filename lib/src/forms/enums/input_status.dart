// lib/src/forms/enums/input_status.dart

/// Enum for tracking the interaction state of a form field.
enum InputStatus {
  /// Indicates the input is modified.
  touched,

  /// Indicates the input is not modified.
  untouched,

  /// Indicates the input is validating. Used in async validators.
  validating,
}
