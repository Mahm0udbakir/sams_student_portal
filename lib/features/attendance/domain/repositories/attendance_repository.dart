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

  /// Record attendance for the currently signed-in user for [sessionId].
  Future<void> recordAttendance({required String sessionId});

  /// Stream real-time attendance overview for the currently signed-in user.
  Stream<AttendanceOverviewEntity> watchAttendanceOverview();
}
