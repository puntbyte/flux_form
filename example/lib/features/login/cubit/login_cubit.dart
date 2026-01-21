import 'package:equatable/equatable.dart';
import 'package:example/inputs/email_input.dart';
import 'package:example/inputs/password_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState());

  void emailChanged(String value) {
    // ⚡️ FIX: Use copyWith with named parameter 'value'.
    // We set isPure: false to mark it as touched.
    // The 'mode' (Submit) is preserved from the existing state.email.
    final newEmail = state.email.copyWith(value: value, isTouched: false);
    emit(state.copyWith(email: newEmail, status: FormStatus.initial));
  }

  void passwordChanged(String value) {
    // ⚡️ FIX: Use copyWith with named parameter 'value'.
    // The 'mode' (Change) is preserved.
    final newPassword = state.password.copyWith(value: value, isTouched: false);
    emit(state.copyWith(password: newPassword, status: FormStatus.initial));
  }

  Future<void> submit() async {
    // If invalid, we mark status as failed.
    // This triggers 'resolveFault' to show errors even for Submit Mode inputs.
    if (state.isNotValid) {
      emit(state.copyWith(status: FormStatus.failed));
      return;
    }

    emit(state.copyWith(status: FormStatus.submitting));

    // Simulate API
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(status: FormStatus.succeeded));
  }
}
