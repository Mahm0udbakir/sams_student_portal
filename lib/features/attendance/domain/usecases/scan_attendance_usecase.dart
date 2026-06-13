import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../repositories/attendance_repository.dart';

class ScanAttendanceUseCase {
  ScanAttendanceUseCase({required AttendanceRepository repository}) : _repository = repository;

  final AttendanceRepository _repository;

  /// Accepts a raw QR payload, tries to extract `sessionId`, then records attendance for [courseSubject].
  Future<void> execute(String qrPayload, {required String courseSubject}) async {
    var sessionId = qrPayload.trim();
    if (sessionId.isEmpty) {
      throw ArgumentError('Invalid QR payload. Please scan the attendance QR code again.');
    }

    try {
      final decoded = jsonDecode(sessionId);
      if (decoded is Map && decoded.containsKey('sessionId')) {
        sessionId = decoded['sessionId']?.toString().trim() ?? sessionId;
      } else if (decoded is String && decoded.trim().isNotEmpty) {
        sessionId = decoded.trim();
      }
    } catch (_) {
      // treat qrPayload as raw sessionId
    }

    if (sessionId.isEmpty) {
      throw ArgumentError('Invalid QR payload. Please scan the attendance QR code again.');
    }

    debugPrint('Parsed attendance sessionId: $sessionId');

    await _repository.recordAttendance(
      sessionId: sessionId,
      courseSubject: courseSubject,
    );
  }
}
