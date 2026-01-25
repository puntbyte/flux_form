import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:example/features/search/inputs/search_input.dart';
import 'package:example/models/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  Timer? _debounce;

  SearchCubit() : super(const SearchState());

  void searchChanged(String query) {
    // 1. Update Input (Runs Sanitizers + Validators immediately)
    // We use .replaceValue because user interaction implies touched.
    final input = state.searchBar.replaceValue(query) as SearchInput;

    emit(state.copyWith(searchBar: input));

    // 2. Cancel previous pending search
    _debounce?.cancel();

    // 3. Logic: Only search if valid AND not empty
    if (input.isValid && input.value.isNotEmpty) {
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        await _performSearch(input.value);
      });
    } else {
      // Clear results if invalid or empty
      emit(state.copyWith(results: [], isSearching: false));
    }
  }

  Future<void> _performSearch(String query) async {
    if (isClosed) return;
    emit(state.copyWith(isSearching: true));

    try {
      // Simulate API Network Delay
      await Future.delayed(const Duration(seconds: 1));

      final lowerQuery = query.toLowerCase();

      // Complex Filter Logic
      final results = _mockDb.where((product) {
        return product.name.toLowerCase().contains(lowerQuery) ||
            product.category.toLowerCase().contains(lowerQuery);
      }).toList();

      if (isClosed) return;

      if (results.isEmpty) {
        // Option: We can treat "No Results" as a Field Error if we want the red text,
        // or just empty state. Let's do empty state for better UX.
        emit(state.copyWith(results: [], isSearching: false));
      } else {
        emit(state.copyWith(results: results, isSearching: false));
      }
    } catch (e) {
      if (isClosed) return;
      // Inject API Error into the field
      emit(
        state.copyWith(
          isSearching: false,
          searchBar: state.searchBar.update(remoteError: 'Network Error: $e'),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

// Robust Mock Data
const List<Product> _mockDb = [
  Product(id: '1', name: 'MacBook Pro', category: 'Electronics', price: 1999),
  Product(id: '2', name: 'iPad Air', category: 'Electronics', price: 599),
  Product(id: '3', name: 'Organic Banana', category: 'Groceries', price: 1.20),
  Product(id: '4', name: 'Running Shoes', category: 'Apparel', price: 89),
  Product(id: '5', name: 'Coffee Maker', category: 'Home', price: 45),
  Product(id: '6', name: 'Gaming Mouse', category: 'Electronics', price: 70),
  Product(id: '7', name: 'Cotton T-Shirt', category: 'Apparel', price: 15),
];
