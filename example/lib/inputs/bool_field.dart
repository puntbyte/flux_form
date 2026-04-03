import 'package:flux_form/flux_form.dart';

/// A simple field for Checkboxes/Switches
class BoolField extends FormInput<bool, String> with InputMixin<bool, String, BoolField> {
  const BoolField.untouched({super.value = false}) : super.untouched();

  const BoolField.touched({super.value = false}) : super.touched();

  @override
  BoolField update({
    bool? value,
    InputStatus? status,
    ValidationMode? mode,
    String? remoteError,
  }) {
    // Respect the incoming status so that replaceValue() correctly transitions
    // an untouched field to touched on first interaction.
    final effectiveStatus = status ?? this.status;
    return effectiveStatus == InputStatus.untouched
        ? BoolField.untouched(value: value ?? this.value)
        : BoolField.touched(value: value ?? this.value);
  }
}