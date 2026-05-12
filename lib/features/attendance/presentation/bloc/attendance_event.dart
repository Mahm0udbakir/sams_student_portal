part of 'attendance_bloc.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceRequested extends AttendanceEvent {
  const AttendanceRequested();
}

class AttendanceMarkRequested extends AttendanceEvent {
  const AttendanceMarkRequested({required this.subject});

  final String subject;

  @override
  List<Object?> get props => [subject];
}

class AttendanceRecordRequested extends AttendanceEvent {
  const AttendanceRecordRequested({required this.sessionId});

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class AttendanceFeedbackCleared extends AttendanceEvent {
  const AttendanceFeedbackCleared();
}

// Internal events used by the bloc to update state from repository streams.
class _AttendanceOverviewUpdated extends AttendanceEvent {
  const _AttendanceOverviewUpdated(this.overall, this.classes);

  final int overall;
  final List<AttendanceClassItem> classes;

  @override
  List<Object?> get props => [overall, classes];
}

class _AttendanceOverviewError extends AttendanceEvent {
  const _AttendanceOverviewError();
}

class _AttendanceSessionsUpdated extends AttendanceEvent {
  const _AttendanceSessionsUpdated(this.sessions);

  final List<AttendanceSessionEntity> sessions;

  @override
  List<Object?> get props => [sessions];
}
