// lib/src/forms/form_submitter.dart

/// A utility class to encapsulate the standard submission lifecycle.
///
/// [T] is the success result type.
class FormSubmitter<T> {
  final Future<T> Function() action;
  final void Function(T) onSuccess;
  final void Function(Object error, StackTrace stackTrace) onError;
  final void Function()? onStart;

  FormSubmitter({
    required this.action,
    required this.onSuccess,
    required this.onError,
    this.onStart,
  });

  Future<void> submit() async {
    onStart?.call();

    try {
      final result = await action();
      onSuccess(result);
    } on Object catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }
}
