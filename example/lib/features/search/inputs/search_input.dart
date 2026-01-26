import 'package:flux_form/flux_form.dart';

/// A specialized input for Search logic.
/// Demonstrates Composition: We define rules/sanitizers via getters.
class SearchInput extends StringInputBase<String> with InputMixin<String, String, SearchInput> {
  const SearchInput.untouched({super.value}) : super.untouched();

  const SearchInput.touched({
    super.value,
    super.initialValue,
    super.remoteError,
  }) : super.touched();

  // 1. Sanitization: Automatically remove leading/trailing spaces
  @override
  List<Sanitizer<String>> get sanitizers => [
    const TrimSanitizer(),
  ];

  // 2. Validation: Ensure user types enough characters
  @override
  List<Validator<String, String>> get validators => [
    const MinLengthValidator(2, 'Type at least 2 characters'),
  ];

  @override
  SearchInput update({
    String? value,
    InputStatus? status,
    ValidationMode? mode,
    String? remoteError,
  }) {
    final data = prepareUpdate(
      value: value,
      status: .touched,
      mode: mode,
      remoteError: remoteError,
    );

    return switch(data.status) {
      InputStatus.touched => SearchInput.touched(
        value: data.value,
        initialValue: data.initialValue,
        remoteError: data.remoteError,
      ),

      InputStatus.untouched => SearchInput.untouched(value: data.value),
      // TODO: Handle this case.
      InputStatus.validating => throw UnimplementedError(),
    };
  }
}
