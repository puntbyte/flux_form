// lib/src/forms/multi_step_schema.dart

import 'package:flux_form/src/forms/form_schema.dart';

/// A concrete, immutable wrapper that models a **multi-step form** (wizard).
///
/// [MultiStepSchema] holds an ordered list of [FormSchema] steps and tracks
/// which step is currently active. Each step is an independent schema with its
/// own inputs, validators, and `copyWith`.
///
/// The class is fully concrete — it does not need to be subclassed.
///
/// ---
/// ## Setup
///
/// ```dart
/// // Define each step as a normal FormSchema.
/// class PersonalSchema extends FormSchema { ... }
/// class AccountSchema  extends FormSchema { ... }
/// class PrefSchema     extends FormSchema { ... }
///
/// // Create the wizard in your initial state.
/// final wizard = MultiStepSchema(steps: [
///   const PersonalSchema(),
///   const AccountSchema(),
///   const PrefSchema(),
/// ]);
/// ```
///
/// ## Navigation
///
/// All navigation returns a **new** [MultiStepSchema] — the current instance
/// is immutable.
///
/// ```dart
/// // Validate current step before advancing.
/// final (validated, isValid) = wizard.validateCurrentStep();
/// if (!isValid) {
///   emit(state.copyWith(wizard: validated, status: SubmissionStatus.failure));
///   return;
/// }
/// emit(state.copyWith(wizard: wizard.advance()));
/// ```
///
/// ## Updating a step
///
/// ```dart
/// void emailChanged(String value) {
///   final step = wizard.currentStep as AccountSchema;
///   final updated = step.copyWith(email: step.email.replaceValue(value));
///   emit(state.copyWith(wizard: wizard.updateCurrentStep(updated)));
/// }
/// ```
///
/// ## Submission
///
/// ```dart
/// Future<void> submit() async {
///   if (!wizard.allStepsValid) {
///     emit(state.copyWith(status: SubmissionStatus.failure));
///     return;
///   }
///   // wizard.values merges all step values into one map.
///   await api.register(wizard.values);
/// }
/// ```
class MultiStepSchema {
  /// All steps in declaration order.
  final List<FormSchema> steps;

  /// The index of the currently active step (0-based).
  final int currentStepIndex;

  MultiStepSchema({
    required this.steps,
    this.currentStepIndex = 0,
  }) : assert(steps.isNotEmpty, 'MultiStepSchema must have at least one step.'),
       assert(
         currentStepIndex >= 0 && currentStepIndex < steps.length,
         'currentStepIndex ($currentStepIndex) is out of range '
         '[0, ${steps.length - 1}].',
       );

  // ── Current step ──────────────────────────────────────────

  /// The active [FormSchema].
  FormSchema get currentStep => steps[currentStepIndex];

  /// 1-based display index (e.g., "Step 2 of 4").
  int get currentStepNumber => currentStepIndex + 1;

  /// Total number of steps.
  int get totalSteps => steps.length;

  // ── Status flags ──────────────────────────────────────────

  bool get isFirstStep => currentStepIndex == 0;

  bool get isLastStep => currentStepIndex == steps.length - 1;

  /// Whether the current step passes all its validators.
  bool get isCurrentStepValid => currentStep.isValid;

  /// Whether every step passes all its validators.
  bool get allStepsValid => steps.every((s) => s.isValid);

  /// Whether all inputs across all steps are untouched.
  bool get isUntouched => steps.every((s) => s.isUntouched);

  /// How many steps have been completed (every input valid), regardless of
  /// current position. Useful for progress indicators.
  int get completedSteps => steps.where((s) => s.isValid).length;

  /// Completion ratio in [0.0, 1.0] based on the current step index.
  ///
  /// Reaches 1.0 when the user is on the last step (not after completion).
  /// Use [allStepsValid] to determine whether all steps are truly complete.
  double get progress => currentStepNumber / totalSteps;

  // ── Navigation ────────────────────────────────────────────

  /// Returns a new wizard advanced to the next step.
  ///
  /// Does nothing if already on the last step.
  MultiStepSchema advance() {
    if (isLastStep) return this;
    return _withIndex(currentStepIndex + 1);
  }

