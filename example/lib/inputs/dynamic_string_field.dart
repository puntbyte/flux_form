import 'package:flux_form/flux_form.dart';

/// Helper class for Ad-Hoc validation logic inside Cubits.
class DynamicStringField extends StringField {
  final List<Validator<String, String>> _validators;

  const DynamicStringField.untouched({
    super.value,
    List<Validator<String, String>> validators = const [],
  }) : _validators = validators,
       super.untouched();

  // ⚡️ FIX: Added super.remoteError here to allow passing it through
  const DynamicStringField.touched({
    super.value,
    super.remoteError,
    List<Validator<String, String>> validators = const [],
  }) : _validators = validators,
       super.touched();

  @override
  List<Validator<String, String>> get validators => _validators;

  @override
  DynamicStringField update({
    String? value,
    bool? isTouched,
    ValidationMode? mode,
    String? remoteError,
  }) {
    final shouldBeTouched = (isTouched ?? false) || this.isTouched;

    if (shouldBeTouched) {
      return DynamicStringField.touched(
        value: value ?? this.value,
        validators: _validators,
        remoteError: remoteError ?? error,
      );
    } else {
      return DynamicStringField.untouched(
        value: value ?? this.value,
        validators: _validators,
      );
    }
  }
}
