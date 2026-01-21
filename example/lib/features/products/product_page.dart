import 'package:example/features/products/cubit/filter_cubit.dart';
import 'package:example/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FilterCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Product Filter')),
        drawer: const AppDrawer(),
        body: const Column(
          children: [
            _FilterHeader(),
            Divider(height: 1),
            Expanded(child: _ProductList()),
          ],
        ),
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FilterCubit>().state;
    final cubit = context.read<FilterCubit>();

    return ExpansionTile(
      title: Text('Filters (${state.filteredProducts.length} items)'),
      subtitle: state.hasActiveFilters
          ? const Text('Filters active', style: TextStyle(color: Colors.blue))
          : null,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: state.category.value,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  'Electronics',
                  'Clothing',
                  'Home',
                  'Books',
                  'Furniture',
                  'Toys',
                  'Beauty',
                  'Groceries',
                ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: cubit.categoryChanged,
              ),

              const SizedBox(height: 16),

              // Price Slider
              const Align(alignment: Alignment.centerLeft, child: Text('Price Range')),
              RangeSlider(
                values: state.priceRange.value,
                min: 0,
                max: 3000,
                divisions: 30,
                labels: RangeLabels(
                  '\$${state.priceRange.value.start.toInt()}',
                  '\$${state.priceRange.value.end.toInt()}',
                ),
                onChanged: cubit.priceChanged,
              ),

              // Stock Switch
              SwitchListTile(
                title: const Text('Only In Stock'),
                value: state.onlyInStock.value,
                onChanged: cubit.stockChanged,
                contentPadding: EdgeInsets.zero,
              ),

              // Reset
              TextButton(
                onPressed: cubit.resetFilters,
                child: const Text('Reset All'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList();

  @override
  Widget build(BuildContext context) {
    final products = context.select((FilterCubit c) => c.state.filteredProducts);

    if (products.isEmpty) {
      return const Center(child: Text('No products match your filters'));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return ListTile(
          leading: Icon(
            p.inStock ? Icons.check_circle : Icons.cancel,
            color: p.inStock ? Colors.green : Colors.grey,
          ),
          title: Text(p.name),
          subtitle: Text(p.category),
          trailing: Text('\$${p.price.toInt()}'),
        );
      },
    );
  }
}
