part of 'login_cubit.dart';

class LoginState {
  final LoginShema shema;
  final FormStatus status;

  const LoginState({
    this.shema = const LoginShema(),
    this.status = FormStatus.initial,
  });

  LoginState copyWith({LoginShema? schema, FormStatus? status}) {
    return LoginState(
      shema: schema ?? shema,
      status: status ?? this.status,
    );
  }
}
