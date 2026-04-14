import 'package:equatable/equatable.dart';

class ScanOptionEntity extends Equatable {
  const ScanOptionEntity({required this.label});

  final String label;

  @override
  List<Object?> get props => [label];
}
