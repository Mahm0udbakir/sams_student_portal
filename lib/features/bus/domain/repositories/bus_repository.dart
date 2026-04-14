import '../entities/bus_live_info_entity.dart';
import '../entities/bus_route_stop_entity.dart';
import '../entities/bus_snapshot_entity.dart';

abstract class BusRepository {
  Future<BusSnapshotEntity> getSnapshot();
  Future<List<BusRouteStopEntity>> getRouteStops();
  Future<BusLiveInfoEntity> getLiveInfo();
}
