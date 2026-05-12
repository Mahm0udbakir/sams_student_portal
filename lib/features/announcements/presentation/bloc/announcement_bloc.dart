import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/announcement_repository.dart';

part 'announcement_event.dart';
part 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  AnnouncementBloc({required AnnouncementRepository repository})
    : _repository = repository,
      super(const AnnouncementState()) {
    on<AnnouncementRequested>(_onAnnouncementRequested);
    on<AnnouncementRefreshRequested>(_onAnnouncementRefreshRequested);
    on<AnnouncementAnonymousSignInRequested>(
      _onAnnouncementAnonymousSignInRequested,
    );
  }

  final AnnouncementRepository _repository;

  Future<void> _onAnnouncementRequested(
    AnnouncementRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    await _loadAnnouncements(emit, showLoading: true);
  }

  Future<void> _onAnnouncementRefreshRequested(
    AnnouncementRefreshRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    await _loadAnnouncements(emit, showLoading: true);
  }

  Future<void> _onAnnouncementAnonymousSignInRequested(
    AnnouncementAnonymousSignInRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AnnouncementStatus.requiresSignIn,
        isSigningIn: true,
        clearError: true,
      ),
    );

    try {
      await _repository.ensureSignedIn();
      emit(state.copyWith(isSigningIn: false, clearError: true));
      await _loadAnnouncements(emit, showLoading: true);
    } on AnnouncementAuthException catch (error) {
      emit(
        state.copyWith(
          status: AnnouncementStatus.requiresSignIn,
          isSigningIn: false,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AnnouncementStatus.requiresSignIn,
          isSigningIn: false,
          errorMessage: 'Could not sign in anonymously. Please try again.',
        ),
      );
    }
  }

  Future<void> _loadAnnouncements(
    Emitter<AnnouncementState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(
        state.copyWith(status: AnnouncementStatus.loading, clearError: true),
      );
    }

    try {
      final announcements = await _repository.getAnnouncements();
      emit(
        state.copyWith(
          status: AnnouncementStatus.success,
          announcements: announcements,
          isSigningIn: false,
          clearError: true,
        ),
      );
    } on AnnouncementAuthException catch (error) {
      emit(
        state.copyWith(
          status: AnnouncementStatus.requiresSignIn,
          isSigningIn: false,
          errorMessage: error.message,
        ),
      );
    } on AnnouncementPermissionDeniedException {
      emit(
        state.copyWith(
          status: AnnouncementStatus.requiresSignIn,
          isSigningIn: false,
          errorMessage:
              'Permission denied. Tap Sign in Anonymously, then retry.',
        ),
      );
    } on AnnouncementDataException catch (error) {
      emit(
        state.copyWith(
          status: AnnouncementStatus.failure,
          isSigningIn: false,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AnnouncementStatus.failure,
          isSigningIn: false,
          errorMessage: 'Failed to load announcements. Please try again.',
        ),
      );
    }
  }
}
