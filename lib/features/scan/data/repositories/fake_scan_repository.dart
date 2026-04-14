import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../domain/entities/scan_option_entity.dart';
import '../../domain/repositories/scan_repository.dart';
import '../models/scan_option_model.dart';

class FakeScanRepository implements ScanRepository {
  FakeScanRepository({FakeDataRepository? dataRepository})
      : _dataRepository = dataRepository ?? const FakeDataRepository();

  final FakeDataRepository _dataRepository;

  @override
  Future<List<ScanOptionEntity>> getOptions() async {
    final options = _dataRepository.getScanOptions();

    return options
        .map((item) => ScanOptionModel(label: item['label'] as String))
        .toList(growable: false);
  }
}
