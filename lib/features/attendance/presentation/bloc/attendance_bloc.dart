import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/attendance_repository.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc({required AttendanceRepository repository})
    : _repository = repository,
      super(const AttendanceState()) {
    on<AttendanceRequested>(_onAttendanceRequested);
    on<AttendanceMarkRequested>(_onAttendanceMarkRequested);
    on<AttendanceFeedbackCleared>(_onAttendanceFeedbackCleared);
  }

  final AttendanceRepository _repository;

  Future<void> _onAttendanceRequested(
    AttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.loading));
    try {
      final overview = await _repository.getAttendanceOverview();
      final classes = overview.subjects
          .map(
            (subject) => AttendanceClassItem(
              subject: subject.subject,
              percentage: subject.percentage,
              band: AttendanceBand.fromPercentage(subject.percentage),
            ),
          )
          .toList(growable: false);

      emit(
        state.copyWith(
          status: AttendanceStatus.success,
          overallPercent: overview.overallPercent,
          classes: classes,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AttendanceStatus.failure,
          errorMessage: 'Failed to load attendance. Please try again.',
        ),
      );
    }
  }

  Future<void> _onAttendanceMarkRequested(
    AttendanceMarkRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: AttendanceActionStatus.processing,
        actionSubject: event.subject,
        clearFeedback: true,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 700));

    emit(
      state.copyWith(
        actionStatus: AttendanceActionStatus.success,
        actionSubject: event.subject,
        feedbackMessage: 'Attendance Marked Successfully',
      ),
    );
  }

  void _onAttendanceFeedbackCleared(
    AttendanceFeedbackCleared event,
    Emitter<AttendanceState> emit,
  ) {
    emit(
      state.copyWith(
        actionStatus: AttendanceActionStatus.idle,
        actionSubject: null,
        clearFeedback: true,
      ),
    );
  }
}
