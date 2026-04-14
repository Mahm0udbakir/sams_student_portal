import '../../domain/entities/home_announcement_entity.dart';

class HomeAnnouncementModel extends HomeAnnouncementEntity {
  const HomeAnnouncementModel({
    required super.title,
    required super.subtitle,
    required super.badge,
  });

  factory HomeAnnouncementModel.fromMap(Map<String, dynamic> map) {
    return HomeAnnouncementModel(
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      badge: map['badge'] as String,
    );
  }
}
