import 'package:flux_form/src/chains/sanitizer_chains.dart';
import 'package:flux_form/src/chains/validator_chains.dart';
import 'package:flux_form/src/sanitization/sanitizer.dart';
import 'package:flux_form/src/validation/validator.dart';
import 'package:flux_form/src/validation/validators/logic_validator.dart';

/// Entry point for fluent chaining.
class ValidatorBuilder {

  const ValidatorBuilder._();

  /// Starts a validation chain for Strings.
  static StringValidatorChain<E> string<E>() => StringValidatorChain<E>();

  /// Starts a validation chain for Numbers.
  static NumberValidatorChain<E> number<E>() => NumberValidatorChain<E>();

  /// Starts a validation chain for Lists.
  static ListValidatorChain<T, E> list<T, E>() => ListValidatorChain<T, E>();

  /// Starts a generic validation chain.
  static GenericValidatorChain<T, E> generic<T, E>() => GenericValidatorChain<T, E>();
}

class SanitizerBuilder {
  const SanitizerBuilder._();

  /// Starts a sanitization chain for Strings.
  static StringSanitizerChain string() => StringSanitizerChain();
}

/// Base class for building lists of validators.
class ValidatorChain<T, E, C extends ValidatorChain<T, E, C>> {
  final List<Validator<T, E>> _validators = [];

  /// Adds a custom validator to the chain.
  C add(Validator<T, E> validator) {
    _validators.add(validator);
    return this as C;
  }

  /// Adds a validator only if [condition] is true.
  C when(bool Function() condition, Validator<T, E> validator) {
    _validators.add(LogicValidator.when(condition: condition, validator: validator));
    return this as C;
  }

  /// Returns the final list of validators.
  List<Validator<T, E>> build() => List.unmodifiable(_validators);
}

/// Base class for building lists of sanitizers.
class SanitizerChain<T, C extends SanitizerChain<T, C>> {
  final List<Sanitizer<T>> _sanitizers = [];

  C add(Sanitizer<T> sanitizer) {
    _sanitizers.add(sanitizer);
    return this as C;
  }

  List<Sanitizer<T>> build() => List.unmodifiable(_sanitizers);
}
