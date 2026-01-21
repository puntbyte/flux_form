import 'package:equatable/equatable.dart';
import 'package:example/inputs/bool_field.dart';
import 'package:example/inputs/filter_fields.dart';
import 'package:flutter/material.dart'; // For RangeValues
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit()
    : super(
        FilterState(allProducts: _products),
      );

  void categoryChanged(String? value) {
    final field = state.category.update(value: value, isTouched: true);
    // Apply filters immediately on change
    _applyFilters(state.copyWith(category: field));
  }

  void priceChanged(RangeValues value) {
    final field = state.priceRange.update(value: value, isTouched: true);
    _applyFilters(state.copyWith(priceRange: field));
  }

  void stockChanged(bool value) {
    final field = state.onlyInStock.update(value: value, isTouched: true) as BoolField;
    _applyFilters(state.copyWith(onlyInStock: field));
  }

  void resetFilters() {
    emit(FilterState(allProducts: state.allProducts));
  }

  void _applyFilters(FilterState newState) {
    final result = newState.allProducts.where((p) {
      // 1. Category Check
      if (newState.category.value != null && newState.category.value != p.category) {
        return false;
      }
      // 2. Stock Check
      if (newState.onlyInStock.value && !p.inStock) {
        return false;
      }
      // 3. Price Check
      if (p.price < newState.priceRange.value.start || p.price > newState.priceRange.value.end) {
        return false;
      }
      return true;
    }).toList();

    emit(newState.copyWith(filteredProducts: result));
  }
}

final _products = <Product>[
  // Electronics (5 items)
  const Product('MacBook Pro', 'Electronics', 2500, true),
  const Product('Asus Gaming PC', 'Electronics', 1500, false),
  const Product('iPhone 15', 'Electronics', 1200, true),
  const Product('Samsung Galaxy Tab S8', 'Electronics', 799, true),
  const Product('Sony WH-1000XM5 Headphones', 'Electronics', 350, false),

  // Clothing (4 items)
  const Product('Nike Shoes', 'Clothing', 120, true),
  const Product('T-Shirt', 'Clothing', 25, false),
  const Product('Jeans', 'Clothing', 50, true),
  const Product('Hoodie', 'Clothing', 40, true),

  // Home (3 items)
  const Product('Coffee Maker', 'Home', 85, false),
  const Product('Blender', 'Home', 45, true),
  const Product('Microwave Oven', 'Home', 100, false),

  // Books (4 items)
  const Product('The Great Gatsby', 'Books', 15, true),
  const Product('1984', 'Books', 10, true),
  const Product('The Catcher in the Rye', 'Books', 12, false),
  const Product('The Hobbit', 'Books', 14, true),

  // Furniture (3 items)
  const Product('Sofa', 'Furniture', 500, true),
  const Product('Bookshelf', 'Furniture', 150, false),
  const Product('Chairs', 'Furniture', 75, true),

  // Toys (4 items)
  const Product('LEGO Set', 'Toys', 50, true),
  const Product('Barbie Doll', 'Toys', 20, false),
  const Product('Remote Control Car', 'Toys', 40, true),
  const Product('Action Figures', 'Toys', 25, false),

  // Beauty (3 items)
  const Product('Lipstick', 'Beauty', 15, true),
  const Product('Foundation', 'Beauty', 25, false),
  const Product('Skincare Set', 'Beauty', 40, true),

  // Groceries (7 items)
  const Product('Milk', 'Groceries', 2, true),
  const Product('Bread', 'Groceries', 3, false),
  const Product('Eggs', 'Groceries', 4, true),
  const Product('Greek Yogurt', 'Groceries', 4, true),
  const Product('Organic Chicken Breast', 'Groceries', 9, true),
  const Product('Extra Virgin Olive Oil', 'Groceries', 12, true),
  const Product('Ground Coffee', 'Groceries', 8, false),
]..shuffle();
