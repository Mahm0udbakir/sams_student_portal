import 'package:equatable/equatable.dart';

class HostelMenuItemEntity extends Equatable {
  const HostelMenuItemEntity({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  List<Object?> get props => [title, subtitle];
}
