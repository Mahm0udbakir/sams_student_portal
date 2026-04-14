import 'package:equatable/equatable.dart';

class BusSnapshotEntity extends Equatable {
  const BusSnapshotEntity({
    required this.currentStatus,
    required this.currentStop,
  });

  final String currentStatus;
  final String currentStop;

  @override
  List<Object?> get props => [currentStatus, currentStop];
}
