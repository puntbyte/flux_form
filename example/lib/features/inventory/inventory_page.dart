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
        appBar: AppBar(title: const Text('Inventory (List Input)')),
        drawer: const AppDrawer(),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () => context.read<InventoryCubit>().addItem(),
              child: const Icon(Icons.add),
            );
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Overall List Error (using resolveFault)
                  if (state.groceries.displayError(state.status) != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red.withAlpha(32),
                      child: Text(
                        // Force unwrap because we checked null above
                        state.groceries.displayError(state.status)!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),

                  const SizedBox(height: 10),

                  // 2. The List Items
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.groceries.value.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final itemValue = state.groceries.value[index];
                        // 3. Specific Item Error (String?)
                        final itemError = state.groceries.getItemError(index);

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: ValueKey(index), // Important for lists
                                initialValue: itemValue,
                                decoration: InputDecoration(
                                  labelText: 'Item ${index + 1}',
                                  border: const OutlineInputBorder(),
                                  errorText: itemError, // Pass String? directly
                                ),
                                onChanged: (val) =>
                                    context.read<InventoryCubit>().updateItem(index, val),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () => context.read<InventoryCubit>().removeItem(index),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // 4. Submit Button
                  ElevatedButton(
                    onPressed: state.isValid ? () {} : null,
                    child: Text(state.isValid ? 'Checkout' : 'Invalid List'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
