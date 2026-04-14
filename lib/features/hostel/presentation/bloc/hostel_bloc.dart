import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/hostel_menu_item_entity.dart';
import '../../domain/repositories/hostel_repository.dart';

part 'hostel_event.dart';
part 'hostel_state.dart';

class HostelBloc extends Bloc<HostelEvent, HostelState> {
  HostelBloc({required HostelRepository repository})
    : _repository = repository,
      super(const HostelState()) {
    on<HostelRequested>(_onHostelRequested);
  }

  final HostelRepository _repository;

  Future<void> _onHostelRequested(
    HostelRequested event,
    Emitter<HostelState> emit,
  ) async {
    emit(state.copyWith(status: HostelStatus.loading));
    try {
      final menuItems = await _repository.getMenuItems();
      emit(state.copyWith(status: HostelStatus.success, menuItems: menuItems));
    } catch (_) {
      emit(
        state.copyWith(
          status: HostelStatus.failure,
          errorMessage: 'Failed to load hostel services. Please try again.',
        ),
      );
    }
  }
}
