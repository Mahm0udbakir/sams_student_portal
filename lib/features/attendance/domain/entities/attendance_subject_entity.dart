import 'package:equatable/equatable.dart';

class AttendanceSubjectEntity extends Equatable {
  const AttendanceSubjectEntity({
    required this.subject,
    required this.percentage,
  });

  final String subject;
  final int percentage;

  @override
  List<Object?> get props => [subject, percentage];
}
