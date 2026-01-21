import 'package:flux_form/flux_form.dart';

/// A simple field for Checkboxes/Switches
class BoolField extends Field<bool, String> {
  const BoolField.untouched({bool value = false}) : super.untouched(value);

  const BoolField.touched({bool value = false}) : super.touched(value);

  @override
  Field<bool, String> copyWith({
    bool? value,
    bool? isTouched,
    ValidationMode? mode,
    String? remoteError,
  }) {
    return isTouched ?? false
        ? BoolField.touched(value: value ?? this.value)
        : BoolField.untouched(value: value ?? this.value);
  }

  // Add logic here if you need to enforce "Must be true" (e.g. Terms of Service)
  @override
  String? validate(bool value) => null;
}
