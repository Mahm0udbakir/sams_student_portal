import '../../domain/entities/profile_overview_entity.dart';

class ProfileOverviewModel extends ProfileOverviewEntity {
  const ProfileOverviewModel({
    required super.name,
    required super.studentId,
    required super.sessionSubtitle,
  });

  factory ProfileOverviewModel.fake() {
    return const ProfileOverviewModel(
      name: 'Student',
      studentId: '',
      sessionSubtitle:
          '2025 - 2026 • Bachelor of Management Sciences – Semester 5',
    );
  }
}
