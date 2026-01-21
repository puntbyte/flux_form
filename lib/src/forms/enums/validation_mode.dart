// lib/src/models/enums/validation_mode.dart

import 'package:flux_form/src/forms/enums/form_status.dart';

/// Controls when validation errors are displayed to users.
enum ValidationMode {
  /// Show errors only after the [FormStatus] changes to [FormStatus.failed].
  /// Useful for "Submit-only" validation forms (e.g., Login screens).
  onSubmit,

  /// Show errors immediately as the user types, provided the input is 'dirty'.
  /// This is the standard behavior for most modern forms.
  onInteraction,

  /// Logically similar to [onInteraction] in this package.
  /// True "blur" validation (validate on focus lost) is a UI concern,
  /// but selecting this treats the input as [onInteraction] mode.
  onUnfocus,
}
