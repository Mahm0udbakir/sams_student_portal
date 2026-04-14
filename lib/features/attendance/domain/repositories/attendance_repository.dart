import '../entities/attendance_overview_entity.dart';

abstract class AttendanceRepository {
  Future<AttendanceOverviewEntity> getAttendanceOverview();
}
