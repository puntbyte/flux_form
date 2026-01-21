part of 'filter_cubit.dart';

// Dummy Product Model
class Product {
  final String name;
  final String category;
  final double price;
  final bool inStock;
  const Product(this.name, this.category, this.price, this.inStock);
}

class FilterState extends Equatable with FormMixin {
  // Fields
  final CategoryField category;
  final PriceRangeField priceRange;
  final BoolField onlyInStock; // Reusing BoolField from previous examples

  // Data
  final List<Product> allProducts;
  final List<Product> filteredProducts;

  const FilterState({
    CategoryField? category,
    PriceRangeField? priceRange,
    BoolField? onlyInStock,
    this.allProducts = const [],
    List<Product>? filteredProducts,
  })  : category = category ?? const CategoryField.untouched(),
        priceRange = priceRange ?? const PriceRangeField.untouched(),
        onlyInStock = onlyInStock ?? const BoolField.untouched(),
        filteredProducts = filteredProducts ?? allProducts;

  @override
  List<Field> get fields => [category, priceRange, onlyInStock];

  // Helper to check if any filter is active
  bool get hasActiveFilters =>
      category.value != null ||
          onlyInStock.value == true ||
          priceRange.value.end < 1000;

  FilterState copyWith({
    CategoryField? category,
    PriceRangeField? priceRange,
    BoolField? onlyInStock,
    List<Product>? filteredProducts,
  }) {
    return FilterState(
      category: category ?? this.category,
      priceRange: priceRange ?? this.priceRange,
      onlyInStock: onlyInStock ?? this.onlyInStock,
      allProducts: this.allProducts, // Keep original list
      filteredProducts: filteredProducts ?? this.filteredProducts,
    );
  }

  @override
  List<Object?> get props => [category, priceRange, onlyInStock, filteredProducts];
}