import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bus_live_info_entity.dart';
import '../../domain/entities/bus_route_stop_entity.dart';
import '../../domain/entities/bus_snapshot_entity.dart';
import '../../domain/repositories/bus_repository.dart';

part 'bus_event.dart';
part 'bus_state.dart';

class BusBloc extends Bloc<BusEvent, BusState> {
  BusBloc({required BusRepository repository})
      : _repository = repository,
        super(const BusState()) {
    on<BusRequested>(_onBusRequested);
  }

  final BusRepository _repository;

  Future<void> _onBusRequested(BusRequested event, Emitter<BusState> emit) async {
    emit(state.copyWith(status: BusStatus.loading));
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final snapshotFuture = _repository.getSnapshot();
      final stopsFuture = _repository.getRouteStops();
      final liveInfoFuture = _repository.getLiveInfo();

      final snapshot = await snapshotFuture;
      final stops = await stopsFuture;
      final liveInfo = await liveInfoFuture;

      emit(
        state.copyWith(
          status: BusStatus.success,
          snapshot: snapshot,
          routeStops: stops,
          liveInfo: liveInfo,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: BusStatus.failure,
          errorMessage: 'Failed to load bus tracking. Please try again.',
        ),
      );
    }
  }
}
