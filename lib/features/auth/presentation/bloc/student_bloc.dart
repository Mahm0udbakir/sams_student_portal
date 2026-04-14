import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/fake_data_repository.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  StudentBloc({FakeDataRepository? dataRepository})
      : _dataRepository = dataRepository ?? const FakeDataRepository(),
        super(const StudentInitial()) {
    on<LoadStudent>(_onLoadStudent);
  }

  final FakeDataRepository _dataRepository;

  Future<void> _onLoadStudent(LoadStudent event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final profile = _dataRepository.getProfileOverview();

      final student = StudentEntity(
        name: profile['name'] as String,
        id: profile['studentId'] as String,
        program: 'B.Des',
        semester: 'Sem 5',
      );

      emit(StudentLoaded(student: student));
    } catch (_) {
      emit(const StudentError(message: 'Failed to load student information. Please try again.'));
    }
  }
}
