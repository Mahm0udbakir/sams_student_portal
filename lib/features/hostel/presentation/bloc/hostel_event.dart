part of 'hostel_bloc.dart';

sealed class HostelEvent extends Equatable {
  const HostelEvent();

  @override
  List<Object?> get props => [];
}

class HostelRequested extends HostelEvent {
  const HostelRequested();
}
