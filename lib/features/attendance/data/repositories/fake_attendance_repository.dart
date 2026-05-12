import '../../domain/entities/attendance_overview_entity.dart';
import '../../domain/entities/attendance_session_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_overview_model.dart';

class FakeAttendanceRepository implements AttendanceRepository {
  @override
  Future<AttendanceOverviewEntity> getAttendanceOverview() async {
    return AttendanceOverviewModel.fake();
  }

  @override
  Future<void> recordAttendance({
    required String sessionId,
    required String courseSubject,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  @override
  Future<AttendanceSessionEntity> createAttendanceSession({
    required String subject,
    required String room,
    required DateTime startAt,
    required DateTime endAt,
    bool isActive = true,
  }) async {
    return AttendanceSessionEntity(
      sessionId: 'fake-session',
      subject: subject,
      room: room,
      startAt: startAt,
      endAt: endAt,
      isActive: isActive,
      qrPayload: '{"sessionId":"fake-session"}',
    );
  }

  @override
  Stream<List<AttendanceSessionEntity>> watchActiveSessions() async* {
    yield const [];
  }

  @override
  Stream<AttendanceOverviewEntity> watchAttendanceOverview() async* {
    // Emit initial value and then do nothing (fake)
    yield await getAttendanceOverview();
  }
}
