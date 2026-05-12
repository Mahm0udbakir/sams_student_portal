import '../../domain/entities/attendance_subject_entity.dart';

class AttendanceSubjectModel extends AttendanceSubjectEntity {
  const AttendanceSubjectModel({
    required super.subject,
    required super.percentage,
    super.attendedCount = 0,
    super.scheduledSessionCount = 0,
    super.scanDates = const [],
  });
}
