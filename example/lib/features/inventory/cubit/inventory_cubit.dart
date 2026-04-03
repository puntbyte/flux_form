// lib/features/inventory/cubit/inventory_cubit.dart

import 'package:example/features/inventory/forms/inventory_schema.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit() : super(InventoryState.initial());

  // ── List mutations ─────────────────────────────────────────────────────────

  void addItem() => _update((s) => s.copyWith(items: s.items.addItem('')));

  void updateItem(int index, String value) =>
      _update((s) => s.copyWith(items: s.items.setItem(index, value)));

  void removeItem(int index) => _update((s) => s.copyWith(items: s.items.removeItemAt(index)));

  // ── Map mutations ──────────────────────────────────────────────────────────
  // FIX: _update passes an InventorySchema directly — not an InventoryState.
  // Use s.quantities, not s.schema.quantities.

  void setQuantity(String itemName, String qty) => _update(
    (s) => s.copyWith(quantities: s.quantities.putItem(itemName, qty)),
  );

  void removeQuantity(String itemName) => _update(
    (s) => s.copyWith(quantities: s.quantities.removeItem(itemName)),
  );

  // ── Submit ─────────────────────────────────────────────────────────────────

  void checkout() {
    final (touched, isValid) = state.schema.validate();
    emit(
      state.copyWith(
        schema: touched as InventorySchema,
        status: isValid ? SubmissionStatus.success : SubmissionStatus.failure,
      ),
    );
  }

  void reset() => emit(InventoryState.initial());

  // ── Internal ───────────────────────────────────────────────────────────────
  // _update receives InventorySchema (the domain object), not InventoryState.
  // This keeps mutation lambdas concise: (s) => s.copyWith(items: ...).

  void _update(InventorySchema Function(InventorySchema) fn) => emit(
    state.copyWith(schema: fn(state.schema), status: SubmissionStatus.idle),
  );
}
