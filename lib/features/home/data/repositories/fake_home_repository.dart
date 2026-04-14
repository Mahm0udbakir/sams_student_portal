import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/home_dashboard_model.dart';
import '../models/home_announcement_model.dart';

class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({FakeDataRepository? dataRepository})
    : _dataRepository = dataRepository ?? const FakeDataRepository();

  final FakeDataRepository _dataRepository;

  @override
  Future<HomeDashboardEntity> getDashboard() async {
    final dashboard = _dataRepository.getHomeDashboard();
    final announcementMaps =
        (dashboard['announcements'] as List<Map<String, dynamic>>);

    return HomeDashboardModel(
      studentName: dashboard['studentName'] as String,
      studentId: dashboard['studentId'] as String,
      attendancePercent: dashboard['attendancePercent'] as int,
      attendanceSubtitle: dashboard['attendanceSubtitle'] as String,
      attendedClassesLabel: dashboard['attendedClassesLabel'] as String,
      busRouteLabel: dashboard['busRouteLabel'] as String,
      busStatusLabel: dashboard['busStatusLabel'] as String,
      announcements: announcementMaps
          .map(HomeAnnouncementModel.fromMap)
          .toList(growable: false),
    );
  }
}
