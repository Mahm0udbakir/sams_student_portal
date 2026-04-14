part of 'bus_bloc.dart';

enum BusStatus { initial, loading, success, failure }

class BusState extends Equatable {
  const BusState({
    this.status = BusStatus.initial,
    this.snapshot,
    this.routeStops = const <BusRouteStopEntity>[],
    this.liveInfo,
    this.errorMessage,
  });

  final BusStatus status;
  final BusSnapshotEntity? snapshot;
  final List<BusRouteStopEntity> routeStops;
  final BusLiveInfoEntity? liveInfo;
  final String? errorMessage;

  bool get hasData =>
      snapshot != null && routeStops.isNotEmpty && liveInfo != null;

  bool get isInCampus => snapshot?.currentStatus.toLowerCase() == 'in campus';

  BusState copyWith({
    BusStatus? status,
    BusSnapshotEntity? snapshot,
    List<BusRouteStopEntity>? routeStops,
    BusLiveInfoEntity? liveInfo,
    String? errorMessage,
  }) {
    return BusState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      routeStops: routeStops ?? this.routeStops,
      liveInfo: liveInfo ?? this.liveInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    snapshot,
    routeStops,
    liveInfo,
    errorMessage,
  ];
}
