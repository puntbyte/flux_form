// lib/src/forms/form_submitter.dart

import 'dart:async';

/// A utility class to encapsulate and standardize form submission lifecycles.
class FormSubmitter<T> {
  final FutureOr<T> Function()? onSubmit;
  final void Function(T)? onSuccess;
  final void Function(Object error, StackTrace stackTrace)? onError;

  final void Function()? onStart;
  final void Function()? onInvalid;

  /// Handles a complete asynchronous submission lifecycle.
  /// Ideal for Cubits that make API calls directly.
  const FormSubmitter({
    required FutureOr<T> Function() this.onSubmit,
    required void Function(T result) this.onSuccess,
    required void Function(Object error, StackTrace stackTrace) this.onError,
    this.onStart,
    this.onInvalid,
  });

  /// Handles a delegated or event-driven submission lifecycle.
  /// Ideal for architectures where the actual async work is handed off to
  /// another Bloc (e.g., triggering an AuthBloc event via a UI listener).
  const FormSubmitter.delegated({
    required void Function() onValid,
    this.onInvalid,
  }) : onSubmit = null,
       onSuccess = null,
       onError = null,
       onStart = onValid;

  /// Executes the submission flow based on the [isValid] flag.
  Future<void> submit([bool isValid = true]) async {
    // 1. Guard against invalid forms
    if (!isValid) {
      onInvalid?.call();
      return;
    }

    // 2. Trigger the start/valid callback (e.g., set status to inProgress)
    onStart?.call();

    // 3. If there is an actual task to run, execute it with try/catch
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
