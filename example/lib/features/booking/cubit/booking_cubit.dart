// lib/features/booking/cubit/booking_cubit.dart

import 'package:example/features/booking/forms/booking_schema.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(BookingState.initial());

  // Date pickers — selecting a date is treated as "blur":
  // setValue first (update value, no touch), then markTouched immediately.
  // This matches the blur-mode contract: don't touch mid-interaction,
  // do touch once the user has made a definitive choice.
  void checkInSelected(DateTime? date) {
    if (date == null) return;
    emit(
      state.copyWith(
        schema: state.schema.copyWith(
          checkIn: state.schema.checkIn.setValue(date).markTouched(),
        ),
      ),
    );
  }

  void checkOutSelected(DateTime? date) {
    if (date == null) return;
    emit(
      state.copyWith(
        schema: state.schema.copyWith(
          checkOut: state.schema.checkOut.setValue(date).markTouched(),
        ),
      ),
    );
  }

  void guestsChanged(int delta) {
    final next = (state.schema.guests.value + delta).clamp(1, 10);
    emit(
      state.copyWith(
        schema: state.schema.copyWith(
          guests: state.schema.guests.replaceValue(next),
        ),
      ),
    );
  }

  Future<void> book() async {
    // validate() touches all inputs and checks validity — works for
    // DateTimeInput even though the fields were touched via picker, not typing.
    final (touched, isValid) = state.schema.validate();
    if (!isValid) {
      emit(
        state.copyWith(
          schema: touched as BookingSchema,
          status: SubmissionStatus.failure,
        ),
      );
      return;
    }

    await FormSubmitter<void>(
      onStart: () => emit(state.copyWith(status: SubmissionStatus.inProgress)),
      onSubmit: () => Future.delayed(const Duration(milliseconds: 600)),
      onSuccess: (_) => emit(state.copyWith(status: SubmissionStatus.success)),
      onError: (_, _) => emit(state.copyWith(status: SubmissionStatus.failure)),
    ).submit();
  }

  void reset() => emit(BookingState.initial());
}
