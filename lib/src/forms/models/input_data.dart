// lib/src/forms/models/input_data.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';

class InputData<T, E> {
  final T value;
  final T initialValue;
  final InputStatus status;
  final ValidationMode mode;
  final E? remoteError;
  final E? errorCache;

  const InputData({
    required this.value,
    required this.initialValue,
    required this.status,
    required this.mode,
    required this.remoteError,
    required this.errorCache,
  });
}
