part of 'search_cubit.dart';

class SearchState extends Equatable with FormMixin {
  final SearchInput searchBar;
  final FormStatus status;
  final List<Product> results;
  final bool isSearching;

  const SearchState({
    SearchInput? searchBar,
    this.status = FormStatus.initial,
    this.results = const [],
    this.isSearching = false,
  }) : searchBar = searchBar ?? const SearchInput.untouched();

  @override
  List<FormInput<dynamic, dynamic>> get inputs => [searchBar];

  SearchState copyWith({
    SearchInput? searchBar,
    FormStatus? status,
    List<Product>? results,
    bool? isSearching,
  }) => SearchState(
    searchBar: searchBar ?? this.searchBar,
    status: status ?? this.status,
    results: results ?? this.results,
    isSearching: isSearching ?? this.isSearching,
  );

  @override
  List<Object> get props => [searchBar, status, results, isSearching];
}
