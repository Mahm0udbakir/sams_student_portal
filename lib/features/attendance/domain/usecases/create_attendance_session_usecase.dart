import '../entities/attendance_session_entity.dart';
import '../repositories/attendance_repository.dart';

class CreateAttendanceSessionParams {
  const CreateAttendanceSessionParams({
    required this.subject,
    required this.room,
    required this.startAt,
    required this.endAt,
    this.isActive = true,
  });

  final String subject;
  final String room;
  final DateTime startAt;
  final DateTime endAt;
  final bool isActive;
}

class CreateAttendanceSessionUseCase {
  CreateAttendanceSessionUseCase({required AttendanceRepository repository})
      : _repository = repository;

  final AttendanceRepository _repository;

  Future<AttendanceSessionEntity> execute(CreateAttendanceSessionParams params) {
    return _repository.createAttendanceSession(
      subject: params.subject,
      room: params.room,
      startAt: params.startAt,
      endAt: params.endAt,
      isActive: params.isActive,
    );
  }
}
