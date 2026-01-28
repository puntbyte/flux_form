// features/login/view/login_page.dart

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
        appBar: AppBar(title: const Text('Flux Form Demo')),
        drawer: const AppDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<LoginCubit, LoginState>(
            listenWhen: (p, c) => p.status != c.status,
            listener: (context, state) {
              if (state.status.isSucceeded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login Success!')),
                );
              }
            },
            builder: (context, state) => _LoginForm(state),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final LoginState state;

  const _LoginForm(this.state);

  @override
  Widget build(BuildContext context) {
    final form = state.shema;
    final cubit = context.read<LoginCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- EMAIL INPUT ---
        TextFormField(
          initialValue: form.email.value, // Important for resets
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Try "taken@gmail.com"',
            // displayError handles ValidationMode.deferred automatically!
            errorText: form.email.displayError(state.status)?.message(context),
            suffixIcon: _buildSuffix(form.email.isValid),
          ),
          onChanged: cubit.emailChanged,
        ),
        const SizedBox(height: 16),

        // --- PASSWORD INPUT ---
        TextFormField(
          initialValue: form.password.value,
          decoration: InputDecoration(
            labelText: 'Password',
            // displayError handles ValidationMode.live automatically!
            errorText: form.password.displayError(state.status)?.message(context),
            suffixIcon: _buildSuffix(form.password.isValid),
          ),
          obscureText: true,
          onChanged: cubit.passwordChanged,
        ),

        // Bonus: Password Strength Indicator (Multi-Error Check)
        if (form.password.isTouched && form.password.isNotValid)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Password Strength: Low',
              style: TextStyle(color: Colors.orange),
            ),
          ),

        const SizedBox(height: 24),

        // --- SUBMIT BUTTON ---
        ElevatedButton(
          onPressed: state.status.isSubmitting ? null : cubit.submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: state.status.isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Login'),
        ),
      ],
    );
  }

  Widget? _buildSuffix(bool isValid) {
    return isValid ? const Icon(Icons.check_circle, color: Colors.green) : null;
  }
}
