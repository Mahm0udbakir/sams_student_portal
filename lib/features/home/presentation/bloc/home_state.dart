part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }


class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.announcementsLoading = false,
    this.studentName,
    this.studentId,
    this.overallAttendance,
    this.attendanceSubtitle,
    this.attendedClassesLabel,
    this.busRouteLabel,
    this.busStatusLabel,
    this.announcements = const <HomeAnnouncementEntity>[],
    this.courseAttendance = const <Map<String, dynamic>>[],
    this.errorMessage,
  });

  final HomeStatus status;
  final bool announcementsLoading;
  final String? studentName;
  final String? studentId;
  final int? overallAttendance;
  final String? attendanceSubtitle;
  final String? attendedClassesLabel;
  final String? busRouteLabel;
  final String? busStatusLabel;
  final List<HomeAnnouncementEntity> announcements;
  final String? errorMessage;
  final List<Map<String, dynamic>> courseAttendance;

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
    bool? announcementsLoading,
    String? studentName,
    String? studentId,
    int? overallAttendance,
    String? attendanceSubtitle,
    String? attendedClassesLabel,
    String? busRouteLabel,
    String? busStatusLabel,
    List<HomeAnnouncementEntity>? announcements,
    List<Map<String, dynamic>>? courseAttendance,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      announcementsLoading: announcementsLoading ?? this.announcementsLoading,
      studentName: studentName ?? this.studentName,
      studentId: studentId ?? this.studentId,
      overallAttendance: overallAttendance ?? this.overallAttendance,
      attendanceSubtitle: attendanceSubtitle ?? this.attendanceSubtitle,
      attendedClassesLabel: attendedClassesLabel ?? this.attendedClassesLabel,
      busRouteLabel: busRouteLabel ?? this.busRouteLabel,
      busStatusLabel: busStatusLabel ?? this.busStatusLabel,
      announcements: announcements ?? this.announcements,
      courseAttendance: courseAttendance ?? this.courseAttendance,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    announcementsLoading,
    studentName,
    studentId,
    overallAttendance,
    attendanceSubtitle,
    attendedClassesLabel,
    busRouteLabel,
    busStatusLabel,
    announcements,
    courseAttendance,
    errorMessage,
  ];
}
