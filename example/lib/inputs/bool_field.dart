import 'package:flux_form/flux_form.dart';

/// A simple field for Checkboxes/Switches
class BoolField extends FormInput<bool, String> with InputMixin<bool, String, BoolField> {
  const BoolField.untouched({super.value = false}) : super.untouched();

  const BoolField.touched({super.value = false}) : super.touched();

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
