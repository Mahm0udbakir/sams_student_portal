part of 'attendance_bloc.dart';

enum AttendanceStatus { initial, loading, success, failure }

enum AttendanceActionStatus { idle, processing, success, failure }

enum AttendanceBand {
  green,
  yellow,
  red;

  static AttendanceBand fromPercentage(int percentage) {
    if (percentage >= 80) {
      return AttendanceBand.green;
    }

    if (percentage >= 60) {
      return AttendanceBand.yellow;
    }

    return AttendanceBand.red;
  }
}

class AttendanceClassItem extends Equatable {
  const AttendanceClassItem({
    required this.subject,
    required this.percentage,
    required this.band,
    required this.attendedCount,
    required this.scanDates,
  });

  final String subject;
  final int percentage;
  final AttendanceBand band;
  final int attendedCount;
  final List<DateTime> scanDates;

  @override
  List<Object?> get props => [subject, percentage, band, attendedCount, scanDates];
}

class AttendanceState extends Equatable {
  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.overallPercent,
    this.classes = const <AttendanceClassItem>[],
    this.sessions = const <AttendanceSessionEntity>[],
    this.actionStatus = AttendanceActionStatus.idle,
    this.actionSubject,
    this.feedbackMessage,
    this.errorMessage,
  });

  final AttendanceStatus status;
  final int? overallPercent;
  final List<AttendanceClassItem> classes;
  final List<AttendanceSessionEntity> sessions;
  final AttendanceActionStatus actionStatus;
  final String? actionSubject;
  final String? feedbackMessage;
  final String? errorMessage;

  bool get hasData => overallPercent != null && classes.isNotEmpty;

  AttendanceState copyWith({
    AttendanceStatus? status,
    int? overallPercent,
    List<AttendanceClassItem>? classes,
    List<AttendanceSessionEntity>? sessions,
    AttendanceActionStatus? actionStatus,
    String? actionSubject,
    String? feedbackMessage,
    bool clearFeedback = false,
    String? errorMessage,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      overallPercent: overallPercent ?? this.overallPercent,
      classes: classes ?? this.classes,
      sessions: sessions ?? this.sessions,
      actionStatus: actionStatus ?? this.actionStatus,
      actionSubject: actionSubject ?? this.actionSubject,
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    overallPercent,
    classes,
    sessions,
    actionStatus,
    actionSubject,
    feedbackMessage,
    errorMessage,
  ];
}
