import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile_overview_entity.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository repository})
    : _repository = repository,
      super(const ProfileState()) {
    on<ProfileRequested>(_onProfileRequested);
  }

  final ProfileRepository _repository;

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final overview = await _repository.getProfileOverview();
      emit(state.copyWith(status: ProfileStatus.success, overview: overview));
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Failed to load profile. Please try again.',
        ),
      );
    }
  }
}
