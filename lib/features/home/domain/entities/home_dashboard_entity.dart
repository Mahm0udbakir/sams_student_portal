import 'package:equatable/equatable.dart';

import 'home_announcement_entity.dart';

class HomeDashboardEntity extends Equatable {
  const HomeDashboardEntity({
    required this.studentName,
    required this.studentId,
    required this.attendancePercent,
    required this.attendanceSubtitle,
    required this.attendedClassesLabel,
    required this.busRouteLabel,
    required this.busStatusLabel,
    required this.announcements,
    required this.courseAttendance,
  });

  final String studentName;
  final String studentId;
  final int attendancePercent;
  final String attendanceSubtitle;
  final String attendedClassesLabel;
  final String busRouteLabel;
  final String busStatusLabel;
  final List<HomeAnnouncementEntity> announcements;
  final List<Map<String, dynamic>> courseAttendance; // [{subject: ..., percentage: ...}]

  @override
  List<Object?> get props => [
    studentName,
    studentId,
    attendancePercent,
    attendanceSubtitle,
    attendedClassesLabel,
    busRouteLabel,
    busStatusLabel,
    announcements,
    courseAttendance,
  ];
}
