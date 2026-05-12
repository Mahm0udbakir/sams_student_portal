import '../../domain/entities/attendance_session_entity.dart';

class AttendanceSessionModel extends AttendanceSessionEntity {
  const AttendanceSessionModel({
    required super.sessionId,
    required super.subject,
    required super.room,
    required super.startAt,
    required super.endAt,
    required super.isActive,
    required super.qrPayload,
  });
}
