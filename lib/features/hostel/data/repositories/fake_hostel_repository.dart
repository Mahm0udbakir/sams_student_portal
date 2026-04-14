import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../domain/entities/hostel_menu_item_entity.dart';
import '../../domain/repositories/hostel_repository.dart';
import '../models/hostel_menu_item_model.dart';

class FakeHostelRepository implements HostelRepository {
  FakeHostelRepository({FakeDataRepository? dataRepository})
      : _dataRepository = dataRepository ?? const FakeDataRepository();

  final FakeDataRepository _dataRepository;

  @override
  Future<List<HostelMenuItemEntity>> getMenuItems() async {
    final items = _dataRepository.getHostelMenuItems();

    return items
        .map(
          (item) => HostelMenuItemModel(
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
          ),
        )
        .toList(growable: false);
  }
}
