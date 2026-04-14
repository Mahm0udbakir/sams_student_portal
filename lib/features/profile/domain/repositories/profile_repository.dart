import '../entities/profile_overview_entity.dart';

abstract class ProfileRepository {
  Future<ProfileOverviewEntity> getProfileOverview();
}
