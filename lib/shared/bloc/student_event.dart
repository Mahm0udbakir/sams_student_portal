part of 'student_bloc.dart';

sealed class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class StudentRequested extends StudentEvent {
  const StudentRequested();
}

class _StudentProfileSnapshot extends StudentEvent {
  const _StudentProfileSnapshot(this.user);

  final AuthUser? user;

  @override
  List<Object?> get props => [user];
}

class _StudentProfileStreamError extends StudentEvent {
  const _StudentProfileStreamError();

  @override
  List<Object?> get props => [];
}
