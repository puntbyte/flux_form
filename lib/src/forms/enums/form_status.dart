// lib/src/models/enums/form_status.dart

/// Represents the current state of a form submission.
enum FormStatus {
  /// The form has not yet been submitted.
  initial,

  /// The form is validating or submitting.
  submitting,

  /// The form has been submitted successfully.
  succeeded,

  /// The form submission failed.
  failed,

  /// The form submission was canceled by the user.
  canceled;

  bool get isInitial => this == FormStatus.initial;
  bool get isSubmitting => this == FormStatus.submitting;
  bool get isSucceeded => this == FormStatus.succeeded;
  bool get isFailed => this == FormStatus.failed;
  bool get isCanceled => this == FormStatus.canceled;

  /// Returns `true` if the form is either loading or succeeded.
  bool get isCommitted => isSubmitting || isSucceeded;

  /// Returns `true` if the submission flow has ended.
  bool get isFinalized => isSucceeded || isFailed || isCanceled;
}
