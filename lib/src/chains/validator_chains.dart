// lib/src/chains/validator_chains.dart

import 'package:flux_form/src/chains/flux_chain.dart';
import 'package:flux_form/src/validation/validators/format_validator.dart';
import 'package:flux_form/src/validation/validators/list_validator.dart';
import 'package:flux_form/src/validation/validators/number_validator.dart';
import 'package:flux_form/src/validation/validators/object_validator.dart';
import 'package:flux_form/src/validation/validators/string_validator.dart';

// --- String Chain ---
class StringValidatorChain<E> extends ValidatorChain<String, E, StringValidatorChain<E>> {
  StringValidatorChain<E> required(E error) => add(StringValidator.required(error));

  StringValidatorChain<E> notEmpty(E error) => add(StringValidator.notEmpty(error));

  StringValidatorChain<E> email(E error) => add(FormatValidator.email(error));

  StringValidatorChain<E> url(E error) => add(FormatValidator.url(error));

  StringValidatorChain<E> minLength(int min, E error) => add(StringValidator.minLength(min, error));

  StringValidatorChain<E> maxLength(int max, E error) => add(StringValidator.maxLength(max, error));

  StringValidatorChain<E> pattern(RegExp reg, E error) => add(StringValidator.pattern(reg, error));

  StringValidatorChain<E> numeric(E error) => add(StringValidator.isNumeric(error));
}

// --- Number Chain ---
class NumberValidatorChain<E> extends ValidatorChain<num, E, NumberValidatorChain<E>> {
  NumberValidatorChain<E> min(num min, E error) => add(NumberValidator.min(min, error));

  NumberValidatorChain<E> max(num max, E error) => add(NumberValidator.max(max, error));

  NumberValidatorChain<E> positive(E error) => add(NumberValidator.positive(error));
}

// --- List Chain ---
class ListValidatorChain<T, E> extends ValidatorChain<List<T>, E, ListValidatorChain<T, E>> {
  ListValidatorChain<T, E> notEmpty(E error) => add(ListValidator.notEmpty(error));

  ListValidatorChain<T, E> minLength(int min, E error) => add(ListValidator.minLength(min, error));

  ListValidatorChain<T, E> maxLength(int max, E error) => add(ListValidator.maxLength(max, error));

  ListValidatorChain<T, E> unique(E error) => add(ListValidator.unique(error));
}

// --- Generic Chain ---
class GenericValidatorChain<T, E> extends ValidatorChain<T, E, GenericValidatorChain<T, E>> {
  GenericValidatorChain<T, E> match(T other, E error) => add(ObjectValidator.match(other, error));

  GenericValidatorChain<T, E> notMatch(T other, E error) =>
      add(ObjectValidator.notMatch(other, error));
}
