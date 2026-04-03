// lib/features/booking/cubit/booking_state.dart

part of 'booking_cubit.dart';

class BookingState {
  final BookingSchema schema;
  final SubmissionStatus status;

  BookingState({required this.schema, required this.status});

  factory BookingState.initial() => BookingState(
    schema: BookingSchema(),
    status: SubmissionStatus.idle,
  );

  BookingState copyWith({BookingSchema? schema, SubmissionStatus? status}) => BookingState(
    schema: schema ?? this.schema,
    status: status ?? this.status,
  );
}
