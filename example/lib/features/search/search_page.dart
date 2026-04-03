// lib/features/search/search_page.dart

import 'package:example/features/search/cubit/search_cubit.dart';
import 'package:example/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search — Debouncer · runAsync · Parallel'),
        ),
        drawer: const AppDrawer(),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (ctx, state) => _SearchBody(state),
        ),
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  final SearchState state;
  const _SearchBody(this.state);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _FeatureTag(
          'Debouncer · runAsync · runBuiltInAsyncValidation · '
              'validateAsyncParallel · blur mode',
        ),
        const SizedBox(height: 20),

        // ── Product search — live + debounced ──────────────────────────────
        const Text('Product Search',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          onChanged: cubit.searchChanged,
          decoration: InputDecoration(
            labelText: 'Search products…',
            helperText:
            'Debouncer: API fires 450 ms after you stop typing',
            prefixIcon: state.isSearching
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : const Icon(Icons.search),
            errorText: state.searchBar.displayError(SubmissionStatus.idle),
          ),
        ),
        if (state.results.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...state.results.map(
                (r) => ListTile(
              dense: true,
              leading: const Icon(Icons.inventory_2_outlined, size: 18),
              title: Text(r),
            ),
          ),
        ] else if (state.searchBar.value.length >= 2 && !state.isSearching) ...[
          const SizedBox(height: 8),
          const Text('No results found.',
              style: TextStyle(color: Colors.grey)),
        ],

        const Divider(height: 40),

        // ── Username — blur mode + runAsync ────────────────────────────────
        const Text('Username Availability',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const Text(
          'blur mode: error shows only after leaving the field.\n'
              'Try: admin, root, flux, test (taken) or spam (banned).',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: cubit.usernameChanged,
          onEditingComplete: cubit.usernameBlurred, // ← blur trigger
          decoration: InputDecoration(
            labelText: 'Username',
            helperText: state.username.isValidating
                ? 'Checking availability…'
                : 'runAsync: markValidating → await task → resolveAsyncValidation',
            suffixIcon: state.username.isValidating
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : state.username.isValid && state.username.isTouched
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            // displayError respects blur mode — hidden until touched.
            errorText: state.username
                .displayError(SubmissionStatus.idle)
                ?.message(),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: cubit.usernameBlurred,
              child: const Text('Trigger blur'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: cubit.checkViaBuiltIn,
              child: const Text('runBuiltInAsync'),
            ),
          ),
        ]),

        const Divider(height: 40),

        // ── Parallel async validation ───────────────────────────────────────
        const Text('Parallel Async Validation',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const Text(
          'validateAsyncParallel fires both validators simultaneously.\n'
              'Results are returned in declaration order, not completion order.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: state.parallelRunning ? null : cubit.runParallel,
          child: state.parallelRunning
              ? const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 8),
              Text('Running both in parallel…'),
            ],
          )
              : const Text('Run validateAsyncParallel()'),
        ),
        if (state.parallelResult.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: state.parallelResult.startsWith('✓')
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              state.parallelResult,
              style: TextStyle(
                color: state.parallelResult.startsWith('✓')
                    ? Colors.green.shade800
                    : Colors.red.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeatureTag extends StatelessWidget {
  final String text;
  const _FeatureTag(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.indigo.shade50,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, color: Colors.indigo.shade700),
    ),
  );
}