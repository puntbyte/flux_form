// lib/src/validation/validators/list_validator.dart

import 'package:flux_form/src/validation/validator.dart';

/// A namespace for List/Array validation rules.
abstract class ListValidator<T, E> extends Validator<List<T>, E> {
  const ListValidator(super.error);

  /// Validates that list is not empty.
  const factory ListValidator.notEmpty(E error) = _NotEmptyValidator;

  /// Validates list count is >= [min].
  const factory ListValidator.minLength(int min, E error) = _MinLengthValidator;

  /// Validates list count is <= [max].
  const factory ListValidator.maxLength(int max, E error) = _MaxLengthValidator;

  /// Validates that the list contains only unique items.
  const factory ListValidator.unique(E error) = _ListUniqueValidator;

  /// Validates that the list contains [candidate].
  const factory ListValidator.contains(T candidate, E error) = _ContainsValidator;

  /// Validates that the list contains ALL [candidates].
  const factory ListValidator.containsAll(List<T> candidates, E error) = _ContainsAllValidator;

  /// Validates that the list contains NONE of the [forbidden] items.
  const factory ListValidator.containsNone(List<T> forbidden, E error) = _ContainsNoneValidator;

  /// Validates that the list's elements all match the provided [predicate].
  const factory ListValidator.allMatch(bool Function(T) predicate, E error) = _AllMatchValidator;

  /// Validates that NO element in the list matches the provided [predicate].
  const factory ListValidator.noneMatch(bool Function(T) predicate, E error) = _NoneMatchValidator;

  /// Validates each item using a provided [itemValidator].
  /// Returns the first item error encountered. This factory is non-const because
  /// it accepts a runtime validator instance.
  factory ListValidator.every(Validator<T, E> itemValidator) = _EachItemValidator;

  /// Validates that the list has at least [minUnique] unique items.
  const factory ListValidator.minUnique(int minUnique, E error) = _MinUniqueValidator;

  /// Validates that the list has at most [maxUnique] unique items.
  const factory ListValidator.maxUnique(int maxUnique, E error) = _MaxUniqueValidator;
}

// ================= Implementation =================

class _NotEmptyValidator<T, E> extends ListValidator<T, E> {
  const _NotEmptyValidator(super.error);

  @override
  E? validate(List<T> value) => value.isEmpty ? error : null;
}

class _MinLengthValidator<T, E> extends ListValidator<T, E> {
  final int min;

  const _MinLengthValidator(this.min, super.error);

  @override
  E? validate(List<T> value) => value.length < min ? error : null;
}

class _MaxLengthValidator<T, E> extends ListValidator<T, E> {
  final int max;

  const _MaxLengthValidator(this.max, super.error);

  @override
  E? validate(List<T> value) => value.length > max ? error : null;
}

class _ListUniqueValidator<T, E> extends ListValidator<T, E> {
  const _ListUniqueValidator(super.error);

  @override
  E? validate(List<T> value) {
    if (value.isEmpty) return null;
    final uniqueSet = value.toSet();
    return uniqueSet.length == value.length ? null : error;
  }
}

class _ContainsValidator<T, E> extends ListValidator<T, E> {
  final T candidate;

  const _ContainsValidator(this.candidate, super.error);

  @override
  E? validate(List<T> value) => value.contains(candidate) ? null : error;
}

class _ContainsAllValidator<T, E> extends ListValidator<T, E> {
  final List<T> candidates;

  const _ContainsAllValidator(this.candidates, super.error);

  @override
  E? validate(List<T> value) {
    for (final c in candidates) {
      if (!value.contains(c)) return error;
    }
    return null;
  }
}

class _ContainsNoneValidator<T, E> extends ListValidator<T, E> {
  final List<T> forbidden;

  const _ContainsNoneValidator(this.forbidden, super.error);

  @override
  E? validate(List<T> value) {
    for (final f in forbidden) {
      if (value.contains(f)) return error;
    }
    return null;
  }
}

class _AllMatchValidator<T, E> extends ListValidator<T, E> {
  final bool Function(T) predicate;

  const _AllMatchValidator(this.predicate, super.error);

  @override
  E? validate(List<T> value) {
    if (value.isEmpty) return null;
    for (final item in value) {
      if (!predicate(item)) return error;
    }
    return null;
  }
}

class _NoneMatchValidator<T, E> extends ListValidator<T, E> {
  final bool Function(T) predicate;

  const _NoneMatchValidator(this.predicate, super.error);

  @override
  E? validate(List<T> value) {
    if (value.isEmpty) return null;
    for (final item in value) {
      if (predicate(item)) return error;
    }
    return null;
  }
}

class _EachItemValidator<T, E> extends ListValidator<T, E> {
  final Validator<T, E> itemValidator;

  _EachItemValidator(this.itemValidator) : super(null);

  @override
  E? validate(List<T> value) {
    if (value.isEmpty) return null;
    for (final item in value) {
      final res = itemValidator.validate(item);
      if (res != null) return res;
    }
    return null;
  }
}

class _MinUniqueValidator<T, E> extends ListValidator<T, E> {
  final int minUnique;

  const _MinUniqueValidator(this.minUnique, super.error);

  @override
  E? validate(List<T> value) {
    final unique = value.toSet().length;
    return unique < minUnique ? error : null;
  }
}

class _MaxUniqueValidator<T, E> extends ListValidator<T, E> {
  final int maxUnique;

  const _MaxUniqueValidator(this.maxUnique, super.error);

  @override
  E? validate(List<T> value) {
    final unique = value.toSet().length;
    return unique > maxUnique ? error : null;
  }
}
