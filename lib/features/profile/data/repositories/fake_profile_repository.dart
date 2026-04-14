import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../domain/entities/profile_overview_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_overview_model.dart';

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({FakeDataRepository? dataRepository})
    : _dataRepository = dataRepository ?? const FakeDataRepository();

  final FakeDataRepository _dataRepository;

  @override
  Future<ProfileOverviewEntity> getProfileOverview() async {
    final profile = _dataRepository.getProfileOverview();

    return ProfileOverviewModel(
      name: profile['name'] as String,
      studentId: profile['studentId'] as String,
      sessionSubtitle: profile['sessionSubtitle'] as String,
    );
  }
}
