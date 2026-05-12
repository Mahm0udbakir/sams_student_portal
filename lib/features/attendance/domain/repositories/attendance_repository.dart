import '../entities/attendance_overview_entity.dart';
import '../entities/attendance_session_entity.dart';

abstract class AttendanceRepository {
  Future<AttendanceOverviewEntity> getAttendanceOverview();

  Future<AttendanceSessionEntity> createAttendanceSession({
    required String subject,
    required String room,
    required DateTime startAt,
    required DateTime endAt,
    bool isActive,
  });

  Stream<List<AttendanceSessionEntity>> watchActiveSessions();

  /// Record attendance for the signed-in user. [courseSubject] is the course the student selected before scanning.
  Future<void> recordAttendance({
    required String sessionId,
    required String courseSubject,
  });

  /// Stream real-time attendance overview for the currently signed-in user.
  Stream<AttendanceOverviewEntity> watchAttendanceOverview();
}
