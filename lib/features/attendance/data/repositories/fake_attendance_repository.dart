import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../domain/entities/attendance_overview_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_overview_model.dart';
import '../models/attendance_subject_model.dart';

class FakeAttendanceRepository implements AttendanceRepository {
  FakeAttendanceRepository({FakeDataRepository? dataRepository})
      : _dataRepository = dataRepository ?? const FakeDataRepository();

  final FakeDataRepository _dataRepository;

  @override
  Future<AttendanceOverviewEntity> getAttendanceOverview() async {
    final overview = _dataRepository.getAttendanceOverview();
    final subjectMaps = overview['subjects'] as List<Map<String, dynamic>>;

    return AttendanceOverviewModel(
      overallPercent: overview['overallPercent'] as int,
      subjects: subjectMaps
          .map(
            (item) => AttendanceSubjectModel(
              subject: item['subject'] as String,
              percentage: item['percentage'] as int,
            ),
          )
          .toList(growable: false),
    );
  }
}
