import '../../../../core/constants/portal_courses.dart';
import '../../domain/entities/attendance_overview_entity.dart';
import 'attendance_subject_model.dart';

class AttendanceOverviewModel extends AttendanceOverviewEntity {
  const AttendanceOverviewModel({
    required super.overallPercent,
    required super.subjects,
  });

  factory AttendanceOverviewModel.fake() {
    return AttendanceOverviewModel(
      overallPercent: 78,
      subjects: [
        AttendanceSubjectModel(
          subject: PortalCourses.curriculum[0],
          percentage: 92,
          attendedCount: 11,
          scheduledSessionCount: 12,
        ),
        AttendanceSubjectModel(
          subject: PortalCourses.curriculum[1],
          percentage: 84,
          attendedCount: 9,
          scheduledSessionCount: 12,
        ),
        AttendanceSubjectModel(
          subject: PortalCourses.curriculum[2],
          percentage: 76,
          attendedCount: 8,
          scheduledSessionCount: 12,
        ),
        AttendanceSubjectModel(
          subject: PortalCourses.curriculum[3],
          percentage: 71,
          attendedCount: 7,
          scheduledSessionCount: 12,
        ),
      ],
    );
  }
}