  /// Returns a new wizard moved back to the previous step.
  ///
  /// Does nothing if already on the first step.
  MultiStepSchema back() {
    if (isFirstStep) return this;
    return _withIndex(currentStepIndex - 1);
  }

  /// Returns a new wizard at [index].
  ///
  /// [index] is clamped to [0, steps.length - 1].
  MultiStepSchema goToStep(int index) => _withIndex(index.clamp(0, steps.length - 1));

  // ── Step mutation ─────────────────────────────────────────

  /// Returns a new wizard with [updated] replacing the current step.
  ///
  /// Use this whenever you need to emit an updated field value:
  ///
  /// ```dart
  /// void emailChanged(String value) {
  ///   final step = wizard.currentStep as AccountSchema;
  ///   emit(state.copyWith(
  ///     wizard: wizard.updateCurrentStep(
  ///       step.copyWith(email: step.email.replaceValue(value)),
  ///     ),
  ///   ));
  /// }
  /// ```
  MultiStepSchema updateCurrentStep(FormSchema updated) {
    final newSteps = List<FormSchema>.of(steps);
    newSteps[currentStepIndex] = updated;
    return MultiStepSchema(steps: newSteps, currentStepIndex: currentStepIndex);
  }

  /// Returns a new wizard with [updated] replacing the step at [index].
  MultiStepSchema updateStep(int index, FormSchema updated) {
    assert(index >= 0 && index < steps.length, 'index out of range');
    final newSteps = List<FormSchema>.of(steps);
    newSteps[index] = updated;
    return MultiStepSchema(steps: newSteps, currentStepIndex: currentStepIndex);
  }

  // ── Validation helpers ────────────────────────────────────

  /// Validates the current step only.
  ///
  /// Returns a record of the updated wizard (with the current step's inputs
  /// all marked touched) and whether the current step is valid.
  ///
  /// Use this before calling [advance] to guard against premature progression:
  ///
  /// ```dart
  /// final (validated, isValid) = wizard.validateCurrentStep();
  /// if (!isValid) {
  ///   emit(state.copyWith(wizard: validated, status: SubmissionStatus.failure));
  ///   return;
  /// }
  /// emit(state.copyWith(wizard: wizard.advance(), status: SubmissionStatus.idle));
  /// ```
  (MultiStepSchema wizard, bool isValid) validateCurrentStep() {
    final (touched, isValid) = currentStep.validate();
    return (updateCurrentStep(touched), isValid);
  }

  /// Validates all steps simultaneously.
  ///
  /// Returns the updated wizard (all steps touched) and whether every step
  /// is valid. Use this as a final guard before submitting.
  (MultiStepSchema wizard, bool isValid) validateAll() {
    final touchedSteps = steps.map((s) => s.touchAll()).toList();
    final allValid = touchedSteps.every((s) => s.isValid);
    return (
      MultiStepSchema(steps: touchedSteps, currentStepIndex: currentStepIndex),
      allValid,
    );
  }

  /// Returns a wizard with all inputs across all steps marked touched.
  MultiStepSchema touchAll() => MultiStepSchema(
    steps: steps.map((s) => s.touchAll()).toList(),
    currentStepIndex: currentStepIndex,
  );

  /// Returns a wizard with all inputs across all steps reset to their
  /// initial values and marked untouched.
  MultiStepSchema reset() => MultiStepSchema(
    steps: steps.map((s) => s.reset()).toList(),
    currentStepIndex: 0,
  );

  // ── Serialization ─────────────────────────────────────────

  /// Merged `values` from all steps in declaration order.
  ///
  /// If two steps declare the same key, the later step's value wins.
  Map<String, dynamic> get values => steps.fold(
    <String, dynamic>{},
    (acc, step) => <String, dynamic>{...acc, ...step.values},
  );

  /// Merged `changedValues` from all steps (only inputs that differ from
  /// their initial values).
  Map<String, dynamic> get changedValues => steps.fold(
    <String, dynamic>{},
    (acc, step) => <String, dynamic>{...acc, ...step.changedValues},
  );

  // ── Internal ──────────────────────────────────────────────

  MultiStepSchema _withIndex(int index) => MultiStepSchema(steps: steps, currentStepIndex: index);
}
