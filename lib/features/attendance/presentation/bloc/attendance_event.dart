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

class AttendanceFeedbackCleared extends AttendanceEvent {
  const AttendanceFeedbackCleared();
}
