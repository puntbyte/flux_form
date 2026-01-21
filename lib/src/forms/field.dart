// lib/src/forms/field.dart

import 'package:flux_form/src/forms/enums/form_status.dart';
import 'package:flux_form/src/forms/enums/validation_mode.dart';
import 'package:meta/meta.dart';

@immutable
abstract class Field<T, E> {
  final T value;
  final bool isTouched;
  final ValidationMode mode;
  final E? _remoteError;
  final E? _cachedError;

  /// Protected constructor.
  @protected
  const Field.raw({
    required this.value,
    required this.isTouched,
    this.mode = ValidationMode.onInteraction,
    E? remoteError,
    E? errorCache,
  }) : _remoteError = remoteError,
       _cachedError = errorCache;

  const Field.untouched(
    this.value, {
    this.mode = ValidationMode.onInteraction,
    E? errorCache,
  }) : isTouched = false,
       _remoteError = null,
       _cachedError = errorCache;

  const Field.touched(
    this.value, {
    this.mode = ValidationMode.onInteraction,
    E? remoteError,
    E? errorCache,
  }) : isTouched = true,
       _remoteError = remoteError,
       _cachedError = errorCache;

  /// Local validation result.
  ///
  /// By default this calls `validate(value)` on every access **unless**
  /// a `_precomputedLocalError` was provided (then that value is used).
  ///
  /// If you want to cache the result to avoid repeated expensive validation,
  /// use `FieldLocalErrorCacheMixin` on your concrete subclass (see below).
  E? get localError => _cachedError ?? validate(value);

  E? get error => _remoteError ?? localError;

  bool get isUntouched => !isTouched;

  /// Now works correctly for Pure inputs too!
  bool get isValid => localError == null && _remoteError == null;

  bool get isNotValid => !isValid;

  /// Define your validation logic here.
  /// This is called automatically by the constructor.
  E? validate(T value);

  /// Define sanitization logic here (optional).
  /// Call this inside your copyWith or factories.
  T sanitize(T value) => value;

  E? displayError(FormStatus status) {
    if (status.isFailed) return error;
    switch (mode) {
      case ValidationMode.onSubmit:
        return null;
      case ValidationMode.onInteraction:
      case ValidationMode.onUnfocus:
        return isTouched ? error : null;
    }
  }

  /// Must be implemented by subclasses to return the correct type.
  Field<T, E> copyWith({
    T? value,
    bool? isTouched,
    ValidationMode? mode,
    E? remoteError,
  });

  @override
  int get hashCode => Object.hash(value, isTouched, mode, _remoteError);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Field<T, E> &&
        other.value == value &&
        other.isTouched == isTouched &&
        other.mode == mode &&
        other._remoteError == _remoteError;
  }
}
