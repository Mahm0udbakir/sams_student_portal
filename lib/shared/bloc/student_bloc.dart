import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/repositories/fake_data_repository.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  StudentBloc({FakeDataRepository? dataRepository})
      : _dataRepository = dataRepository ?? const FakeDataRepository(),
        super(const StudentState()) {
    on<StudentRequested>(_onStudentRequested);
  }

  final FakeDataRepository _dataRepository;

  Future<void> _onStudentRequested(
    StudentRequested event,
    Emitter<StudentState> emit,
  ) async {
    emit(state.copyWith(status: StudentStatus.loading));
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final student = _dataRepository.getProfileOverview();

      emit(
        state.copyWith(
          status: StudentStatus.success,
          studentName: student['name'] as String,
          studentId: student['studentId'] as String,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: StudentStatus.failure,
          errorMessage: 'Failed to load student profile. Please try again.',
        ),
      );
    }
  }
}
