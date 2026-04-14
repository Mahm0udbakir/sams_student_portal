part of 'student_bloc.dart';

class StudentEntity extends Equatable {
  const StudentEntity({
    required this.name,
    required this.id,
    required this.program,
    required this.semester,
  });

  final String name;
  final String id;
  final String program;
  final String semester;

  @override
  List<Object?> get props => [name, id, program, semester];
}

sealed class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentLoading extends StudentState {
  const StudentLoading();
}

class StudentLoaded extends StudentState {
  const StudentLoaded({required this.student});

  final StudentEntity student;

  @override
  List<Object?> get props => [student];
}

class StudentError extends StudentState {
  const StudentError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
