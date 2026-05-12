import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../core/services/current_user_service.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  StudentBloc({CurrentUserService? currentUserService})
    : _currentUserService = currentUserService ?? CurrentUserService(),
      super(const StudentState()) {
    on<StudentRequested>(_onStudentRequested);
  }

  final CurrentUserService _currentUserService;
  StreamSubscription<AuthUser?>? _userSubscription;

  Future<void> _onStudentRequested(
    StudentRequested event,
    Emitter<StudentState> emit,
  ) async {
    emit(state.copyWith(status: StudentStatus.loading));
    try {
      await _userSubscription?.cancel();
      _userSubscription = _currentUserService.watchCurrentUser().listen((currentUser) {
        if (currentUser == null) {
          emit(
            state.copyWith(
              status: StudentStatus.failure,
              errorMessage: 'No signed-in user was found. Please log in again.',
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: StudentStatus.success,
            studentName: currentUser.fullName,
            studentId: currentUser.studentId,
          ),
        );
      }, onError: (_) {
        emit(
          state.copyWith(
            status: StudentStatus.failure,
            errorMessage: 'Failed to load student profile. Please try again.',
          ),
        );
      });
    } catch (_) {
      emit(
        state.copyWith(
          status: StudentStatus.failure,
          errorMessage: 'Failed to load student profile. Please try again.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
