// lib/features/inventory/forms/inventory_schema.dart
//
// Demonstrates:
//   • ListInput (renamed from SimpleListInput) — constructor-based validators
//   • Validator.compose — named, reusable rule pipeline
//   • Sanitizer.compose — named, reusable sanitizer pipeline
//   • SimpleMapInput + MapValidator — key-value collection with named rules
//   • FormSchema.namedErrors — {fieldKey: error} for all invalid inputs

import 'package:flux_form/flux_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared composed rules
//
// Validator.compose bundles multiple validators into one named object.
// Drop it into itemValidators or any input's validators list directly.
// Sanitizer.compose does the same for sanitizers.
// ─────────────────────────────────────────────────────────────────────────────

/// Shared item-level validator — used by ListInput.itemValidators.
/// Named once, reusable anywhere (e.g., server-side mirror validation).
final Validator<String, String> itemRules = Validator.compose<String, String>([
  const StringValidator.required('Item name cannot be empty'),
  const StringValidator.maxLength(40, 'Name too long (max 40 chars)'),
]);

/// Shared item-level sanitizer pipeline.
/// trim → collapseWhitespace → capitalize
/// "  organic  milk  " → "Organic milk"
final Sanitizer<String> itemSanitizers = Sanitizer.compose<String>([
  const StringSanitizer.trim(),
  const StringSanitizer.collapseWhitespace(),
  const StringSanitizer.capitalize(),
]);

// ─────────────────────────────────────────────────────────────────────────────
// Schema
// ─────────────────────────────────────────────────────────────────────────────

class InventorySchema extends FormSchema {
  /// ListInput — the renamed concrete list type (was SimpleListInput).
  ///
  /// All list-level and item-level validators/sanitizers passed via
  /// constructor — no subclassing needed for this one-off field.
  final SimpleListInput<String, String> items;

  /// SimpleMapInput — a key-value collection where the key is an item name
  /// and the value is the quantity as a string.
  ///
  /// MapValidator.notEmpty applied at map level.
  /// Per-value validators ensure each quantity is a positive number.
  final SimpleMapInput<String, String, String> quantities;

  InventorySchema({
    SimpleListInput<String, String>? items,
    SimpleMapInput<String, String, String>? quantities,
  }) : items =
           items ??
           SimpleListInput.untouched(
             // List-level validators: structure rules for the whole list.
             validators: const [
               ListValidator.minLength(3, 'Add at least 3 items to checkout'),
               ListValidator.maxLength(10, 'Maximum 10 items at once'),
             ],
             // Item-level validators: applied to each item individually.
             // Validator.compose used here — one entry, many rules.
             itemValidators: [itemRules],
             // Item-level sanitizers: run on each item before storage.
             // Sanitizer.compose used here — one entry, full pipeline.
             itemSanitizers: [itemSanitizers],
           ),
       quantities =
           quantities ??
           const SimpleMapInput.untouched(
             // MapValidator at map level: the whole map must have entries.
             validators: [
               MapValidator<String, String, String>.notEmpty('Enter at least one quantity'),
             ],
             // Per-value validators: each quantity must be a positive number.
             valueValidators: [
               StringValidator.isNumeric('Must be a number'),
               StringValidator.numericMin(1, 'Must be at least 1'),
             ],
           );

  @override
  Map<String, FormInput<dynamic, dynamic>> get namedInputs => {
    'items': items,
    'quantities': quantities,
  };

  InventorySchema copyWith({
    SimpleListInput<String, String>? items,
    SimpleMapInput<String, String, String>? quantities,
  }) => InventorySchema(
    items: items ?? this.items,
    quantities: quantities ?? this.quantities,
  );

  @override
  InventorySchema touchAll() => copyWith(
    items: items.markTouched(),
    quantities: quantities.markTouched(),
  );

  @override
  InventorySchema reset() => InventorySchema();
}
