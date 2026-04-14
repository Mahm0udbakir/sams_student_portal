import '../../domain/entities/profile_overview_entity.dart';

class ProfileOverviewModel extends ProfileOverviewEntity {
  const ProfileOverviewModel({
    required super.name,
    required super.studentId,
    required super.sessionSubtitle,
  });

  factory ProfileOverviewModel.fake() {
    return const ProfileOverviewModel(
      name: 'Mahmoud Bakir',
      studentId: '11360',
      sessionSubtitle: '2025 - 2026 • B.Des Semester 5',
    );
  }
}
