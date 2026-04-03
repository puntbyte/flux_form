// lib/features/login/cubit/login_state.dart

part of 'login_cubit.dart';

class LoginState {
  final LoginSchema schema;
  final SubmissionStatus status;

  const LoginState({
    this.schema = const LoginSchema(),
    this.status = SubmissionStatus.idle,
  });

  LoginState copyWith({LoginSchema? schema, SubmissionStatus? status}) => LoginState(
    schema: schema ?? this.schema,
    status: status ?? this.status,
  );
}
