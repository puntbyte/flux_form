// lib/features/wizard/cubit/wizard_state.dart

part of 'wizard_cubit.dart';

class WizardState {
  final MultiStepSchema wizard;
  final SubmissionStatus status;

  const WizardState({required this.wizard, required this.status});

  factory WizardState.initial() => WizardState(
    wizard: MultiStepSchema(
      steps: [PersonalStep(), AccountStep(), PreferencesStep()],
    ),
    status: SubmissionStatus.idle,
  );

  WizardState copyWith({MultiStepSchema? wizard, SubmissionStatus? status}) => WizardState(
    wizard: wizard ?? this.wizard,
    status: status ?? this.status,
  );
}
