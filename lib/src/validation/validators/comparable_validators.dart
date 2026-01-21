// lib/src/rules/comparable_validators.dart

import 'package:flux_form/src/validation/validator.dart';

class GreaterThanValidator<T extends Comparable<T>, E> extends Validator<T, E> {
  final T other;

  const GreaterThanValidator(this.other, super.error);

  @override
  E? validate(T value) => value.compareTo(other) > 0 ? null : error;
}

class LessThanValidator<T extends Comparable<T>, E> extends Validator<T, E> {
  final T other;

  const LessThanValidator(this.other, super.error);

  @override
  E? validate(T value) => value.compareTo(other) < 0 ? null : error;
}

class MinValueValidator<T extends Comparable<T>, E> extends Validator<T, E> {
  final T other;

  const MinValueValidator(this.other, super.error);

  @override
  E? validate(T value) => value.compareTo(other) >= 0 ? null : error;
}

class MaxValueValidator<T extends Comparable<T>, E> extends Validator<T, E> {
  final T other;

  const MaxValueValidator(this.other, super.error);

  @override
  E? validate(T value) => value.compareTo(other) <= 0 ? null : error;
}
