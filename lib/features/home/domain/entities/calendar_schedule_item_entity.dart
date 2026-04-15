import 'package:equatable/equatable.dart';

enum CalendarEntryType { exam, event, lecture, birthday }

class CalendarScheduleItemEntity extends Equatable {
  const CalendarScheduleItemEntity({
    required this.date,
    required this.title,
    required this.timeRange,
    required this.location,
    required this.type,
    this.note,
  });

  final DateTime date;
  final String title;
  final String timeRange;
  final String location;
  final CalendarEntryType type;
  final String? note;

  @override
  List<Object?> get props => [date, title, timeRange, location, type, note];
}
