import '../../../../core/services/current_user_service.dart';
import '../../domain/entities/profile_overview_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_overview_model.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({CurrentUserService? currentUserService})
    : _currentUserService = currentUserService ?? CurrentUserService();

  final CurrentUserService _currentUserService;

  @override
  Future<ProfileOverviewEntity> getProfileOverview() async {
    final currentUser = await _currentUserService.loadCurrentUser();
    final department = currentUser?.department?.trim();
    final sessionSubtitle = department != null && department.isNotEmpty
        ? '$department • Current term'
        : 'Current term';

    return ProfileOverviewModel(
      name: currentUser?.fullName ?? 'Student',
      studentId: currentUser?.studentId ?? '',
      sessionSubtitle: sessionSubtitle,
    );
  }
}