import 'package:example/features/login/forms/login_schema.dart';
import 'package:example/features/login/models/auth_error.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void emailChanged(String value) {
    // 1. Update Input -> 2. Update Form
    emit(
      state.copyWith(
        schema: state.shema.copyWith(email: state.shema.email.replaceValue(value)),
        status: FormStatus.initial, // Reset global status on edit
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        schema: state.shema.copyWith(password: state.shema.password.replaceValue(value)),
        status: FormStatus.initial,
      ),
    );
  }

  Future<void> submit() async {
    // 1. Validate: If invalid, state.form.isValid is false.
    // We check if it's NOT valid.
    if (state.shema.isNotValid) {
      // 2. Mark Failed: This reveals 'Deferred' errors (like Email).
      emit(state.copyWith(status: FormStatus.failed));
      return;
    }

    emit(state.copyWith(status: FormStatus.submitting));

    try {
      // Simulate Network Call
      await Future.delayed(const Duration(seconds: 2));

      // 3. Simulate Server Error (e.g., Email taken)
      if (state.shema.email.value == 'taken@gmail.com') {
        // Inject remote error back into the field
        final newEmail = state.shema.email.setRemoteError(AuthError.emailTaken);

        emit(
          state.copyWith(
            schema: state.shema.copyWith(email: newEmail),
            status: FormStatus.failed,
          ),
        );
        return;
      }

      // Success
      print('Submitted: ${state.shema.values}');
      emit(state.copyWith(status: FormStatus.succeeded));
    } catch (_) {
      emit(state.copyWith(status: FormStatus.failed));
    }
  }
}
