// lib/features/login/cubit/login_cubit.dart

import 'package:example/errors/auth_error.dart';
import 'package:example/features/login/forms/login_schema.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void emailChanged(String value) => emit(
    state.copyWith(
      schema: state.schema.copyWith(
        email: state.schema.email.replaceValue(value),
      ),
      status: SubmissionStatus.idle,
    ),
  );

  void passwordChanged(String value) => emit(
    state.copyWith(
      schema: state.schema.copyWith(
        password: state.schema.password.replaceValue(value),
      ),
      status: SubmissionStatus.idle,
    ),
  );

  Future<void> submit() async {
    // FormSchema.validate() — touches all inputs then checks validity.
    // Returns a record (touched schema, bool isValid).
    final (touched, isValid) = state.schema.validate();
    if (!isValid) {
      emit(state.copyWith(schema: touched as LoginSchema, status: SubmissionStatus.failure));
      return;
    }

    // FormSubmitter — encapsulates the async lifecycle with no try/catch in
    // the Cubit. onStart, onSubmit, onSuccess, onError are all wired here.
    await FormSubmitter<void>(
      onStart: () => emit(state.copyWith(status: SubmissionStatus.inProgress)),
      onSubmit: () => _fakeApi(state.schema.values),
      onSuccess: (_) => emit(state.copyWith(status: SubmissionStatus.success)),
      onError: (_, _) => emit(state.copyWith(status: SubmissionStatus.failure)),
    ).submit();
  }

  void resetForm() => emit(
    state.copyWith(
      // schema.reset() reverts every input to initialValue + untouched.
      schema: state.schema.reset(),
      status: SubmissionStatus.idle,
    ),
  );

  Future<void> _fakeApi(Map<String, dynamic> values) async {
    await Future.delayed(const Duration(seconds: 1));
    if (values['email'] == 'taken@example.com') {
      // setRemoteError — injects a server-side error into a specific field.
      // The error is automatically cleared when the user next edits the field.
      emit(
        state.copyWith(
          schema: state.schema.copyWith(
            email: state.schema.email.setRemoteError(AuthError.emailTaken),
          ),
          status: SubmissionStatus.failure,
        ),
      );
      throw Exception('email taken');
    }
  }
}
