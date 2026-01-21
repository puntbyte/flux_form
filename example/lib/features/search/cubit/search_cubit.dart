import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:example/inputs/dynamic_string_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  Timer? _debounce;

  SearchCubit() : super(SearchState());

  void searchChanged(String query) {
    // 1. Update UI immediately (show text typing)
    final input = DynamicStringField.touched(
      value: query,
      validators: const [
        MinLengthValidator(3, 'Type at least 3 chars'),
      ],
    );

    emit(state.copyWith(searchBar: input));

    // 2. Debounce the Async Call
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Only search if client-side validation passes
    if (input.isValid) {
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        await _performSearch(query);
      });
    } else {
      emit(state.copyWith(results: [], isSearching: false));
    }
  }

  Future<void> _performSearch(String query) async {
    emit(state.copyWith(isSearching: true));

    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockDb = ['Apple', 'Apricot', 'Banana', 'Blueberry', 'Cherry', 'Date'];
      final results = mockDb
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (results.isEmpty) {
        emit(state.copyWith(results: [], isSearching: false));
      } else {
        emit(state.copyWith(results: results, isSearching: false));
      }
    } catch (e) {
      // Apply the remote error to the existing field
      emit(
        state.copyWith(
          isSearching: false,
          searchBar: state.searchBar.copyWith(remoteError: 'API Error: $e'),
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
