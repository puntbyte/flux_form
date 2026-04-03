// lib/features/search/cubit/search_cubit.dart
//
// Debouncing done with dart:async Timer — the standard Dart approach with
// zero extra dependencies. Replace Timer with rxdart Subject.debounceTime,
// easy_debounce.EasyDebounce.debounce, or any other package without changing
// any flux_form call. runAsync is completely scheduling-agnostic.

import 'dart:async';

import 'package:example/errors/auth_error.dart';
import 'package:example/features/search/inputs/search_input.dart';
import 'package:example/inputs/shared_inputs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'search_state.dart';

class _AvailabilityCheck extends AsyncValidator<String, String> {
  const _AvailabilityCheck() : super(null);
  static const _taken = {'admin', 'root', 'flux', 'test'};

  @override
  Future<String?> validate(String value) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _taken.contains(value.toLowerCase()) ? 'Username is taken' : null;
  }
}

class _BannedWordsCheck extends AsyncValidator<String, String> {
  const _BannedWordsCheck() : super(null);
  static const _banned = {'spam', 'abuse', 'hate'};

  @override
  Future<String?> validate(String value) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _banned.contains(value.toLowerCase()) ? 'Username contains a banned word' : null;
  }
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  // dart:async Timer — cancel + restart on each keystroke = debounce.
  // Swap for rxdart / easy_debounce / stream_transform without touching
  // any flux_form API.
  Timer? _searchTimer;
  Timer? _usernameTimer;

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    _usernameTimer?.cancel();
    return super.close();
  }

  // ── Product search ─────────────────────────────────────────────────────────

  void searchChanged(String query) {
    final input = state.searchBar.replaceValue(query);
    emit(state.copyWith(searchBar: input, results: []));

    _searchTimer?.cancel();
    if (!input.isValid || input.value.isEmpty) return;

    _searchTimer = Timer(const Duration(milliseconds: 450), () async {
      if (isClosed) return;
      emit(state.copyWith(isSearching: true));
      await Future.delayed(const Duration(milliseconds: 500));
      if (isClosed) return;
      final q = input.value.toLowerCase();
      final results = _mockDb.where((p) => p.toLowerCase().contains(q)).toList();
      emit(state.copyWith(results: results, isSearching: false));
    });
  }

  // ── Username — blur mode + runAsync ───────────────────────────────────────

  void usernameChanged(String v) {
    // Blur mode: setValue — value updates, field stays untouched.
    emit(state.copyWith(username: state.username.setValue(v)));
  }

  Future<void> usernameBlurred() async {
    final touched = state.username.markTouched();
    emit(state.copyWith(username: touched));
    if (!touched.isValid) return;

    _usernameTimer?.cancel();
    _usernameTimer = Timer(const Duration(milliseconds: 600), () async {
      if (isClosed) return;
      // runAsync is the flux_form lifecycle helper. The Timer above is the
      // debounce mechanism — these two concerns are fully independent.
      final resolved = await state.username.runAsync(
        task: () async {
          await Future.delayed(const Duration(milliseconds: 600));
          const taken = {'admin', 'root', 'flux', 'test'};
          // Return AuthError? — must match UsernameInput's error type E.
          return taken.contains(state.username.value.toLowerCase())
              ? AuthError.usernameTaken
              : null;
        },
        onValidating: (v) => emit(state.copyWith(username: v)),
      );
      if (!isClosed) emit(state.copyWith(username: resolved));
    });
  }

  Future<void> checkViaBuiltIn() async {
    if (!state.username.isValid) return;
    _usernameTimer?.cancel();
    _usernameTimer = Timer(const Duration(milliseconds: 600), () async {
      if (isClosed) return;
      // runBuiltInAsyncValidation delegates to UsernameInput.asyncValidators.
      final resolved = await state.username.runBuiltInAsyncValidation(
        onValidating: (v) => emit(state.copyWith(username: v)),
      );
      if (!isClosed) emit(state.copyWith(username: resolved));
    });
  }

  // ── Parallel async validation ─────────────────────────────────────────────

  Future<void> runParallel() async {
    if (state.username.value.isEmpty) return;
    emit(state.copyWith(parallelRunning: true, parallelResult: ''));
    final error = await ValidatorPipeline.validateAsyncParallel<String, String>(
      state.username.value,
      [const _AvailabilityCheck(), const _BannedWordsCheck()],
    );
    emit(
      state.copyWith(
        parallelRunning: false,
        parallelResult: error ?? '✓ All parallel async validators passed',
      ),
    );
  }
}

const _mockDb = [
  'MacBook Pro',
  'iPad Air',
  'iPhone 15',
  'AirPods Pro',
  'Samsung Galaxy S24',
  'Google Pixel 8',
  'Organic Banana',
  'Almond Milk',
  'Greek Yogurt',
  'Running Shoes',
  'Yoga Mat',
  'Dumbbell Set',
  'Coffee Maker',
  'Toaster Oven',
  'Blender',
  'Flutter Book',
  'Dart in Action',
  'Clean Code',
];
