part of 'booking_cubit.dart';

class BookingState extends Equatable with FormMixin {
  final StringField start;
  final StringField end;
  final FormStatus status;

  BookingState({
    StringField? start,
    StringField? end,
    this.status = FormStatus.initial,
  })  : start = start ?? StringField.untouched(),
        end = end ?? StringField.untouched();

  @override
  List<Field> get fields => [start, end];

  BookingState copyWith({
    StringField? start,
    StringField? end,
    FormStatus? status,
  }) {
    return BookingState(
      start: start ?? this.start,
      end: end ?? this.end,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [start, end, status];
}