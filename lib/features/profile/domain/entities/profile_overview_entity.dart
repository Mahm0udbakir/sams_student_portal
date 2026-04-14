import 'package:equatable/equatable.dart';

class ProfileOverviewEntity extends Equatable {
  const ProfileOverviewEntity({
    required this.name,
    required this.studentId,
    required this.sessionSubtitle,
  });

  final String name;
  final String studentId;
  final String sessionSubtitle;

  @override
  List<Object?> get props => [name, studentId, sessionSubtitle];
}
