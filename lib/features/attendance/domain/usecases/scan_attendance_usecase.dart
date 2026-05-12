import 'dart:convert';

import '../repositories/attendance_repository.dart';

class ScanAttendanceUseCase {
  ScanAttendanceUseCase({required AttendanceRepository repository}) : _repository = repository;

  final AttendanceRepository _repository;

  /// Accepts a raw QR payload, tries to extract `sessionId`, then records attendance.
  Future<void> execute(String qrPayload) async {
    String sessionId = qrPayload;
    try {
      final decoded = jsonDecode(qrPayload);
      if (decoded is Map && decoded['sessionId'] is String) {
        sessionId = decoded['sessionId'] as String;
      }
    } catch (_) {
      // treat qrPayload as raw sessionId
    }

    if (sessionId.isEmpty) {
      throw ArgumentError('Invalid QR payload');
    }

    await _repository.recordAttendance(sessionId: sessionId);
  }
}
