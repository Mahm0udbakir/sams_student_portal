import 'package:equatable/equatable.dart';

class AttendanceSubjectEntity extends Equatable {
  const AttendanceSubjectEntity({
    required this.subject,
    required this.percentage,
    this.attendedCount = 0,
    this.scanDates = const [],
  });

  final String subject;
  final int percentage;
  final int attendedCount;
  final List<DateTime> scanDates;

  @override
  List<Object?> get props => [subject, percentage, attendedCount, scanDates];
}
