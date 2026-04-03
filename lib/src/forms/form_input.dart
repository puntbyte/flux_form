// lib/src/forms/form_input.dart

import 'package:flux_form/src/forms/enums/input_status.dart';
import 'package:flux_form/src/forms/enums/submission_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:flux_form/src/forms/form_schema.dart';
import 'package:flux_form/src/forms/mixins/input_mixin.dart';
import 'package:flux_form/src/forms/models/input_data.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/sanitization/sanitizer_pipeline.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validator_pipeline.dart';
import 'package:meta/meta.dart';

@immutable
abstract class FormInput<T, E> {
  final T value;
  final T initialValue;
  final InputStatus status;
  final ValidationMode mode;
  final E? _remoteError;
  final E? _cachedError;

  const FormInput.untouched({
    required this.value,
    this.mode = ValidationMode.live,
    E? errorCache,
  }) : initialValue = value,
       status = InputStatus.untouched,
       _remoteError = null,
       _cachedError = errorCache;

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

  // ── Validation pipeline ───────────────────────────────────

  /// Synchronous validators run against [value].
  List<Validator<T, E>> get validators => const [];

  /// Asynchronous validators run via [InputMixin.runBuiltInAsyncValidation].
  List<AsyncValidator<T, E>> get asyncValidators => const [];

  // ── Sanitization pipeline ─────────────────────────────────

  List<Sanitizer<T>> get sanitizers => const [];

  // ── Error resolution ──────────────────────────────────────

  E? get localError {
    if (_cachedError case final cached?) return cached;
    return validate(value);
  }

  /// Remote errors take precedence over local ones.
  E? get error => _remoteError ?? localError;

  // ── Status flags ──────────────────────────────────────────

  bool get isTouched => status == InputStatus.touched;

  bool get isUntouched => status == InputStatus.untouched;

  bool get isValid => localError == null && _remoteError == null;

  bool get isNotValid => !isValid;

  /// True when the current value equals the [initialValue] (user has not
  /// changed the field from its starting state).
  bool get isPristine => value == initialValue;

  /// True when the current value differs from [initialValue].
  ///
  /// Opposite of [isPristine]. Useful for building PATCH payloads — combine
  /// with [FormSchema.changedValues] to send only modified fields.
  bool get isDirty => !isPristine;

  bool get isValidating => status == InputStatus.validating;

  // ── Validation helpers ────────────────────────────────────

  E? validate(T value) => ValidatorPipeline.validate(value, validators);

  Future<E?> validateAsync(T value) => ValidatorPipeline.validateAsync(value, asyncValidators);

  T sanitize(T value) => SanitizerPipeline.sanitize(value, sanitizers);

  // ── UI error display ──────────────────────────────────────

  /// Resolves the error to show in the UI based on [SubmissionStatus] and [ValidationMode].
  E? displayError(SubmissionStatus status) {
    if (status.isFailure) return error;

    switch (mode) {
      case ValidationMode.deferred:
        return null;
      case ValidationMode.live:
      case ValidationMode.blur:
        return isTouched ? error : null;
    }
  }

  /// ALL validation errors for the current value — bypasses the cache.
  /// Use for password-strength meters or multi-requirement checklists.
  List<E> get detailedErrors => ValidatorPipeline.validateAll(value, validators);

  // ── Mutation (internal) ───────────────────────────────────

  /// ⚠️ Known limitation: when [T] is nullable (e.g., `DateTime?`), passing
  /// `value: null` is indistinguishable from omitting `value`. Use
  /// [InputMixin.reset] to revert a nullable field to its initial value.
  @protected
  InputData<T, E> prepareUpdate({
    T? value,
    InputStatus? status,
    ValidationMode? mode,
    E? remoteError,
  }) {
    final rawValue = value ?? this.value;
    final valueChanged = value != null && value != this.value;
    final sanitizedValue = value != null ? sanitize(rawValue) : rawValue;

    final computedError = valueChanged || _cachedError == null
        ? validate(sanitizedValue)
        : _cachedError;

    final effectiveStatus = status ?? this.status;

    E? effectiveRemote;
    if (remoteError != null) {
      effectiveRemote = remoteError;
    } else if (effectiveStatus == InputStatus.untouched) {
      effectiveRemote = null;
    } else if (valueChanged) {
      effectiveRemote = null;
    } else {
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
