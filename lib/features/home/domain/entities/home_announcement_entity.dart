import 'package:equatable/equatable.dart';

class HomeAnnouncementEntity extends Equatable {
  const HomeAnnouncementEntity({
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final String badge;

  @override
  List<Object?> get props => [title, subtitle, badge];
}
