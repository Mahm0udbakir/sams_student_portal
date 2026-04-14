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
  });

  final String studentName;
  final String studentId;
  final int attendancePercent;
  final String attendanceSubtitle;
  final String attendedClassesLabel;
  final String busRouteLabel;
  final String busStatusLabel;
  final List<HomeAnnouncementEntity> announcements;

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
      ];
}
