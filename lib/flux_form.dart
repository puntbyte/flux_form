// lib/flux_form.dart

/// Flux Form — modular, type-safe, state-management-agnostic form library.
library;

// ── Builders ──────────────────────────────────────────────────────────────────
export 'src/forms/builders/bool_input_builder.dart';
export 'src/forms/builders/datetime_input_builder.dart';
export 'src/forms/builders/list_input_builder.dart';
export 'src/forms/builders/map_input_builder.dart';
export 'src/forms/builders/number_input_builder.dart';
export 'src/forms/builders/string_input_builder.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────
export 'src/forms/enums/input_status.dart';
export 'src/forms/enums/submission_status.dart';
export 'src/forms/enums/validation_mode.dart';

// ── Form core ─────────────────────────────────────────────────────────────────
export 'src/forms/form_error.dart';
export 'src/forms/form_input.dart';
export 'src/forms/form_schema.dart';      // FormSchema + EditableSchema mixin
export 'src/forms/form_validator.dart';
export 'src/forms/multi_step_schema.dart';
export 'src/forms/schema_validator.dart';

// ── Inputs ────────────────────────────────────────────────────────────────────
// Each family: abstract base (for inheritance) + Simple* concrete (for composition).
//
//   Abstract base        Concrete
//   ─────────────────    ──────────────────────
//   BoolInput            SimpleBoolInput
//   DateTimeInput        SimpleDateTimeInput
//   BaseListInput        ListInput
//   MapInput             SimpleMapInput
//   NumberInput          SimpleNumberInput
//   ObjectInput          SimpleObjectInput   (replaces StandardInput)
//   StringInput          SimpleStringInput
//
export 'src/forms/inputs/bool_input.dart';
export 'src/forms/inputs/date_time_input.dart';
export 'src/forms/inputs/list_input.dart';
export 'src/forms/inputs/map_input.dart';
export 'src/forms/inputs/number_input.dart';
export 'src/forms/inputs/object_input.dart';    // ObjectInput + SimpleObjectInput
export 'src/forms/inputs/string_input.dart';

// ── Mixins ────────────────────────────────────────────────────────────────────
export 'src/forms/mixins/form_mixin.dart';
export 'src/forms/mixins/input_mixin.dart';

// ── Models ────────────────────────────────────────────────────────────────────
export 'src/forms/models/input_data.dart';

// ── Utilities ─────────────────────────────────────────────────────────────────
// Note: debouncing, throttling, and rate-limiting are intentionally NOT
// provided by this library. Use an external package that fits your project:
//
//   • dart:async Timer   — standard library, zero dependencies
//   • rxdart             — stream-based, great for complex async flows
//   • easy_debounce      — simple, named debounce slots
//   • stream_transform   — debounce/throttle operators for streams
//
// flux_form is compatible with all of the above. Call [InputMixin.runAsync]
// or [InputMixin.runBuiltInAsyncValidation] inside whichever debounce
// mechanism you choose — the library does not care how the call is scheduled.
export 'src/forms/utilities/form_submitter.dart';

// ── Sanitization core ─────────────────────────────────────────────────────────
export 'src/sanitization/sanitizer.dart';        // Sanitizer + Sanitizer.compose
export 'src/sanitization/sanitizer_pipeline.dart';

// ── Sanitizers ────────────────────────────────────────────────────────────────
export 'src/sanitization/sanitizers/list_sanitizer.dart';
export 'src/sanitization/sanitizers/number_sanitizer.dart';
export 'src/sanitization/sanitizers/string_sanitizer.dart';

// ── Validation core ───────────────────────────────────────────────────────────
export 'src/validation/validator.dart';          // Validator.compose + AsyncValidator.compose
export 'src/validation/validator_pipeline.dart'; // + validateAsyncParallel

// ── Validators ────────────────────────────────────────────────────────────────
export 'src/validation/validators/bool_validator.dart';
export 'src/validation/validators/comparable_validator.dart';
export 'src/validation/validators/external_validator.dart';
export 'src/validation/validators/file_validators.dart';
export 'src/validation/validators/format_validator.dart';
export 'src/validation/validators/list_validator.dart';
export 'src/validation/validators/logic_validator.dart';
export 'src/validation/validators/map_validator.dart';
export 'src/validation/validators/number_validator.dart';
export 'src/validation/validators/object_validator.dart';
export 'src/validation/validators/string_validator.dart';