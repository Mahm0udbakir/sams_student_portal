import 'package:equatable/equatable.dart';

class BusLiveInfoEntity extends Equatable {
  const BusLiveInfoEntity({
    required this.nextStop,
    required this.eta,
    required this.lastUpdated,
    required this.routeSummary,
  });

  final String nextStop;
  final String eta;
  final String lastUpdated;
  final String routeSummary;

  @override
  List<Object?> get props => [nextStop, eta, lastUpdated, routeSummary];
}
