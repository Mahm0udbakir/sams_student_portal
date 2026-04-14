import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/scan_option_entity.dart';
import '../../domain/repositories/scan_repository.dart';

part 'scan_event.dart';
part 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  ScanBloc({required ScanRepository repository})
    : _repository = repository,
      super(const ScanState()) {
    on<ScanRequested>(_onScanRequested);
    on<ScanStarted>(_onScanStarted);
    on<ScanGalleryPicked>(_onScanGalleryPicked);
    on<ScanFeedbackCleared>(_onScanFeedbackCleared);
  }

  final ScanRepository _repository;

  Future<void> _onScanRequested(
    ScanRequested event,
    Emitter<ScanState> emit,
  ) async {
    emit(state.copyWith(status: ScanStatus.loading));
    try {
      final options = await _repository.getOptions();
      emit(state.copyWith(status: ScanStatus.ready, options: options));
    } catch (_) {
      emit(
        state.copyWith(
          status: ScanStatus.failure,
          feedbackMessage: 'Failed to load scan options. Please try again.',
        ),
      );
    }
  }

  Future<void> _onScanStarted(
    ScanStarted event,
    Emitter<ScanState> emit,
  ) async {
    await _processScan(
      emit: emit,
      action: ScanAction.camera,
      successMessage: 'Attendance marked for Management Information Systems',
    );
  }

  Future<void> _onScanGalleryPicked(
    ScanGalleryPicked event,
    Emitter<ScanState> emit,
  ) async {
    await _processScan(
      emit: emit,
      action: ScanAction.gallery,
      successMessage: 'Library Access Granted',
    );
  }

  Future<void> _processScan({
    required Emitter<ScanState> emit,
    required ScanAction action,
    required String successMessage,
  }) async {
    emit(
      state.copyWith(
        status: ScanStatus.processing,
        activeAction: action,
        clearFeedback: true,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1750));

    emit(
      state.copyWith(
        status: ScanStatus.success,
        activeAction: action,
        feedbackMessage: successMessage,
      ),
    );

    emit(state.copyWith(status: ScanStatus.ready));
  }

  void _onScanFeedbackCleared(
    ScanFeedbackCleared event,
    Emitter<ScanState> emit,
  ) {
    emit(state.copyWith(clearFeedback: true));
  }
}
