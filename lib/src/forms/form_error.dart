// lib/src/forms/form_error.dart

/// Interface for form errors.
abstract interface class FormError {
  String get code;

  String message([dynamic context]);
}
