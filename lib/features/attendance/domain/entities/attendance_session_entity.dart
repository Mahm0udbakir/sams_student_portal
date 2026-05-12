import 'package:equatable/equatable.dart';

class AttendanceSessionEntity extends Equatable {
  const AttendanceSessionEntity({
    required this.sessionId,
    required this.subject,
    required this.room,
    required this.startAt,
    required this.endAt,
    required this.isActive,
    required this.qrPayload,
  });

  final String sessionId;
  final String subject;
  final String room;
  final DateTime startAt;
  final DateTime endAt;
  final bool isActive;
  final String qrPayload;

  @override
  List<Object?> get props => [
    sessionId,
    subject,
    room,
    startAt,
    endAt,
    isActive,
    qrPayload,
  ];
}
