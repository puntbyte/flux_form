// lib/src/models/enums/submission_status.dart

/// Represents the current state of a form submission.
enum SubmissionStatus {
  /// The form has not yet been submitted.
  idle,

  /// The form is validating or submitting.
  inProgress,

  /// The form has been submitted successfully.
  success,

  /// The form submission failed.
  failure,

  /// The form submission was canceled by the user.
  canceled;

  bool get isIdle => this == SubmissionStatus.idle;
  bool get isInProgress => this == SubmissionStatus.inProgress;
  bool get isNotInProgress => this != SubmissionStatus.inProgress;
  bool get isSuccess => this == SubmissionStatus.success;
  bool get isFailure => this == SubmissionStatus.failure;
  bool get isCanceled => this == SubmissionStatus.canceled;

  /// Returns `true` if the form is either loading or succeeded.
  bool get isCommitted => isInProgress || isSuccess;

  /// Returns `true` if the submission flow has ended.
  bool get isFinalized => isSuccess || isFailure || isCanceled;
}
