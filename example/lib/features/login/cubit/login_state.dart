part of 'login_cubit.dart';

class LoginState extends Equatable with FormMixin {
  final EmailInput email;
  final PasswordInput password;
  final FormStatus status;

  const LoginState({
    EmailInput? email,
    PasswordInput? password,
    this.status = FormStatus.initial,
  }) : email = email ?? const EmailInput.pure(),
       password = password ?? const PasswordInput.untouched();

  @override
  List<FormInput<String, String>> get inputs => [email, password];

  LoginState copyWith({
    EmailInput? email,
    PasswordInput? password,
    FormStatus? status,
  }) => LoginState(
    email: email ?? this.email,
    password: password ?? this.password,
    status: status ?? this.status,
  );

  @override
  List<Object> get props => [email, password, status];
}
