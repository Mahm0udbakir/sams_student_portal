part of 'hostel_bloc.dart';

enum HostelStatus { initial, loading, success, failure }

class HostelState extends Equatable {
  const HostelState({
    this.status = HostelStatus.initial,
    this.menuItems = const [],
    this.errorMessage,
  });

  final HostelStatus status;
  final List<HostelMenuItemEntity> menuItems;
  final String? errorMessage;

  HostelState copyWith({
    HostelStatus? status,
    List<HostelMenuItemEntity>? menuItems,
    String? errorMessage,
  }) {
    return HostelState(
      status: status ?? this.status,
      menuItems: menuItems ?? this.menuItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, menuItems, errorMessage];
}
