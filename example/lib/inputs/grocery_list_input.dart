import 'package:flux_form/flux_form.dart';

class GroceryListInput extends ListInput<String, String> {
  // 4. Constructors (Clean - just setting Mode)
  // We use ValidationMode.change (Live) so user sees errors immediately when adding items
  const GroceryListInput.pure({super.value}) : super.untouched(mode: ValidationMode.live);

  const GroceryListInput.dirty({super.value}) : super.touched(mode: ValidationMode.live);

  // 1. Define List-Level Rules (e.g. Min 3 items total)
  @override
  List<Validator<List<String>, String>> get validators => [
    const ListMinLengthValidator(3, 'You need at least 3 items to checkout'),
    const ListMaxLengthValidator(10, 'Too many items for express checkout'),
  ];

  // 2. Define Item-Level Rules (e.g. Each item must not be empty)
  @override
  List<Validator<String, String>> get itemValidators => [
    const RequiredValidator('Item name cannot be empty'),
  ];

  // 3. Define Item Sanitizers (e.g. Trim whitespace from items)
  @override
  List<Sanitizer<String>> get itemSanitizers => [
    const TrimSanitizer(),
  ];


  @override
  GroceryListInput update({
    List<String>? value,
    InputStatus? status,
    ValidationMode? mode,
    String? remoteError,
  }) {
    return isTouched
        ? GroceryListInput.pure(value: value ?? this.value)
        : GroceryListInput.dirty(value: value ?? this.value);
  }
}
