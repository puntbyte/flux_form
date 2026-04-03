// lib/features/wizard/cubit/wizard_cubit.dart

import 'package:example/features/wizard/forms/wizard_steps.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'wizard_state.dart';

class WizardCubit extends Cubit<WizardState> {
  WizardCubit() : super(WizardState.initial());

  // ── Step 1 — Personal ──────────────────────────────────────────────────────

  void firstNameChanged(String v) =>
      _step1((s) => s.copyWith(firstName: s.firstName.replaceValue(v)));

  void lastNameChanged(String v) => _step1((s) => s.copyWith(lastName: s.lastName.replaceValue(v)));

  void phoneChanged(String v) => _step1((s) => s.copyWith(phone: s.phone.replaceValue(v)));

  void _step1(PersonalStep Function(PersonalStep) fn) => emit(
    state.copyWith(
      wizard: state.wizard.updateCurrentStep(fn(state.wizard.currentStep as PersonalStep)),
    ),
  );

  // ── Step 2 — Account ───────────────────────────────────────────────────────

  void emailChanged(String v) => _step2((s) => s.copyWith(email: s.email.replaceValue(v)));

  void passwordChanged(String v) => _step2((s) => s.copyWith(password: s.password.replaceValue(v)));

  void confirmPasswordChanged(String v) =>
      _step2((s) => s.copyWith(confirmPassword: s.confirmPassword.replaceValue(v)));

  void _step2(AccountStep Function(AccountStep) fn) => emit(
    state.copyWith(
      wizard: state.wizard.updateCurrentStep(fn(state.wizard.currentStep as AccountStep)),
    ),
  );

  // ── Step 3 — Preferences ───────────────────────────────────────────────────

  void acceptTermsChanged(bool v) => _step3(
    (s) => s.copyWith(
      acceptTerms: s.acceptTerms.update(value: v, status: InputStatus.touched),
    ),
  );

  void subscribeChanged(bool v) => _step3(
    (s) => s.copyWith(
      subscribeNewsletter: s.subscribeNewsletter.update(value: v),
    ),
  );

  void _step3(PreferencesStep Function(PreferencesStep) fn) => emit(
    state.copyWith(
      wizard: state.wizard.updateCurrentStep(fn(state.wizard.currentStep as PreferencesStep)),
    ),
  );

  // ── Navigation ────────────────────────────────────────────────────────────

  void next() {
    // validateCurrentStep — touches the current step and returns
    // (updated wizard, isValid). Guards against advancing with errors.
    final (validated, isValid) = state.wizard.validateCurrentStep();
    if (!isValid) {
      emit(state.copyWith(wizard: validated, status: SubmissionStatus.failure));
      return;
    }
    emit(
      state.copyWith(
        wizard: validated.advance(),
        status: SubmissionStatus.idle,
      ),
    );
  }

  void back() => emit(
    state.copyWith(
      wizard: state.wizard.back(),
      status: SubmissionStatus.idle,
    ),
  );

  Future<void> submit() async {
    // validateAll — touches all steps simultaneously and checks all are valid.
    final (validated, isValid) = state.wizard.validateAll();
    if (!isValid) {
      emit(state.copyWith(wizard: validated, status: SubmissionStatus.failure));
      return;
    }
    await FormSubmitter<void>(
      onStart: () => emit(state.copyWith(status: SubmissionStatus.inProgress)),
      onSubmit: () => Future.delayed(const Duration(seconds: 1)),
      onSuccess: (_) => emit(state.copyWith(status: SubmissionStatus.success)),
      onError: (_, _) => emit(state.copyWith(status: SubmissionStatus.failure)),
    ).submit();
  }

  void reset() => emit(WizardState.initial());
}
