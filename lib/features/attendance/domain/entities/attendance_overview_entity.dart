import 'package:equatable/equatable.dart';

import 'attendance_subject_entity.dart';

class AttendanceOverviewEntity extends Equatable {
  const AttendanceOverviewEntity({
    required this.overallPercent,
    required this.subjects,
  });

  final int overallPercent;
  final List<AttendanceSubjectEntity> subjects;

  @override
  List<Object?> get props => [overallPercent, subjects];
}
