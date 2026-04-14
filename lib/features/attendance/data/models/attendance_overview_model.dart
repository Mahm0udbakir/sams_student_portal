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
        AttendanceSubjectModel(
          subject: 'Accounting Principles',
          percentage: 92,
        ),
        AttendanceSubjectModel(subject: 'Marketing Management', percentage: 84),
        AttendanceSubjectModel(subject: 'Financial Management', percentage: 78),
        AttendanceSubjectModel(
          subject: 'Business Administration',
          percentage: 74,
        ),
        AttendanceSubjectModel(
          subject: 'Human Resources Management',
          percentage: 65,
        ),
        AttendanceSubjectModel(
          subject: 'Management Information Systems',
          percentage: 59,
        ),
        AttendanceSubjectModel(
          subject: 'Economics for Managers',
          percentage: 52,
        ),
        AttendanceSubjectModel(subject: 'Business Statistics', percentage: 38),
      ],
    );
  }
}
