part of 'student_bloc.dart';

sealed class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class StudentRequested extends StudentEvent {
  const StudentRequested();
}
