import 'package:example/features/login/cubit/login_cubit.dart';
import 'package:example/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Login Demo')),
        drawer: const AppDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state.status.isSucceeded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login Success!')),
                );
              }
            },

            builder: (context, state) => _buildContent(state, context),
          ),
        ),
      ),
    );
  }

  Column _buildContent(LoginState state, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        const Text('Email: Submit Mode (Error shows on click)'),

        _buildEmailField(state, context),

        const SizedBox(height: 16),

        const Text('Password: Live Mode (Error shows while typing)'),

        buildPasswordField(state, context),

        const SizedBox(height: 24),

        if (state.status.isSubmitting)
          const Center(child: CircularProgressIndicator())
        else
          _buildSubmitButton(state, context),
      ],
    );
  }

  Widget _buildEmailField(LoginState state, BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        // resolveFault handles the logic:
        // - Submit Mode: Returns null until status is Failed.
        errorText: state.email.displayError(state.status),
      ),
      onChanged: (value) => context.read<LoginCubit>().emailChanged(value),
    );
  }

  Widget buildPasswordField(LoginState state, BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        // - Change Mode: Returns error immediately if dirty.
        errorText: state.password.displayError(state.status),
      ),
      obscureText: true,
      onChanged: (value) => context.read<LoginCubit>().passwordChanged(value),
    );
  }

  Widget _buildSubmitButton(LoginState state, BuildContext context) {
    if (state.status.isSubmitting) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () => context.read<LoginCubit>().submit(),
          child: const Text('Submit'),
        ),
      );
    }
  }
}
