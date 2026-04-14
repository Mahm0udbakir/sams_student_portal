import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../domain/entities/complaint_entity.dart';
import '../../domain/repositories/help_desk_repository.dart';
import '../models/complaint_model.dart';

class FakeHelpDeskRepository implements HelpDeskRepository {
  FakeHelpDeskRepository({FakeDataRepository? dataRepository})
    : _dataRepository = dataRepository ?? const FakeDataRepository();

  final FakeDataRepository _dataRepository;

  @override
  Future<List<ComplaintEntity>> getComplaints() async {
    final complaints = _dataRepository.getComplaints();

    return complaints
        .map(
          (item) => ComplaintModel(
            department: item['department'] as String,
            message: item['message'] as String,
            contact: item['contact'] as String,
          ),
        )
        .toList(growable: false);
  }
}
