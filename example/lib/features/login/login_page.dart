// lib/features/login/login_page.dart

import 'package:example/errors/auth_error.dart';
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
        appBar: AppBar(title: const Text('Login — FormSchema + FormSubmitter')),
        drawer: const AppDrawer(),
        body: BlocConsumer<LoginCubit, LoginState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: (ctx, state) {
            if (state.status.isSuccess) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('✓ Logged in! (check console for serialized values)'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (ctx, state) => _LoginBody(state),
        ),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  final LoginState state;

  const _LoginBody(this.state);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    final schema = state.schema;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Feature tag
        _tag('FormSchema · FormSubmitter · detailedErrors · remote error'),
        const SizedBox(height: 24),

        // ── Email — deferred mode ──────────────────────────────────────────
        // Error is hidden while typing; revealed only after submit fails OR
        // when a remote error is injected (try 'taken@example.com').
        TextFormField(
          initialValue: schema.email.value,
          onChanged: cubit.emailChanged,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Try taken@example.com',
            // FormError.message(context) — typed error → localised string.
            errorText: schema.email.displayError(state.status)?.message(context),
            suffixIcon: schema.email.isValid
                ? const Icon(Icons.check_circle_outline, color: Colors.green)
                : null,
          ),
        ),
        const SizedBox(height: 16),

        // ── Password — live mode ───────────────────────────────────────────
        TextFormField(
          initialValue: schema.password.value,
          onChanged: cubit.passwordChanged,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: schema.password.displayError(state.status)?.message(context),
          ),
        ),

        // ── detailedErrors — password strength meter ───────────────────────
        // detailedErrors runs ALL validators and returns every failing error,
        // not just the first one. Perfect for requirement checklists.
        if (schema.password.isTouched) ...[
          const SizedBox(height: 12),
          _PasswordStrengthMeter(schema.password.detailedErrors),
        ],

        const SizedBox(height: 24),

        // ── namedErrors — debug panel ──────────────────────────────────────
        // namedErrors returns {fieldKey: error} only for invalid inputs.
        if (state.status.isFailure && schema.namedErrors.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('namedErrors:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${schema.namedErrors}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Submit ─────────────────────────────────────────────────────────
        ElevatedButton(
          onPressed: state.status.isInProgress ? null : cubit.submit,
          child: state.status.isInProgress
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Login'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: cubit.resetForm,
          child: const Text('Reset Form'),
        ),

        // ── values debug ───────────────────────────────────────────────────
        if (state.status.isSuccess) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'schema.values (sent to API):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${state.schema.values}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Demonstrates [detailedErrors] — showing every unmet password requirement
/// as individual checklist items rather than a single error string.
class _PasswordStrengthMeter extends StatelessWidget {
  final List<AuthError> failingErrors;

  const _PasswordStrengthMeter(this.failingErrors);

  @override
  Widget build(BuildContext context) {
    final requirements = [
      (AuthError.tooShort, 'At least 8 characters'),
      (AuthError.noUppercase, 'One uppercase letter'),
      (AuthError.noDigit, 'One digit'),
      (AuthError.noSpecialChar, r'One special character (!@#$%)'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requirements.map((req) {
        final met = !failingErrors.contains(req.$1);
        return Row(
          children: [
            Icon(
              met ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: met ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              req.$2,
              style: TextStyle(
                fontSize: 12,
                color: met ? Colors.green : Colors.grey,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

Widget _tag(String text) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(text, style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
);
