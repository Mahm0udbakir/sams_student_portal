import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/home_announcement_entity.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../../domain/repositories/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required HomeRepository repository})
    : _repository = repository,
      super(const HomeState()) {
    on<HomeRequested>(_onHomeRequested);
  }

  final HomeRepository _repository;

  Future<void> _onHomeRequested(
    HomeRequested event,
    Emitter<HomeState> emit,
  ) async {
    final hasCoreData = state.hasCoreData;
    emit(
      state.copyWith(
        status: hasCoreData ? HomeStatus.success : HomeStatus.loading,
        announcementsLoading: true,
        clearError: true,
      ),
    );

    try {
      final dashboard = await _repository.getDashboard();
      _emitLoadedState(emit, dashboard);
    } catch (_) {
      if (hasCoreData) {
        emit(
          state.copyWith(
            status: HomeStatus.success,
            announcementsLoading: false,
            errorMessage:
                'Failed to refresh announcements. Showing latest available data.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: HomeStatus.failure,
          announcementsLoading: false,
          errorMessage: 'Failed to load home dashboard. Please try again.',
        ),
      );
    }
  }

  void _emitLoadedState(
    Emitter<HomeState> emit,
    HomeDashboardEntity dashboard,
  ) {
    emit(
      state.copyWith(
        status: HomeStatus.success,
        announcementsLoading: false,
        studentName: dashboard.studentName,
        studentId: dashboard.studentId,
        overallAttendance: dashboard.attendancePercent,
        attendanceSubtitle: dashboard.attendanceSubtitle,
        attendedClassesLabel: dashboard.attendedClassesLabel,
        busRouteLabel: dashboard.busRouteLabel,
        busStatusLabel: dashboard.busStatusLabel,
        announcements: dashboard.announcements,
        courseAttendance: dashboard.courseAttendance,
        clearError: true,
      ),
    );
  }
}
