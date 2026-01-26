// lib/flux_form.dart

/// Flux Form
library;

// Enums
export 'src/forms/enums/form_status.dart';
export 'src/forms/enums/input_status.dart';
export 'src/forms/enums/validation_mode.dart';

// Form Core
export 'src/forms/form_error.dart';
export 'src/forms/form_group.dart';
export 'src/forms/form_input.dart';
export 'src/forms/form_validator.dart';

// Inputs
export 'src/forms/inputs/bool_input.dart';
export 'src/forms/inputs/date_time_input.dart';
export 'src/forms/inputs/generic_input.dart';
export 'src/forms/inputs/list_input.dart';
export 'src/forms/inputs/map_input.dart';
export 'src/forms/inputs/number_input.dart';
export 'src/forms/inputs/standard_input.dart';
export 'src/forms/inputs/string_input.dart';

// Mixins
export 'src/forms/mixins/form_mixin.dart';
export 'src/forms/mixins/input_mixin.dart';

// Models
export 'src/forms/models/input_data.dart';

// Sanitization Core
export 'src/sanitization/sanitizer.dart';
export 'src/sanitization/sanitizer_pipeline.dart';

// Sanitizers
export 'src/sanitization/sanitizers/textual_sanitizers.dart';

// Validation Core
export 'src/validation/validator.dart';
export 'src/validation/validator_pipeline.dart';

// Validators
export 'src/validation/validators/comparable_validators.dart';
export 'src/validation/validators/file_validators.dart';
export 'src/validation/validators/general_validators.dart';
export 'src/validation/validators/logic_validators.dart';
export 'src/validation/validators/numeric_validators.dart';
export 'src/validation/validators/textual_validators.dart';
