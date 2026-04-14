import '../../domain/entities/bus_snapshot_entity.dart';

class BusSnapshotModel extends BusSnapshotEntity {
  const BusSnapshotModel({
    required super.currentStatus,
    required super.currentStop,
  });

  factory BusSnapshotModel.fake() {
    return const BusSnapshotModel(
      currentStatus: 'In Campus',
      currentStop: 'SAMS University',
    );
  }
}
