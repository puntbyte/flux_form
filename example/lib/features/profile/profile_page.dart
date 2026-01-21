import 'package:example/features/profile/cubit/profile_cubit.dart';
import 'package:example/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Dynamic Profile')),
        drawer: const AppDrawer(),
        body: const _ProfileView(),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    // Watch specific parts or full state
    final state = context.watch<ProfileCubit>().state;
    final cubit = context.read<ProfileCubit>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Demonstrates: Sanitization, Conditional Logic, Serialization'),
        const SizedBox(height: 20),

        TextField(
          onChanged: cubit.nameChanged,
          decoration: InputDecoration(
            labelText: 'Name (Auto-Trimmed)',
            // Updated API: errorText(status)
            errorText: state.name.displayError(state.status),
          ),
        ),
        const SizedBox(height: 16),

        CheckboxListTile(
          title: const Text('Are you employed?'),
          value: state.isEmployed.value,
          onChanged: (v) => cubit.employedChanged(v ?? false),
        ),
        const SizedBox(height: 16),

        TextField(
          onChanged: cubit.companyChanged,
          // Logic: Field enabled state can depend on the bool field
          enabled: state.isEmployed.value,
          decoration: InputDecoration(
            labelText: 'Company Name',
            errorText: state.company.displayError(state.status),
            // Logic: Helper text changes dynamically
            helperText: state.isEmployed.value ? 'Required *' : 'Optional',
          ),
        ),
        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: cubit.submit,
          child: const Text('Save Profile'),
        ),

        if (state.status.isSucceeded)
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Text(
              'Serialized JSON:\n${state.toMap}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
      ],
    );
  }
}
