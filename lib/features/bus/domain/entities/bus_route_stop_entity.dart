import 'package:equatable/equatable.dart';

class BusRouteStopEntity extends Equatable {
  const BusRouteStopEntity({
    required this.stop,
    required this.time,
    required this.status,
  });

  final String stop;
  final String time;
  final String status;

  @override
  List<Object?> get props => [stop, time, status];
}
