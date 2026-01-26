// lib/src/forms/form_input.dart

import 'package:flux_form/src/forms/enums/form_status.dart';
import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/models/input_data.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizer_pipeline.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validator_pipeline.dart';
import 'package:meta/meta.dart';

@immutable
abstract class FormInput<T, E> {
  /// The current value of the input.
  final T value;

  /// The value this input had when it was first created [FormInput.untouched].
  final T initialValue;

  /// The interaction state (touched/untouched).
  final InputStatus status;

  /// Controls when errors are displayed (Live, Deferred, Blur).
  final ValidationMode mode;

  /// An error injected from an external source (API, Server).
  final E? _remoteError;

  /// Cached result of local validation to avoid recomputation.
  final E? _cachedError;

  /// Creates a field in its initial state [isTouched] false).
  /// Sets [initialValue] to [value].
  const FormInput.untouched({
    required this.value,
    this.mode = ValidationMode.live,
    E? errorCache,
  }) : initialValue = value,
       status = InputStatus.untouched,
       _remoteError = null,
       _cachedError = errorCache;

  /// Creates a field that has been modified (isTouched: true).
  ///
  /// [initialValue] must be passed to persist history, otherwise it defaults to [value].
  const FormInput.touched({
    required this.value,
    T? initialValue,
    this.mode = ValidationMode.live,
    E? remoteError,
    E? errorCache,
  }) : initialValue = initialValue ?? value,
       status = InputStatus.touched,
       _remoteError = remoteError,
       _cachedError = errorCache;

  FormInput.fromData(InputData<T, E> data)
    : value = data.value,
      initialValue = data.initialValue,
      status = data.status,
      mode = data.mode,
      _remoteError = data.remoteError,
      _cachedError = data.errorCache;

  /// Sanitizers to transform the value before validation.
  List<Sanitizer<T>> get sanitizers => const [];

  /// Validators to run against the value.
  List<Validator<T, E>> get validators => const [];

  /// Returns the local validation error (cached if available).
  E? get localError {
    if (_cachedError case final cached?) return cached;
    // Only compute if not cached
    final error = validate(value);
    // Note: You can't cache here since this is a getter and class is immutable
    return error;
  }

  /// Returns the effective error. Remote errors take precedence over local ones.
  E? get error => _remoteError ?? localError;

  /// Returns true if the field has been touched.
  bool get isTouched => status == InputStatus.touched;

  /// Returns true if the field has not been touched.
  bool get isUntouched => status == InputStatus.untouched;

  /// Returns true if there are no local OR remote errors.
  bool get isValid => localError == null && _remoteError == null;

  /// Returns true if there are any errors (local or remote).
  bool get isNotValid => !isValid;

  /// Returns true if the value equals [initialValue].
  bool get isPristine => value == initialValue;

  /// Returns true if async validation is currently running
  bool get isValidating => false;

  /// Define your validation logic here.
  /// This is called automatically by the constructor.
  E? validate(T value) => ValidatorPipeline.validate(value, validators);

  /// Override to enable async validation (e.g., username availability)
  Future<E?> validateAsync(T value) async => null;

  /// Define sanitization logic here (optional).
  /// Call this inside your copyWith or factories.
  T sanitize(T value) => SanitizerPipeline.sanitize(value, sanitizers);

  /// Resolves the error to display in the UI based on [FormStatus] and [ValidationMode].
  E? displayError(FormStatus status) {
    if (status.isFailed) return error;

    switch (mode) {
      case ValidationMode.deferred:
        return null; // Hidden until submit fails
      case ValidationMode.live:
      case ValidationMode.blur:
        return isTouched ? error : null;
    }
  }

  /// Centralizes the logic for updating a field.
  @protected
  InputData<T, E> prepareUpdate({
    T? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) {
    // 1. Resolve Value
    final rawValue = value ?? this.value;
    final valueChanged = value != null && value != this.value;

    // 2. Sanitize
    final sanitizedValue = value != null ? sanitize(rawValue) : rawValue;

    // 3. Validate (Smart Caching)
    final computedError = valueChanged || _cachedError == null
        ? validate(sanitizedValue)
        : _cachedError;

    // 4. Resolve Touched
    //final effectiveTouched = (isTouched ?? false) || this.isTouched;
    final effectiveStatus = status ?? this.status;

    // 5. Resolve Remote Error
    // Logic: Explicit override > Clear on change > Preserve stale
    E? effectiveRemote;
    if (remoteError != null) {
      // Explicit new error takes precedence
      effectiveRemote = remoteError;
    } else if (effectiveStatus == InputStatus.untouched) {
      // ⚡️ Logic Fix: If we are resetting to Untouched, clear remote errors.
      effectiveRemote = null;
    } else if (valueChanged) {
      // ⚡️ Logic Fix: If value changed, assume old remote error is stale.
      effectiveRemote = null;
    } else {
      // Preserve existing
      effectiveRemote = _remoteError;
    }

    return InputData(
      value: sanitizedValue,
      initialValue: initialValue,
      status: effectiveStatus,
      mode: mode ?? this.mode,
      remoteError: effectiveRemote,
      errorCache: computedError,
    );
  }

  FormInput<T, E> update({
    T? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  });

  @protected
  E? get currentRemoteError => _remoteError;

  @override
  int get hashCode => Object.hash(value, initialValue, status, mode, _remoteError);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormInput<T, E> &&
        other.value == value &&
        other.initialValue == initialValue &&
        other.status == status &&
        other.mode == mode &&
        other._remoteError == _remoteError;
  }
}
