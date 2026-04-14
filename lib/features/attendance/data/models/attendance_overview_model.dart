import '../../domain/entities/attendance_overview_entity.dart';
import 'attendance_subject_model.dart';

class AttendanceOverviewModel extends AttendanceOverviewEntity {
  const AttendanceOverviewModel({
    required super.overallPercent,
    required super.subjects,
  });

  factory AttendanceOverviewModel.fake() {
    return const AttendanceOverviewModel(
      overallPercent: 75,
      subjects: [
        AttendanceSubjectModel(subject: 'Business Analytics', percentage: 92),
        AttendanceSubjectModel(subject: 'Marketing Management', percentage: 84),
        AttendanceSubjectModel(subject: 'Financial Accounting', percentage: 78),
        AttendanceSubjectModel(subject: 'Operations Research', percentage: 74),
        AttendanceSubjectModel(subject: 'Organizational Behavior', percentage: 65),
        AttendanceSubjectModel(subject: 'Business Law', percentage: 59),
        AttendanceSubjectModel(subject: 'Managerial Economics', percentage: 52),
        AttendanceSubjectModel(subject: 'Quantitative Techniques', percentage: 38),
      ],
    );
  }
}
