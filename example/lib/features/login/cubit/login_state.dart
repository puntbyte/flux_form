part of 'login_cubit.dart';

class LoginState {
  final LoginShema shema;
  final SubmissionStatus status;

  const LoginState({
    this.shema = const LoginShema(),
    this.status = SubmissionStatus.idle,
  });

  LoginState copyWith({LoginShema? schema, SubmissionStatus? status}) {
    return LoginState(
      shema: schema ?? shema,
      status: status ?? this.status,
    );
  }
}
