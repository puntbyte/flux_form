import 'package:example/features/search/cubit/search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Async Search')),
        body: const _SearchView(),
      ),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SearchCubit>().state;
    final cubit = context.read<SearchCubit>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            onChanged: cubit.searchChanged,
            decoration: InputDecoration(
              labelText: 'Search Fruits (min 3 chars)',
              hintText: 'e.g. App',
              suffixIcon: SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: state.isSearching
                      ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.search),
                ),
              ),
              errorText: state.searchBar.displayError(state.status),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: state.results.isEmpty && state.searchBar.isValid && !state.isSearching
                ? const Center(
                    child: Text('No results', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.food_bank),
                        title: Text(state.results[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
