import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/portal_courses.dart';
import '../../domain/exceptions/attendance_scan_exception.dart';
import '../../domain/entities/attendance_session_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/scan_attendance_usecase.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc({required AttendanceRepository repository})
    : _repository = repository,
      super(const AttendanceState()) {
    on<AttendanceRequested>(_onAttendanceRequested);
    on<AttendanceMarkRequested>(_onAttendanceMarkRequested);
    on<AttendanceFeedbackCleared>(_onAttendanceFeedbackCleared);
    on<AttendanceRecordRequested>(_onAttendanceRecordRequested);
    on<_AttendanceOverviewUpdated>(_onAttendanceOverviewUpdated);
    on<_AttendanceOverviewError>(_onAttendanceOverviewError);
    on<_AttendanceSessionsUpdated>(_onAttendanceSessionsUpdated);
  }

  final AttendanceRepository _repository;
  StreamSubscription? _overviewSub;
  StreamSubscription? _sessionsSub;

  Future<void> _onAttendanceRequested(
    AttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.loading));

    // Cancel previous subscription if any
    await _overviewSub?.cancel();
    await _sessionsSub?.cancel();

    try {
      _overviewSub = _repository.watchAttendanceOverview().listen((overview) {
        final bySubject = {
          for (final s in overview.subjects) s.subject: s,
        };
        final classes = PortalCourses.curriculum
            .map((name) {
              final subject = bySubject[name];
              if (subject == null) {
                return AttendanceClassItem(
                  subject: name,
                  percentage: 0,
                  band: AttendanceBand.fromPercentage(0),
                  attendedCount: 0,
                  scheduledSessionCount: 0,
                  scanDates: const [],
                );
              }
              return AttendanceClassItem(
                subject: subject.subject,
                percentage: subject.percentage,
                band: AttendanceBand.fromPercentage(subject.percentage),
                attendedCount: subject.attendedCount,
                scheduledSessionCount: subject.scheduledSessionCount,
                scanDates: subject.scanDates,
              );
            })
            .toList(growable: false);

        add(_AttendanceOverviewUpdated(overview.overallPercent, classes));
      }, onError: (_) {
        add(_AttendanceOverviewError());
      });

      _sessionsSub = _repository.watchActiveSessions().listen((sessions) {
        add(_AttendanceSessionsUpdated(sessions));
      }, onError: (_) {
        add(const _AttendanceSessionsUpdated(<AttendanceSessionEntity>[]));
      });
    } catch (_) {
      emit(state.copyWith(status: AttendanceStatus.failure, errorMessage: 'Failed to load attendance. Please try again.'));
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

  Future<void> _onAttendanceRecordRequested(
    AttendanceRecordRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: AttendanceActionStatus.processing,
        actionSubject: event.courseSubject,
        clearFeedback: true,
      ),
    );
    try {
      await ScanAttendanceUseCase(repository: _repository).execute(
        event.sessionId,
        courseSubject: event.courseSubject,
      );
      emit(state.copyWith(actionStatus: AttendanceActionStatus.success, feedbackMessage: 'Attendance recorded'));
    } on AttendanceDuplicateScanException catch (error) {
      emit(state.copyWith(actionStatus: AttendanceActionStatus.failure, feedbackMessage: error.message));
    } on AttendanceSessionNotFoundException catch (error) {
      emit(state.copyWith(actionStatus: AttendanceActionStatus.failure, feedbackMessage: error.message));
    } on AttendanceScanException catch (error) {
      emit(state.copyWith(actionStatus: AttendanceActionStatus.failure, feedbackMessage: error.message));
    } catch (_) {
      emit(state.copyWith(actionStatus: AttendanceActionStatus.failure, feedbackMessage: 'Failed to record attendance'));
    }
  }

  @override
  Future<void> close() {
    _overviewSub?.cancel();
    _sessionsSub?.cancel();
    return super.close();
  }

  // Internal events for stream handling
  void _onAttendanceOverviewUpdated(_AttendanceOverviewUpdated event, Emitter<AttendanceState> emit) {
    emit(state.copyWith(status: AttendanceStatus.success, overallPercent: event.overall, classes: event.classes));
  }

  void _onAttendanceOverviewError(_AttendanceOverviewError event, Emitter<AttendanceState> emit) {
    emit(state.copyWith(status: AttendanceStatus.failure, errorMessage: 'Failed to load attendance. Please try again.'));
  }

  void _onAttendanceSessionsUpdated(
    _AttendanceSessionsUpdated event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(sessions: event.sessions));
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
