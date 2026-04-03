// lib/src/forms/utilities/form_submitter.dart

import 'dart:async';

/// A utility class to encapsulate and standardise form submission lifecycles.
///
/// [FormSubmitter] handles the try/catch, status transitions, and result
/// routing of an async submission so your Cubit/Bloc handler stays flat.
///
/// **Standard usage (with [FormSchema.validate]):**
/// ```dart
/// Future<void> submit() async {
///   // 1. Touch all fields and check validity in one call.
///   final (validated, isValid) = state.schema.validate();
///   if (!isValid) {
///     emit(state.copyWith(schema: validated, status: SubmissionStatus.failure));
///     return;
///   }
///
///   // 2. Hand off the async lifecycle to FormSubmitter.
///   await FormSubmitter<void>(
///     onStart: () => emit(state.copyWith(status: SubmissionStatus.inProgress)),
///     onSubmit: () => api.login(state.schema.values),
///     onSuccess: (_) => emit(state.copyWith(status: SubmissionStatus.success)),
///     onError: (e, s) => emit(state.copyWith(status: SubmissionStatus.failure)),
///   ).submit();
/// }
/// ```
///
/// The validity guard is intentionally **not** part of [submit]. Your state
/// management layer already has the schema and knows whether to proceed —
/// putting a validity flag here would duplicate that logic and make the
/// signature lie about what [FormSubmitter] is responsible for.
class FormSubmitter<T> {
  final FutureOr<T> Function()? onSubmit;
  final void Function(T result)? onSuccess;
  final void Function(Object error, StackTrace stackTrace)? onError;
  final void Function()? onStart;

  /// Creates a [FormSubmitter] for a full async submission lifecycle.
  ///
  /// - [onStart] — called first; use it to set `SubmissionStatus.inProgress`.
  /// - [onSubmit] — the async task (API call, repository write, etc.).
  /// - [onSuccess] — called with the task's result on success.
  /// - [onError] — called with the error and stack trace on failure.
  const FormSubmitter({
    required FutureOr<T> Function() this.onSubmit,
    required void Function(T result) this.onSuccess,
    required void Function(Object error, StackTrace stackTrace) this.onError,

    this.onStart,
  });

  /// Creates a [FormSubmitter] for a delegated or event-driven submission.
  ///
  /// Use this in architectures where the form Cubit does not make the API
  /// call directly but instead triggers another Bloc via a listener:
  ///
  /// ```dart
  /// // The form Cubit just fires an event; the AuthBloc owns the API call.
  /// await FormSubmitter.delegated(
  ///   onValid: () => authBloc.add(const LoginRequested()),
  /// ).submit();
  /// ```
  const FormSubmitter.delegated({
    required void Function() onValid,
  }) : onSubmit = null,
       onSuccess = null,
       onError = null,
       onStart = onValid;

  /// Executes the submission lifecycle.
  ///
  /// Call this **after** your validity guard:
  /// ```dart
  /// final (validated, isValid) = state.schema.validate();
  /// if (!isValid) { /* emit failure */ return; }
  /// await submitter.submit();
  /// ```
  ///
  /// Order of operations:
  /// 1. Calls [onStart] (if provided).
  /// 2. Awaits [onSubmit] inside a try/catch.
  /// 3. On success calls [onSuccess]; on error calls [onError].
  Future<void> submit() async {
    onStart?.call();

    if (onSubmit != null) {
      try {
        final result = await onSubmit!();
        onSuccess?.call(result);
      } catch (error, stackTrace) {
        onError?.call(error, stackTrace);
      }
    }
  }
}
