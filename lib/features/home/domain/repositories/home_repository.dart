import '../entities/home_dashboard_entity.dart';

abstract class HomeRepository {
  Future<HomeDashboardEntity> getDashboard();
}
