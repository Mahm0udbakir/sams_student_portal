import '../../domain/entities/home_dashboard_entity.dart';
import 'home_announcement_model.dart';

class HomeDashboardModel extends HomeDashboardEntity {
  const HomeDashboardModel({
    required super.studentName,
    required super.studentId,
    required super.attendancePercent,
    required super.attendanceSubtitle,
    required super.attendedClassesLabel,
    required super.busRouteLabel,
    required super.busStatusLabel,
    required super.announcements,
  });

  factory HomeDashboardModel.fake() {
    return HomeDashboardModel(
      studentName: 'Mahmoud Bakir',
      studentId: '11360',
      attendancePercent: 75,
      attendanceSubtitle: 'for omnichannel',
      attendedClassesLabel: '8/11 classes attended',
      busRouteLabel: 'route no. 3',
      busStatusLabel: 'Status: In campus',
      announcements: const [
        HomeAnnouncementModel(
          title: 'Application Open for DEBSOC Core Team 2025',
          subtitle: 'Last date to apply is Sept 18. Interviews start from Sept 22 in Block B Seminar Hall.',
          badge: 'Important',
        ),
        HomeAnnouncementModel(
          title: 'Post Matric Scholarship Verification Window',
          subtitle: 'Document verification desk will remain open from 10:00 AM to 4:00 PM till Sept 12.',
          badge: 'Financial Aid',
        ),
        HomeAnnouncementModel(
          title: 'Mid-Semester Examination Schedule Released',
          subtitle: 'Please check your exam timetable on ERP and report conflicts to the exam cell immediately.',
          badge: 'Academics',
        ),
        HomeAnnouncementModel(
          title: 'Hostel Night Entry Advisory',
          subtitle: 'Late entry after 9:30 PM requires prior approval from hostel office and wardens.',
          badge: 'Hostel',
        ),
      ],
    );
  }
}
