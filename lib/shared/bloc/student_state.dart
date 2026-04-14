part of 'student_bloc.dart';

enum StudentStatus { initial, loading, success, failure }

class StudentState extends Equatable {
  const StudentState({
    this.status = StudentStatus.initial,
    this.studentName,
    this.studentId,
    this.errorMessage,
  });

  final StudentStatus status;
  final String? studentName;
  final String? studentId;
  final String? errorMessage;

  bool get hasData => studentName != null && studentId != null;

  StudentState copyWith({
    StudentStatus? status,
    String? studentName,
    String? studentId,
    String? errorMessage,
  }) {
    return StudentState(
      status: status ?? this.status,
      studentName: studentName ?? this.studentName,
      studentId: studentId ?? this.studentId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, studentName, studentId, errorMessage];
}
