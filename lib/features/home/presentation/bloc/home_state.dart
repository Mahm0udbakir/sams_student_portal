part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.studentName,
    this.studentId,
    this.overallAttendance,
    this.attendanceSubtitle,
    this.attendedClassesLabel,
    this.busRouteLabel,
    this.busStatusLabel,
    this.announcements = const <HomeAnnouncementEntity>[],
    this.errorMessage,
  });

  final HomeStatus status;
  final String? studentName;
  final String? studentId;
  final int? overallAttendance;
  final String? attendanceSubtitle;
  final String? attendedClassesLabel;
  final String? busRouteLabel;
  final String? busStatusLabel;
  final List<HomeAnnouncementEntity> announcements;
  final String? errorMessage;

  bool get hasCoreData {
    return studentName != null &&
        studentId != null &&
        overallAttendance != null &&
        attendanceSubtitle != null &&
        attendedClassesLabel != null &&
        busRouteLabel != null &&
        busStatusLabel != null;
  }

  HomeState copyWith({
    HomeStatus? status,
    String? studentName,
    String? studentId,
    int? overallAttendance,
    String? attendanceSubtitle,
    String? attendedClassesLabel,
    String? busRouteLabel,
    String? busStatusLabel,
    List<HomeAnnouncementEntity>? announcements,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      studentName: studentName ?? this.studentName,
      studentId: studentId ?? this.studentId,
      overallAttendance: overallAttendance ?? this.overallAttendance,
      attendanceSubtitle: attendanceSubtitle ?? this.attendanceSubtitle,
      attendedClassesLabel: attendedClassesLabel ?? this.attendedClassesLabel,
      busRouteLabel: busRouteLabel ?? this.busRouteLabel,
      busStatusLabel: busStatusLabel ?? this.busStatusLabel,
      announcements: announcements ?? this.announcements,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    studentName,
    studentId,
    overallAttendance,
    attendanceSubtitle,
    attendedClassesLabel,
    busRouteLabel,
    busStatusLabel,
    announcements,
    errorMessage,
  ];
}
