import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizer_pipeline.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validator_pipeline.dart';

class MapInput<K, V, E> extends FormInput<Map<K, V>, E> {
  const MapInput.untouched({
    super.value = const {},
    super.mode,
    super.errorCache,
  }) : super.untouched();

  const MapInput.touched({
    super.value = const {},
    super.initialValue,
    super.mode,
    super.errorCache,
    super.remoteError,
  }) : super.touched();

  MapInput._(super.data) : super.fromData();

  /// Validates every VALUE in the map
  List<Validator<V, E>> get valueValidators => [];

  List<Sanitizer<V>> get valueSanitizers => [];

  @override
  MapInput<K, V, E> update({
    Map<K, V>? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) => MapInput._(
    prepareUpdate(
      value: value,
      status: status,
      mode: mode,
      remoteError: remoteError,
    ),
  );

  @override
  E? validate(Map<K, V> value) {
    // 1. Structure
    final structError = ValidatorPipeline.validate(value, validators);
    if (structError != null) return structError;

    // 2. Values
    if (valueValidators.isNotEmpty) {
      for (final val in value.values) {
        final err = ValidatorPipeline.validate(val, valueValidators);
        if (err != null) return err;
      }
    }

    return null;
  }

  E? getValueError(K key) {
    if (!value.containsKey(key)) return null;

    return ValidatorPipeline.validate(value[key] as V, valueValidators);
  }

  MapInput<K, V, E> putItem(K key, V item) {
    final sanitized = SanitizerPipeline.sanitize(item, valueSanitizers);
    final newMap = Map<K, V>.from(value);
    newMap[key] = sanitized;

    return update(value: newMap, status: InputStatus.touched);
  }

  MapInput<K, V, E> removeItem(K key) {
    final newMap = Map<K, V>.from(value)..remove(key);

    return update(value: newMap, status: InputStatus.touched);
  }
}
