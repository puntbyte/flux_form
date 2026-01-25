import 'package:flutter/material.dart';
import 'package:flux_form/flux_form.dart';

/// A field for selecting a category (String value, nullable).
class CategoryField extends FormInput<String?, String>
    with InputMixin<String?, String, CategoryField> {
  const CategoryField.untouched({String? value}) : super.untouched(value);

  const CategoryField.touched({String? value}) : super.touched(value);

  @override
  CategoryField update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    String? remoteError,
  }) {
    return isTouched
        ? CategoryField.touched(value: value ?? this.value)
        : CategoryField.untouched(value: value ?? this.value);
  }
}

/// A field for price range (RangeValues).
class PriceRangeField extends FormInput<RangeValues, String>
    with InputMixin<RangeValues, String, PriceRangeField> {
  // Default range: 0 to 1000
  const PriceRangeField.untouched({RangeValues value = const RangeValues(0, 1000)})
    : super.untouched(value);

  const PriceRangeField.touched({RangeValues value = const RangeValues(0, 1000)})
    : super.touched(value);

  @override
  String? validate(RangeValues value) {
    if (value.start < 0) return 'Price cannot be negative';
    return null;
  }

  @override
  PriceRangeField update({
    RangeValues? value,
    InputStatus? status,
    ValidationMode? mode,
    String? remoteError,
  }) {
    return isTouched
        ? PriceRangeField.touched(value: value ?? this.value)
        : PriceRangeField.untouched(value: value ?? this.value);
  }
}
