import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../domain/entities/bus_live_info_entity.dart';
import '../../domain/entities/bus_route_stop_entity.dart';
import '../../domain/entities/bus_snapshot_entity.dart';
import '../../domain/repositories/bus_repository.dart';
import '../models/bus_snapshot_model.dart';

class FakeBusRepository implements BusRepository {
  FakeBusRepository({FakeDataRepository? dataRepository})
    : _dataRepository = dataRepository ?? const FakeDataRepository();

  final FakeDataRepository _dataRepository;

  @override
  Future<BusSnapshotEntity> getSnapshot() async {
    final snapshot = _dataRepository.getBusSnapshot();

    return BusSnapshotModel(
      currentStatus: snapshot['currentStatus'] as String,
      currentStop: snapshot['currentStop'] as String,
    );
  }

  @override
  Future<List<BusRouteStopEntity>> getRouteStops() async {
    final stops = _dataRepository.getBusRouteStops();

    return stops
        .map(
          (item) => BusRouteStopEntity(
            stop: item['stop'] as String,
            time: item['time'] as String,
            status: item['status'] as String,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<BusLiveInfoEntity> getLiveInfo() async {
    final liveInfo = _dataRepository.getBusLiveInfo();
    return BusLiveInfoEntity(
      nextStop: liveInfo['nextStop'] as String,
      eta: liveInfo['eta'] as String,
      lastUpdated: liveInfo['lastUpdated'] as String,
      routeSummary: liveInfo['routeSummary'] as String,
    );
  }
}
