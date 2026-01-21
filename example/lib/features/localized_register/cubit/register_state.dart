part of 'register_cubit.dart';

class RegisterState extends Equatable with FormMixin {
  final AuthField email;
  final AuthField password;
  final FormStatus status;
  final String languageCode; // 'en' or 'es'

  const RegisterState({
    AuthField? email,
    AuthField? password,
    this.status = FormStatus.initial,
    this.languageCode = 'en',
  }) : email = email ?? const AuthField.untouched(),
       password = password ?? const AuthField.untouched();

  @override
  List<Field> get fields => [email, password];

  RegisterState copyWith({
    AuthField? email,
    AuthField? password,
    FormStatus? status,
    String? languageCode,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object> get props => [email, password, status, languageCode];
}
