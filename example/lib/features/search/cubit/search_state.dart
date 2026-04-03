// lib/features/search/cubit/search_state.dart

part of 'search_cubit.dart';

class SearchState {
  final SearchInput searchBar;
  final UsernameInput username;
  final List<String> results;
  final bool isSearching;
  final bool parallelRunning;
  final String parallelResult;

  const SearchState({
    SearchInput? searchBar,
    UsernameInput? username,
    this.results = const [],
    this.isSearching = false,
    this.parallelRunning = false,
    this.parallelResult = '',
  }) : searchBar = searchBar ?? const SearchInput.untouched(),
       username = username ?? const UsernameInput.untouched();

  SearchState copyWith({
    SearchInput? searchBar,
    UsernameInput? username,
    List<String>? results,
    bool? isSearching,
    bool? parallelRunning,
    String? parallelResult,
  }) => SearchState(
    searchBar: searchBar ?? this.searchBar,
    username: username ?? this.username,
    results: results ?? this.results,
    isSearching: isSearching ?? this.isSearching,
    parallelRunning: parallelRunning ?? this.parallelRunning,
    parallelResult: parallelResult ?? this.parallelResult,
  );
}
