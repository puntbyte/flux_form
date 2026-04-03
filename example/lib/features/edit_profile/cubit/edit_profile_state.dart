// lib/features/edit_profile/cubit/edit_profile_state.dart

part of 'edit_profile_cubit.dart';

class EditProfileState {
  final ProfileSchema schema;
  final SubmissionStatus status;

  // ProfileSchema() cannot be const because its static final StringInputBuilder
  // fields are non-const. Default parameter values must be const, so instead
  // we accept a nullable schema and resolve it in the initializer list —
  // initializer list expressions are not required to be const.
  EditProfileState({
    ProfileSchema? schema,
    this.status = SubmissionStatus.idle,
  }) : schema = schema ?? ProfileSchema();

  EditProfileState copyWith({
    ProfileSchema? schema,
    SubmissionStatus? status,
  }) => EditProfileState(
    schema: schema ?? this.schema,
    status: status ?? this.status,
  );
}