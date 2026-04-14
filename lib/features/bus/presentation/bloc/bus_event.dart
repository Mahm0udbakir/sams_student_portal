part of 'bus_bloc.dart';

sealed class BusEvent extends Equatable {
  const BusEvent();

  @override
  List<Object?> get props => [];
}

class BusRequested extends BusEvent {
  const BusRequested();
}
