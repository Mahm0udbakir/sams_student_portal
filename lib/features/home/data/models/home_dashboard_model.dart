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
      attendanceSubtitle:
          'Bachelor of Management Sciences – Semester 5 • Current term',
      attendedClassesLabel: '8/11 lectures attended this week',
      busRouteLabel: 'SAMS Shuttle 03 • Maadi → Ramses',
      busStatusLabel: 'Status: Arriving at Gate 2 (Maadi Campus)',
      announcements: const [
        HomeAnnouncementModel(
          title: 'SAMS Midterm Schedule (Semester 5) Published',
          subtitle:
              'Please review your timetable on the SAMS portal. Any clash requests should be sent to Prof. Mohamed Salah before Wednesday 2:00 PM.',
          badge: 'Important',
        ),
        HomeAnnouncementModel(
          title: 'Tuition Installment Window – Spring 2026',
          subtitle:
              'Student Affairs (Maadi Building A) will accept installment requests from 9:30 AM to 2:30 PM. Contact Dr. Fatima Ali for verification support.',
          badge: 'Financial Aid',
        ),
        HomeAnnouncementModel(
          title: 'Career Week: Banking & FMCG Talks',
          subtitle:
              'Guest sessions start Sunday at the Main Auditorium. Opening talk moderated by Dr. Ahmed Hassan and Dr. Sara Ibrahim.',
          badge: 'Academics',
        ),
        HomeAnnouncementModel(
          title: 'Library Extended Hours Before Midterms',
          subtitle:
              'SAMS Central Library will be open until 9:00 PM (Sun–Thu). Floor supervisors include Dr. Nourhan Adel and Prof. Karim Abdelrahman.',
          badge: 'Campus',
        ),
      ],
    );
  }
}
