import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/complaint_entity.dart';
import '../../domain/repositories/help_desk_repository.dart';

part 'help_desk_event.dart';
part 'help_desk_state.dart';

class HelpDeskBloc extends Bloc<HelpDeskEvent, HelpDeskState> {
  HelpDeskBloc({required HelpDeskRepository repository})
    : _repository = repository,
      _random = Random(),
      super(const HelpDeskState()) {
    on<HelpDeskRequested>(_onHelpDeskRequested);
    on<HelpDeskConcernSubmitted>(_onHelpDeskConcernSubmitted);
    on<HelpDeskSubmissionNoticeCleared>(_onHelpDeskSubmissionNoticeCleared);
    on<HelpDeskComplaintAdded>(_onHelpDeskComplaintAdded);
  }

  final HelpDeskRepository _repository;
  final Random _random;

  static const _submissionBaseDelayMs = 1500;
  static const _submissionJitterMs = 500;

  Future<void> _onHelpDeskRequested(
    HelpDeskRequested event,
    Emitter<HelpDeskState> emit,
  ) async {
    emit(state.copyWith(status: HelpDeskStatus.loading));
    try {
      final complaints = await _repository.getComplaints();
      emit(
        state.copyWith(status: HelpDeskStatus.success, complaints: complaints),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HelpDeskStatus.failure,
          errorMessage: 'Failed to load help desk requests. Please try again.',
        ),
      );
    }
  }

  Future<void> _onHelpDeskConcernSubmitted(
    HelpDeskConcernSubmitted event,
    Emitter<HelpDeskState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: HelpDeskSubmissionStatus.submitting,
        clearSubmissionMessage: true,
      ),
    );

    final simulatedDelay = Duration(
      milliseconds:
          _submissionBaseDelayMs + _random.nextInt(_submissionJitterMs + 1),
    );
    await Future<void>.delayed(simulatedDelay);

    final updatedComplaints = _buildUpdatedComplaints(event);

    emit(
      state.copyWith(
        status: HelpDeskStatus.success,
        complaints: updatedComplaints,
        submissionStatus: HelpDeskSubmissionStatus.success,
        submissionMessage: 'Concern submitted successfully',
      ),
    );
  }

  List<ComplaintEntity> _buildUpdatedComplaints(
    HelpDeskConcernSubmitted event,
  ) {
    // Keep newest concern at the top so users see immediate feedback.
    return <ComplaintEntity>[
      ComplaintEntity(
        department: event.department,
        message: event.concern,
        contact: 'Help Desk Team\nExt. 101',
      ),
      ...state.complaints,
    ];
  }

  void _onHelpDeskSubmissionNoticeCleared(
    HelpDeskSubmissionNoticeCleared event,
    Emitter<HelpDeskState> emit,
  ) {
    emit(
      state.copyWith(
        submissionStatus: HelpDeskSubmissionStatus.idle,
        clearSubmissionMessage: true,
      ),
    );
  }

  void _onHelpDeskComplaintAdded(
    HelpDeskComplaintAdded event,
    Emitter<HelpDeskState> emit,
  ) {
    emit(
      state.copyWith(
        status: HelpDeskStatus.success,
        complaints: [event.complaint, ...state.complaints],
      ),
    );
  }
}
