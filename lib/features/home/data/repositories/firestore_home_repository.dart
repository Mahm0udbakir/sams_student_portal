import '../../../../core/services/current_user_service.dart';
import '../../../announcements/repositories/announcement_repository.dart';
import '../../../attendance/data/repositories/firestore_attendance_repository.dart';
import '../../../attendance/domain/entities/attendance_overview_entity.dart';
import '../../../attendance/domain/repositories/attendance_repository.dart';
import '../../domain/entities/home_announcement_entity.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/home_announcement_model.dart';
import '../models/home_dashboard_model.dart';

class FirestoreHomeRepository implements HomeRepository {
  FirestoreHomeRepository({
    AttendanceRepository? attendanceRepository,
    AnnouncementRepository? announcementRepository,
    CurrentUserService? currentUserService,
  })  : _attendanceRepository =
           attendanceRepository ?? FirestoreAttendanceRepository(),
       _announcementRepository = announcementRepository ?? AnnouncementRepository(),
       _currentUserService = currentUserService ?? CurrentUserService();

  final AttendanceRepository _attendanceRepository;
  final AnnouncementRepository _announcementRepository;
  final CurrentUserService _currentUserService;

  static const int _maxHomeAnnouncements = 5;
  static const int _maxPreviewMessageLength = 120;

  @override
  Future<HomeDashboardEntity> getDashboard() async {
    final currentUser = await _currentUserService.loadCurrentUser();
    final results = await Future.wait<Object?>([
      _attendanceRepository.getAttendanceOverview(),
      _loadLatestAnnouncements(),
    ]);

    final overview = results[0] as AttendanceOverviewEntity;
    final announcements = results[1] as List<HomeAnnouncementEntity>;
    final attendancePercent = overview.overallPercent;
    final department = currentUser?.department?.trim();
    final attendanceSubtitle = department != null && department.isNotEmpty
        ? '$department • Live term overview'
        : 'Live term overview';
    final attendedClassesLabel = overview.subjects.isEmpty
        ? 'No attendance records yet'
        : '${overview.subjects.length} tracked subjects • $attendancePercent% overall';

    return HomeDashboardModel(
      studentName: currentUser?.fullName ?? 'Student',
      studentId: currentUser?.studentId ?? '',
      attendancePercent: attendancePercent,
      attendanceSubtitle: attendanceSubtitle,
      attendedClassesLabel: attendedClassesLabel,
      busRouteLabel: 'SAMS Shuttle 03 • Maadi → Ramses',
      busStatusLabel: 'Status: Arriving at Gate 2 (Maadi Campus)',
      announcements: announcements,
    );
  }

  Future<List<HomeAnnouncementEntity>> _loadLatestAnnouncements() async {
    try {
      final announcements = await _announcementRepository.getAnnouncements();
      final sortedAnnouncements = announcements.toList(growable: false)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return sortedAnnouncements
          .take(_maxHomeAnnouncements)
          .map((item) {
            final normalizedTitle = item.title.trim();
            return HomeAnnouncementModel(
              title: normalizedTitle.isEmpty
                  ? 'Untitled announcement'
                  : normalizedTitle,
              subtitle: _buildPreviewMessage(item.message),
              badge: _formatDate(item.createdAt),
            );
          })
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static String _buildPreviewMessage(String message) {
    final normalized = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return 'No message provided.';
    }

    if (normalized.length <= _maxPreviewMessageLength) {
      return normalized;
    }

    return '${normalized.substring(0, _maxPreviewMessageLength - 1).trimRight()}...';
  }

  static String _formatDate(DateTime createdAt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final local = createdAt.toLocal();
    final monthLabel = months[local.month - 1];
    return '$monthLabel ${local.day}, ${local.year}';
  }
}