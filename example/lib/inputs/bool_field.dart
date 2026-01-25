import 'package:flux_form/flux_form.dart';

/// A simple field for Checkboxes/Switches
class BoolField extends FormInput<bool, String> with InputMixin<bool, String, BoolField> {
  const BoolField.untouched({bool value = false}) : super.untouched(value);

  const BoolField.touched({bool value = false}) : super.touched(value);

  @override
  FormInput<bool, String> update({
    bool? value,
    InputStatus? status,
    ValidationMode? mode,
    String? remoteError,
  }) {
    return isTouched
        ? BoolField.touched(value: value ?? this.value)
        : BoolField.untouched(value: value ?? this.value);
  }
}
