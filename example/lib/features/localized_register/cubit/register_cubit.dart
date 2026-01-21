import 'package:equatable/equatable.dart';
import 'package:example/features/localized_register/auth_error.dart';
import 'package:example/inputs/auth_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterState());

  void toggleLanguage() {
    final newLang = state.languageCode == 'en' ? 'es' : 'en';
    emit(state.copyWith(languageCode: newLang));
  }

  void emailChanged(String value) {
    final emailInput = AuthField.touched(
      value: value,
      rules: const [
        // Notice we pass Enum values instead of Strings here
        RequiredValidator(AuthError.empty),
        EmailValidator(AuthError.invalidEmail),
      ],
    );
    emit(state.copyWith(email: emailInput));
  }

  void passwordChanged(String value) {
    final passInput = AuthField.touched(
      value: value,
      rules: [
        const RequiredValidator(AuthError.empty),
        const MinLengthValidator(6, AuthError.shortPassword),
        // Custom Regex Rule with Enum Error
        RegexValidator(RegExp('[!@#]'), AuthError.noSpecialChar),
      ],
    );
    emit(state.copyWith(password: passInput));
  }

  void submit() {
    if (state.isValid) {
      emit(state.copyWith(status: FormStatus.succeeded));
    } else {
      emit(state.copyWith(status: FormStatus.failed));
    }
  }
}
