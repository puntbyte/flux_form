part of 'booking_cubit.dart';

class BookingState extends Equatable with FormMixin {
  final StringInput<String> start;
  final StringInput<String> end;
  final FormStatus status;

  const BookingState({
    StringInput<String>? start,
    StringInput<String>? end,
    this.status = FormStatus.initial,
  }) : start = start ?? const StringInput.untouched(),
       end = end ?? const StringInput.untouched();

  @override
  List<FormInput<dynamic, String>> get inputs => [start, end];

  BookingState copyWith({
    StringInput<String>? start,
    StringInput<String>? end,
    FormStatus? status,
  }) => BookingState(
    start: start ?? this.start,
    end: end ?? this.end,
    status: status ?? this.status,
  );

  @override
  List<Object> get props => [start, end, status];
}
