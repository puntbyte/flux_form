import 'package:equatable/equatable.dart';
import 'package:example/inputs/dynamic_string_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_form/flux_form.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(const BookingState());

  void dateChanged({String? start, String? end}) {
    // 1. Get current values if not updated
    final s = start ?? state.start.value;
    final e = end ?? state.end.value;

    // 2. Reconstruct inputs with Cross-Field Logic
    // We use DynamicStringField because the rules change based on 's' and 'e'.

    final startInput = DynamicStringField.touched(
      value: s,
      validators: const [
        RequiredValidator('Start date required'),
        // Optional: Add regex for YYYY-MM-DD
      ],
    );

    final endInput = DynamicStringField.touched(
      value: e,
      validators: [
        const RequiredValidator('End date required'),
        // 3. Cross Field Logic:
        // "End" must be greater than "Start" (s)
        GreaterThanValidator(s, 'End date must be after Start date'),
      ],
    );

    emit(state.copyWith(start: startInput, end: endInput));
  }

  void submit() {
    if (state.isValid) {
      emit(state.copyWith(status: FormStatus.succeeded));
    } else {
      emit(state.copyWith(status: FormStatus.failed));
    }
  }
}
