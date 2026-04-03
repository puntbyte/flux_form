// lib/features/wizard/wizard_page.dart

import 'package:example/features/wizard/cubit/wizard_cubit.dart';
import 'package:example/features/wizard/forms/wizard_steps.dart';
import 'package:example/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

class WizardPage extends StatelessWidget {
  const WizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WizardCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Registration Wizard — MultiStepSchema')),
        drawer: const AppDrawer(),
        body: BlocBuilder<WizardCubit, WizardState>(
          builder: (context, state) {
            final wizard = state.wizard;

            if (state.status.isSuccess) return _SuccessView(wizard.values);

            return Column(
              children: [
                // Progress
                _WizardProgress(wizard.currentStepIndex, wizard.totalSteps),
                Expanded(
                  child: switch (wizard.currentStep) {
                    final PersonalStep s => _Step1View(s, state.status),
                    final AccountStep s => _Step2View(s, state.status),
                    final PreferencesStep s => _Step3View(s, state.status),
                    _ => const SizedBox.shrink(),
                  },
                ),
                _NavBar(state),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _WizardProgress extends StatelessWidget {
  final int step;
  final int total;

  const _WizardProgress(this.step, this.total);

  static const _labels = ['Personal', 'Account', 'Preferences'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(total, (i) {
          final active = i == step;
          final done = i < step;
          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: done
                      ? Colors.green
                      : active
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  child: done
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: active ? Colors.white : Colors.grey,
                          ),
                        ),
                ),
                if (i < total - 1) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: active ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: done ? Colors.green : Colors.grey.shade300),
                  ),
                ] else
                  Expanded(
                    child: Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: active ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Step views ────────────────────────────────────────────────────────────────

class _Step1View extends StatelessWidget {
  final PersonalStep step;
  final SubmissionStatus status;

  const _Step1View(this.step, this.status);

  @override
  Widget build(BuildContext context) {
    final c = context.read<WizardCubit>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _tag('StringInputBuilder — fluent builder API'),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            labelText: 'First Name',
            errorText: step.firstName.displayError(status),
          ),
          onChanged: c.firstNameChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Last Name',
            errorText: step.lastName.displayError(status),
          ),
          onChanged: c.lastNameChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Phone (digits only — sanitized automatically)',
            helperText: 'Spaces/dashes stripped via StringSanitizer.digitsOnly()',
            errorText: step.phone.displayError(status),
          ),
          keyboardType: TextInputType.phone,
          onChanged: c.phoneChanged,
        ),
      ],
    );
  }
}

class _Step2View extends StatelessWidget {
  final AccountStep step;
  final SubmissionStatus status;

  const _Step2View(this.step, this.status);

  @override
  Widget build(BuildContext context) {
    final c = context.read<WizardCubit>();
    // schemaErrors — cross-field errors from SchemaValidator
    final crossFieldError = step.schemaErrors.firstOrNull?.toString();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _tag('Validator.compose · SchemaValidator cross-field'),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: step.email.displayError(status),
          ),
          onChanged: c.emailChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            helperText: 'Rules defined via Validator.compose()',
            errorText: step.password.displayError(status),
          ),
          onChanged: c.passwordChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            // Cross-field error from SchemaValidator
            errorText:
                step.confirmPassword.displayError(status) ??
                (status.isFailure ? crossFieldError : null),
          ),
          onChanged: c.confirmPasswordChanged,
        ),
      ],
    );
  }
}

class _Step3View extends StatelessWidget {
  final PreferencesStep step;
  final SubmissionStatus status;

  const _Step3View(this.step, this.status);

  @override
  Widget build(BuildContext context) {
    final c = context.read<WizardCubit>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _tag('BoolInputBuilder · SimpleBoolInput'),
        const SizedBox(height: 20),
        SwitchListTile(
          title: const Text('Subscribe to newsletter'),
          subtitle: const Text('Optional — no validation'),
          value: step.subscribeNewsletter.value,
          onChanged: c.subscribeChanged,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        CheckboxListTile(
          title: const Text('I accept the Terms of Service *'),
          value: step.acceptTerms.value,
          onChanged: (v) => c.acceptTermsChanged(v ?? false),
          contentPadding: EdgeInsets.zero,
        ),
        if (step.acceptTerms.displayError(status) != null)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              step.acceptTerms.displayError(status)!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// ── Navigation bar ─────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  final WizardState state;

  const _NavBar(this.state);

  @override
  Widget build(BuildContext context) {
    final c = context.read<WizardCubit>();
    final wizard = state.wizard;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (!wizard.isFirstStep)
              Expanded(
                child: OutlinedButton(
                  onPressed: c.back,
                  child: const Text('Back'),
                ),
              ),
            if (!wizard.isFirstStep) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: state.status.isInProgress
                    ? null
                    : wizard.isLastStep
                    ? c.submit
                    : c.next,
                child: state.status.isInProgress
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(wizard.isLastStep ? 'Submit' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success view ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final Map<String, dynamic> values;

  const _SuccessView(this.values);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Registration Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'wizard.values (all steps merged):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green.shade50,
              child: Text('$values', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _tag(String t) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(4)),
  child: Text(t, style: TextStyle(fontSize: 11, color: Colors.purple.shade700)),
);
