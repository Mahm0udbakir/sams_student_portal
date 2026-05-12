import 'package:equatable/equatable.dart';

class AttendanceSubjectEntity extends Equatable {
  const AttendanceSubjectEntity({
    required this.subject,
    required this.percentage,
    this.attendedCount = 0,
    this.scheduledSessionCount = 0,
    this.scanDates = const [],
  });

  final String subject;
  final int percentage;
  /// Records in Firestore for this student + course (scans marked).
  final int attendedCount;
  /// Sessions in `attendance_sessions` for this course (scheduled / total offered).
  final int scheduledSessionCount;
  final List<DateTime> scanDates;

  @override
  List<Object?> get props => [
        subject,
        percentage,
        attendedCount,
        scheduledSessionCount,
        scanDates,
      ];
}
