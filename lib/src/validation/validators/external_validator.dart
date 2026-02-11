import 'package:flux_form/src/forms/form_input.dart';
import 'package:flux_form/src/validation/validator.dart';

/// A standard Flutter validation signature used by most packages.
typedef ExternalValidationRule<T> = String? Function(T? value);

/// A namespace for adapting external validation libraries (like form_builder_validators)
/// into Flux Form validators.
abstract class ExternalValidator<T, E> extends Validator<T, E> {
  const ExternalValidator(super.error);

  /// Uses an external validator that returns a String, and uses that String as the error.
  ///
  /// Use this if your [FormInput] uses [String] as its error type.
  ///
  /// Example:
  /// ```dart
  /// ExternalValidator.delegate(FormBuilderValidators.email())
  /// ```
  static Validator<T, String> delegate<T>(
    ExternalValidationRule<T> rule,
  ) => _ExternalDelegateValidator<T>(rule);

  /// Uses an external validator, but ignores its error message and uses [error] instead.
  ///
  /// Use this if you want the logic from the package, but your own error object (e.g. Enum).
  ///
  /// Example:
  /// ```dart
  /// ExternalValidator.override(
  ///   FormBuilderValidators.email(),
  ///   AuthError.invalidEmail
  /// )
  /// ```
  static Validator<T, E> override<T, E>(
    ExternalValidationRule<T> rule,
    E error,
  ) => _ExternalOverrideValidator<T, E>(rule, error);

  /// Uses an external validator and maps its String error to type [E].
  ///
  /// Use this if you want to wrap the external error message inside your own object.
  ///
  /// Example:
  /// ```dart
  /// ExternalValidator.map(
  ///   FormBuilderValidators.minLength(5),
  ///   (msg) => MyError(message: msg)
  /// )
  /// ```
  static Validator<T, E> map<T, E>(
    ExternalValidationRule<T> rule,
    E Function(String externalMessage) mapper,
  ) => _ExternalMapValidator<T, E>(rule, mapper);
}

// ================= Implementation =================

class _ExternalDelegateValidator<T> extends Validator<T, String> {
  final ExternalValidationRule<T> rule;

  const _ExternalDelegateValidator(this.rule) : super(null);

  @override
  String? validate(T value) {
    // External rules usually accept T?, so passing T is safe.
    return rule(value);
  }
}

class _ExternalOverrideValidator<T, E> extends Validator<T, E> {
  final ExternalValidationRule<T> rule;

  const _ExternalOverrideValidator(this.rule, E error) : super(error);

  @override
  E? validate(T value) {
    final result = rule(value);
    // If result is not null (error exists), return OUR error [E].
    return result != null ? error : null;
  }
}

class _ExternalMapValidator<T, E> extends Validator<T, E> {
  final ExternalValidationRule<T> rule;
  final E Function(String) mapper;

  const _ExternalMapValidator(this.rule, this.mapper) : super(null);

  @override
  E? validate(T value) {
    final result = rule(value);
    if (result == null) return null;
    return mapper(result);
  }
}
