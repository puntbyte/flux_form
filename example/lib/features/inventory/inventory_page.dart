// lib/features/inventory/inventory_page.dart

import 'package:example/features/inventory/cubit/inventory_cubit.dart';
import 'package:example/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InventoryCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory — ListInput · MapInput · compose'),
        ),
        drawer: const AppDrawer(),
        floatingActionButton: BlocBuilder<InventoryCubit, InventoryState>(
          builder: (ctx, _) => FloatingActionButton.extended(
            onPressed: ctx.read<InventoryCubit>().addItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ),
        body: BlocBuilder<InventoryCubit, InventoryState>(
          builder: (ctx, state) => _InventoryBody(state),
        ),
      ),
    );
  }
}

class _InventoryBody extends StatelessWidget {
  final InventoryState state;

  const _InventoryBody(this.state);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InventoryCubit>();
    final schema = state.schema;

    // Named items (non-empty) are what we render in the quantities map.
    final namedItems = schema.items.value.where((v) => v.isNotEmpty).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        const _FeatureTag(
          'ListInput · MapInput · Validator.compose · '
          'Sanitizer.compose · MapValidator · namedErrors',
        ),
        const SizedBox(height: 14),

        // ── List-level error ───────────────────────────────────────────────
        if (schema.items.displayError(state.status) != null)
          _ErrorBanner(schema.items.displayError(state.status)!),

        // ── Items section ──────────────────────────────────────────────────
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Grocery List', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'sanitized: trim → collapseWhitespace → capitalize',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              '${schema.items.value.length}/10',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...List.generate(schema.items.value.length, (i) {
          // itemErrorAt(i) — O(1) look-up from the cached validation result.
          final itemErr = schema.items.itemErrorAt(i);
          final raw = schema.items.value[i];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('item_$i'),
                    initialValue: raw,
                    onChanged: (v) => cubit.updateItem(i, v),
                    decoration: InputDecoration(
                      labelText: 'Item ${i + 1}',
                      errorText: itemErr,
                      // Show sanitized value as a hint when the item is valid.
                      helperText: itemErr == null && raw.isNotEmpty ? '✓ "$raw"' : null,
                      helperStyle: const TextStyle(color: Colors.green, fontSize: 11),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () => cubit.removeItem(i),
                ),
              ],
            ),
          );
        }),

        // ── Quantities section (MapInput) ──────────────────────────────────
        if (namedItems.isNotEmpty) ...[
          const Divider(height: 28),
          const Text('Quantities', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text(
            'MapInput: key = item name, value = quantity.\n'
            'MapValidator.notEmpty + per-value numeric validators.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          if (schema.quantities.displayError(state.status) != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                schema.quantities.displayError(state.status)!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          ...namedItems.map((item) {
            final qtyErr = schema.quantities.valueErrorAt(item);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(item, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      key: ValueKey('qty_$item'),
                      initialValue: schema.quantities.value[item] ?? '',
                      keyboardType: TextInputType.number,
                      onChanged: (v) => cubit.setQuantity(item, v),
                      decoration: InputDecoration(
                        labelText: 'Qty',
                        isDense: true,
                        errorText: qtyErr,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 20),

        // ── namedErrors debug panel ────────────────────────────────────────
        // namedErrors returns {fieldKey: error} only for invalid inputs.
        // Useful for server-side error mapping and summary widgets.
        if (state.status.isFailure && schema.namedErrors.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'schema.namedErrors:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${schema.namedErrors}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        ElevatedButton(
          onPressed: cubit.checkout,
          child: const Text('Validate & Checkout'),
        ),

        if (state.status.isSuccess) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✓ Checked out!',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('${schema.values}', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          TextButton(
            onPressed: cubit.reset,
            child: const Text('Reset'),
          ),
        ],
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(10),
    color: Colors.red.shade50,
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ),
      ],
    ),
  );
}

class _FeatureTag extends StatelessWidget {
  final String text;

  const _FeatureTag(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, color: Colors.green.shade800),
    ),
  );
}
