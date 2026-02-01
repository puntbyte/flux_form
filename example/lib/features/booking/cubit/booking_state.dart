part of 'booking_cubit.dart';

class BookingState extends Equatable with FormMixin {
  final SimpleStringInput<String> start;
  final SimpleStringInput<String> end;
  final FormStatus status;

  const BookingState({
    SimpleStringInput<String>? start,
    SimpleStringInput<String>? end,
    this.status = FormStatus.initial,
  }) : start = start ?? const SimpleStringInput.untouched(),
       end = end ?? const SimpleStringInput.untouched();

  @override
  List<FormInput<dynamic, String>> get inputs => [start, end];

  BookingState copyWith({
    SimpleStringInput<String>? start,
    SimpleStringInput<String>? end,
    FormStatus? status,
  }) => BookingState(
    start: start ?? this.start,
    end: end ?? this.end,
    status: status ?? this.status,
  );

  @override
  List<Object> get props => [start, end, status];
}
