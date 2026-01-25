import 'package:example/features/search/cubit/search_cubit.dart';
import 'package:example/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Product Search')),
        drawer: const AppDrawer(),
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

    // Resolve the error message based on the FluxForm mode
    final errorMsg = state.searchBar.displayError(state.status);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Flutter SearchBar
          _buildSearchBar(cubit, state, errorMsg),

          // 2. Custom Error Display (Since SearchBar doesn't have errorText)
          if (errorMsg != null) _buildError(errorMsg, context),

          const SizedBox(height: 20),

          // 3. Results List
          Expanded(child: _buildResults(state)),
        ],
      ),
    );
  }

  Padding _buildError(String errorMsg, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16),
      child: Text(
        errorMsg,
        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
      ),
    );
  }

  Widget _buildSearchBar(SearchCubit cubit, SearchState state, String? errorMsg) {
    return SearchBar(
      hintText: 'Search products...',
      leading: const Icon(Icons.search),
      onChanged: cubit.searchChanged,
      // Show spinner inside the bar
      trailing: state.isSearching
          ? [
              const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ]
          : null,
      // Visual feedback for error state
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (errorMsg != null) return Colors.red.shade50;
        return null;
      }),
    );
  }

  Widget _buildResults(SearchState state) {
    if (state.results.isEmpty) {
      if (state.searchBar.value.isEmpty) {
        return const Center(child: Text('Start typing to search...'));
      }
      if (state.searchBar.isValid && !state.isSearching) {
        return const Center(child: Text('No products found.'));
      }
      return const SizedBox.shrink();
    }

    return ListView.separated(
      itemCount: state.results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = state.results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(product.name[0]),
          ),
          title: Text(product.name),
          subtitle: Text(product.category),
          trailing: Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        );
      },
    );
  }
}
