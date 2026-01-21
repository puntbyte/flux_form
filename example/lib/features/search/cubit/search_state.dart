part of 'search_cubit.dart';

class SearchState extends Equatable with FormMixin {
  final StringField searchBar;
  final FormStatus status;
  final List<String> results;

  // Custom status for the search bar specifically
  final bool isSearching;

  SearchState({
    StringField? searchBar,
    this.status = FormStatus.initial,
    this.results = const [],
    this.isSearching = false,
  }) : searchBar = searchBar ?? const StringField.untouched();

  @override
  List<Field<dynamic, String>> get fields => [searchBar];

  SearchState copyWith({
    StringField? searchBar,
    FormStatus? status,
    List<String>? results,
    bool? isSearching,
  }) {
    return SearchState(
      searchBar: searchBar ?? this.searchBar,
      status: status ?? this.status,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object> get props => [searchBar, status, results, isSearching];
}
